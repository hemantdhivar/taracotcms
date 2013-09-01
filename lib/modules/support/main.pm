package modules::support::main;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use Date::Format;
use taracot::AUBBC;
use Lingua::Identify qw(:language_identification);
use taracot::jevix;
use Digest::MD5 qw(md5_hex);
use Encode;

# Configuration

my $defroute = '/support';

# Module core settings 

my $lang;
prefix $defroute;
my $detect_lang;
my @columns = ('id','stopic_id','stopic','sdate','susername_last','sstatus','unread'); 

sub _name() {
 &_load_lang();
  return $lang->{module_name};
}           
sub _defroute() {
  return $defroute;
}
sub _load_lang {
  $detect_lang = &taracot::_detect_lang();
  my $lng = $detect_lang->{lng} || config->{lang_default};
  my $lang_adm = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/support/lang/en.lng') || {};
  my $lang_adm_cnt={};
  if ($lng ne 'en') {
   $lang_adm_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/support/lang/'.$lng.'.lng') || {};
  } 
  my $lang_mod = YAML::XS::LoadFile(config->{root_dir}.'lib/taracot/lang/en.lng') || {};
  my $lang_mod_cnt={};
  if ($lng ne 'en') {
   $lang_mod_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/taracot/lang/'.$lng.'.lng') || {};
  }
  $lang = { %$lang_adm, %$lang_mod, %$lang_adm_cnt, %$lang_mod_cnt };
  return $lng;
}

# Routes

get '/' => sub {
  my $auth = &taracot::_auth();
  my $_current_lang=_load_lang(); 
  my $page_data = &taracot::_load_settings('site_title,keywords,description,support_topics', $_current_lang);
  my $st = $page_data->{support_topics};
  my @st_arr = split(/;/, $st);
  my @topics;
  foreach my $item(@st_arr) {
    my ($tid, $tt) = split(/,/, $item);
    my %tc;
    $tid =~ s/^\s+//;
    $tid =~ s/\s+$//;
    $tt =~ s/^\s+//;
    $tt =~ s/\s+$//;
    $tc{id} = $tid;
    $tc{title} = $tt;
    push @topics, \%tc;
  }
  if (!$auth->{id}) {
    return &taracot::_process_template( template 'support_error', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'support.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{module_name}, auth_data => $auth, errmsg => $lang->{error_unauth_long} }, { layout => config->{layout}.'_'.$_current_lang } );
  }
  return &taracot::_process_template( template 'support_index', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'support.css" rel="stylesheet" /><link href="'.config->{modules_css_url}.'wbbtheme.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{module_name}, auth_data => $auth, topics => \@topics  }, { layout => config->{layout}.'_'.$_current_lang } );
  pass();
};

get '/data/list' => sub {
  my $auth = &taracot::_auth();
  if (!$auth) { redirect '/admin?'.md5_hex(time); return true }
  my $_current_lang=_load_lang(); 
  content_type 'application/json';
  my $sEcho = param('sEcho') || 0;
  $sEcho=int($sEcho);
  my $iDisplayStart = param('iDisplayStart') || 0;
  $iDisplayStart=int($iDisplayStart);
  my $iDisplayLength = param('iDisplayLength') || 0;
  $iDisplayLength=int($iDisplayLength);
  my $iColumns = param('iColumns') || @columns;
  $iColumns=int($iColumns);
  my $sSearch = '';
  my $iSortingCols = param('iSortingCols') || 0;
  $iSortingCols=int($iSortingCols);
  my $iSortCol_0 = param('iSortCol_0') || 0;
  $iSortCol_0=int($iSortCol_0);
  my $sSortCol = $columns[$iSortCol_0] || 'id';
  my $sSortDir = param('sSortDir_0') || '';
  if ($sSortDir ne "asc" && $sSortDir ne "desc") {
   $sSortDir="asc";
  }
  my $where='susername='.database->quote($auth->{username});  
  my $total=0;
  my $sth = database->prepare(
   'SELECT COUNT(*) AS cnt FROM '.config->{db_table_prefix}.'_support WHERE '.$where
  );
  if ($sth->execute()) {
   ($total) = $sth -> fetchrow_array;
  }
  $sth->finish();
  my $total_filtered=$total;
  my $sortorder=' ';  
  my @data;
  if ($sSortCol) {
   $sortorder=" ORDER BY $sSortCol $sSortDir";
  }
  my $columns=join(',',@columns);
  $columns=~s/,$//;
  $sth = database->prepare(
   'SELECT '.$columns.' FROM '.config->{db_table_prefix}.'_support WHERE '.$where.$sortorder.' LIMIT '.$iDisplayStart.', '.$iDisplayLength
  );
  if ($sth->execute()) {
   while(my (@ary) = $sth -> fetchrow_array) {
    $ary[3] = time2str($lang->{date_time_template}, $ary[3]);
    $ary[3] =~ s/\\//gm;
    push(@ary, '');
    push(@data, \@ary);
   }
  }
  $sth->finish();  
  my $json_xs = JSON::XS->new();
  my $json = $json_xs->encode(\@data);
  # Begin: return JSON data
  return qq~{
    "sEcho": $sEcho,
    "iTotalRecords": "$total",
    "iTotalDisplayRecords": "$total_filtered",
    "aaData": $json   
  }~;
}; 
 
post '/ticket/load' => sub {
  my $auth = &taracot::_auth();
  if (!$auth) { 
    return '{"status":"0"}'; 
  }
  my $_current_lang=_load_lang();
  my $tid = int(param('tid')) || 0;
  if (!$tid || $tid<1) {
    return '{"status":"0"}';
  }
  my $ticket = database->quick_select(config->{db_table_prefix}.'_support', { id => $tid });
  if (!$ticket || $ticket->{susername} ne $auth->{username}) { 
    return '{"status":"0"}'; 
  }
  $ticket->{status} = 1;
  $ticket->{sdate} = time2str($lang->{date_time_template}, $ticket->{sdate});
  $ticket->{sdate} =~ s/\\//gm;
  my @ans;
  my $sth = database->prepare(
   'SELECT * FROM '.config->{db_table_prefix}.'_support_ans WHERE tid = '.$tid.' ORDER BY sdate ASC'
  );  
  if ($sth->execute()) {
   while(my $item = $sth->fetchrow_hashref) {
    $item->{sdate} = time2str($lang->{date_time_template}, $item->{sdate});
    $item->{sdate} =~ s/\\//gm;
    if ($item->{susername} ne $auth->{username}) {
      $item->{reply} = 1;
    }
    push @ans, $item;
   }
  }
  $sth->finish();
  $ticket->{ans} = \@ans;
  my $json_xs = JSON::XS->new();
  return $json_xs->encode($ticket);
};

post '/answer/save' => sub {
  my $auth = &taracot::_auth();
  if (!$auth) { 
    return '{"status":"0"}'; 
  }
  my $ans = param('ans');
  if (length($ans) > 102400 || !$ans) {
    return '{"status":"0"}'; 
  }
  my $_current_lang=_load_lang();
  my $tid = int(param('tid')) || 0;
  if (!$tid || $tid<1) {
    return '{"status":"0"}';
  }
  my $ticket = database->quick_select(config->{db_table_prefix}.'_support', { id => $tid });
  if (!$ticket || $ticket->{susername} ne $auth->{username}) { 
    return '{"status":"0"}'; 
  }
  my $aubbc = taracot::AUBBC->new();
  $ans =~ s/\</&lt;/gm;
  $ans =~ s/\>/&gt;/gm;
  my $ans_html = $aubbc->do_all_ubbc($ans);
  # Process typography
  if (langof($ans) eq 'ru') {
    my $conf = {
      isHTML => 1, # Hypertext mode (plain text mode is faster)
      vanish => 0, # Convert source into plain text (ignores all other options)
      lineBreaks => 0, # Add linebreaks <br />
      paragraphs => 0, # Add paragraphs <p>
      dashes => 1, # Long dashes
      dots => 1, # Convert three dots into ellipsis
      edgeSpaces => 1, # Clear white spaces around string
      tagSpaces => 1, # Clear white spaces between tags (</td> <td>)
      multiSpaces => 1, # Convert multiple white spaces into single
      redundantSpaces => 1, # Clear white spaces where they should not be
      compositeWords => 1, # Put composite words inside <nobr> tag
      compositeWordsLength => 10, # The maximum length of composite word to put inside <nobr>
      nbsp => 1, # Convert spaceses into non-breaking spaces where necessary
      quotes => 1, # Quotes makeup
      qaType => 0, # Outer quotes type (http://jevix.ru/)
      qbType => 1, # Inner quotes type
      misc => 1, # Little things (&copy, fractions and other)
      codeMode => 2, # Special chars representation (0: ANSI <...>, 1: HTML <&#133;>, 2: HTML entities <&hellip;>)
      tagsDenyAll => 0, # Deny all tags by default
      tagsDeny => '', # Deny tags list
      tagsAllow => '|A:href:title,br,B:STYLE', # Allowed tags list (exception to "deny all" mode)
      tagCloseSingle => 1, # Close single tags when they are not
      tagCloseOpen => 0, # Close all open tags at the end of the document
      tagNamesToLower => 0, # Bring tag names to lower case
      tagNamesToUpper => 0, # Bring tag names to upper case
      tagAttributesToLower => 1, # Bring tag attributes names to lower case
      tagAttributesToUpper => 0, # Bring tag attributes names to upper case
      tagQuoteValues => 0, # Quote tag attribute values
      tagUnQuoteValues => 0, # Unquote tag attributes values
      links => 0, # Put urls into <a> tag
      linksAttributes => {target=>'_blank'}, # Hash containing all new links attributes set
      simpleXSS => 1, # Detect and prevent XSS
      checkHTML => 0, # Check for HTML integrity
      logErrors => 0 # Log errors
    };
    my $jevix = new taracot::jevix;
    $jevix->setConf($conf);
    $ans_html = $jevix->process(\encode_utf8($ans))->{text};
  }  
  if (length($ans_html) > 102400 || !$ans_html) {
    return '{"status":"0"}'; 
  }
  my $ans_html_hash = md5_hex(encode_utf8($ans_html));
  my $ahc = database->quick_select(config->{db_table_prefix}.'_support_ans', { smsg_hash => $ans_html_hash, tid => $tid });
  if ($ahc) {
    return '{"status":"-1"}';
  }
  database->quick_insert(config->{db_table_prefix}.'_support_ans', { susername => $auth->{username}, tid => $tid, sdate => time, smsg => $ans_html, smsg_hash => $ans_html_hash }); 
  my $aid = database->{q{mysql_insertid}};
  my %res;
  my $json_xs = JSON::XS->new();
  $res{status} = 1;
  $res{ans} = $ans_html;
  $res{id} = $aid;
  $res{username} = $auth->{username};
  my $sd = time2str($lang->{date_time_template}, time);
  $sd =~ s/\\//gm;
  $res{sdate} = $sd;
  return $json_xs->encode(\%res);
};

# End

1;