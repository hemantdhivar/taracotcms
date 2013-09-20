package modules::support::main;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use Date::Format;
use taracot::AUBBC;
use Lingua::Identify qw(:language_identification);
use taracot::jevix;
use Digest::MD5 qw(md5_hex);
use Encode;
use Dancer::Plugin::Email;
use HTML::Entities qw(encode_entities_numeric);

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
  if (!$auth->{id}) {
    return redirect '/user/authorize?comeback=/support';
  }
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
  return &taracot::_process_template( template 'support_index', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'support.css" rel="stylesheet" /><link href="'.config->{modules_css_url}.'wbbtheme.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{module_name}, auth_data => $auth, topics => \@topics  }, { layout => config->{layout}.'_'.$_current_lang } );
  pass();
};

get '/specialist' => sub {
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
  my $allow = undef;
  $allow = 1 if ($auth->{status} eq 2);
  $allow = 1 if ($auth->{groups_hash}->{'support_specialist'});
  foreach my $st (@topics) {
    if ($auth->{groups_hash}->{'support_specialist_'.$st->{id}}) { 
      $allow = 1;
    }
  }
  if (!$allow) {
    return &taracot::_process_template( template 'support_error', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'support.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{module_name}, auth_data => $auth, errmsg => $lang->{error_perm_long} }, { layout => config->{layout}.'_'.$_current_lang } );    
  }
  return &taracot::_process_template( template 'support_specialist', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'support.css" rel="stylesheet" /><link href="'.config->{modules_css_url}.'wbbtheme.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{specialist}, auth_data => $auth, topics => \@topics  }, { layout => config->{layout}.'_'.$_current_lang } );
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
  my $page_data = &taracot::_load_settings('support_topics', $_current_lang);
  my %topics;
  foreach my $item(split(/;/, $page_data->{support_topics})) {
    my ($tid, $tt) = split(/,/, $item);    
    $tid =~ s/^\s+//;
    $tid =~ s/\s+$//;
    $tt =~ s/^\s+//;
    $tt =~ s/\s+$//;
    $topics{$tid} = $tt;
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
    if ($topics{$ary[1]}) {
      $ary[1] = $topics{$ary[1]};
    }
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

get '/data/list_specialist' => sub {
  my $auth = &taracot::_auth();
  if (!$auth) { redirect '/admin?'.md5_hex(time); return true }
  my $_current_lang=_load_lang(); 
  my $page_data = &taracot::_load_settings('support_topics', $_current_lang);
  my @topics;
  my %topics_hash;
  foreach my $item(split(/;/, $page_data->{support_topics})) {
    my ($tid,$tv) = split(/,/, $item);
    $tid =~ s/^\s+//;
    $tid =~ s/\s+$//;
    $tv =~ s/^\s+//;
    $tv =~ s/\s+$//;
    push @topics, $tid;
    $topics_hash{$tid} = $tv;
  }
  my $allow = undef;
  my $topics_sql = ' AND (';
  $allow = 1 if ($auth->{status} eq 2);
  $allow = 1 if ($auth->{groups_hash}->{'support_specialist'});
  foreach my $st (@topics) {
    if ($auth->{groups_hash}->{'support_specialist_'.$st}) { 
      $allow = 2;
      $topics_sql .= ' OR stopic_id = '.database->quote($st)
    }
  }
  $topics_sql =~ s/ OR //;
  $topics_sql .= ')';
  if (!$allow) {
    return $lang->{error_perm_long};
  }
  if ($allow ne 2) {
    $topics_sql = '';
  }
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
  my $where = 'sstatus < 2';  
  my $total=0;
  my $sth = database->prepare(
   'SELECT COUNT(*) AS cnt FROM '.config->{db_table_prefix}.'_support WHERE '.$where.$topics_sql
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
   'SELECT '.$columns.' FROM '.config->{db_table_prefix}.'_support WHERE '.$where.$topics_sql.$sortorder.' LIMIT '.$iDisplayStart.', '.$iDisplayLength
  );
  if ($sth->execute()) {
   while(my (@ary) = $sth -> fetchrow_array) {
    $ary[3] = time2str($lang->{date_time_template}, $ary[3]);
    $ary[3] =~ s/\\//gm;
    if ($topics_hash{$ary[1]}) {
      $ary[1] = $topics_hash{$ary[1]};
    }
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
  my $page_data = &taracot::_load_settings('support_topics', $_current_lang);
  my %topics_hash;
  foreach my $item(split(/;/, $page_data->{support_topics})) {
    my ($tid,$tv) = split(/,/, $item);
    $tid =~ s/^\s+//;
    $tid =~ s/\s+$//;
    $tv =~ s/^\s+//;
    $tv =~ s/\s+$//;
    $topics_hash{$tid} = $tv;
  }
  $ticket->{status} = 1;
  $ticket->{stopic_id} = $topics_hash{$ticket->{stopic_id}};
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
  database->quick_update(config->{db_table_prefix}.'_support', { id => $tid }, { unread => 0, lastmodified => time });
  my $json_xs = JSON::XS->new();
  return $json_xs->encode($ticket);
};

post '/ticket/specialist/load' => sub {
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
  if (!$ticket) {
    return '{"status":"0"}';
  } 
  my $page_data = &taracot::_load_settings('support_topics', $_current_lang);
  my @topics;
  my %topics_hash;
  foreach my $item(split(/;/, $page_data->{support_topics})) {
    my ($tid,$tv) = split(/,/, $item);
    $tid =~ s/^\s+//;
    $tid =~ s/\s+$//;
    $tv =~ s/^\s+//;
    $tv =~ s/\s+$//;
    push @topics, $tid;
    $topics_hash{$tid} = $tv;
  }
  my $allow = undef;
  $allow = 1 if ($auth->{status} eq 2);
  $allow = 1 if ($auth->{groups_hash}->{'support_specialist'});
  if ($auth->{groups_hash}->{'support_specialist_'.$ticket->{stopic_id}}) { 
    $allow = 1;
  }
  if (!$allow) {
    return '{"status":"0"}'; 
  }
  $ticket->{stopic_id} = $topics_hash{$ticket->{stopic_id}};
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
    $ans_html = decode_utf8($jevix->process(\encode_utf8($ans))->{text});
  } 
  if (length($ans_html) > 102400 || !$ans_html) {
    return '{"status":"0"}'; 
  }
  my $ans_html_hash = md5_hex(encode_utf8($ans_html));
  my $ahc = database->quick_select(config->{db_table_prefix}.'_support_ans', { smsg_hash => $ans_html_hash, tid => $tid });
  if ($ahc) {
    return '{"status":"-1"}';
  }
  my $status = $ticket->{sstatus};
  if ($status eq 2) {
    $status = 1;
  }
  database->quick_insert(config->{db_table_prefix}.'_support_ans', { susername => $auth->{username}, tid => $tid, sdate => time, smsg => $ans_html, smsg_hash => $ans_html_hash }); 
  database->quick_update(config->{db_table_prefix}.'_support', { id => $tid }, { susername_last => $auth->{username}, sdate => time, sstatus => $status, lastmodified => time });  
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
  my $page_data = &taracot::_load_settings('site_title,support_topics,support_mail', $_current_lang);
  my $mail_list = '';
  if ($page_data->{support_mail}) {    
    if ($page_data->{support_mail} !~ /\=/) {
      $mail_list = $page_data->{support_mail};
    } else {
      #$page_data->{support_mail}=~s/ //gm;
      my @arr = split(/;/, $page_data->{support_mail});
      foreach my $item(@arr) {
        my ($gr,$ms) = split(/\=/, $item);
        if ($gr eq $ticket->{stopic_id}) {
          $mail_list = $ms;
        }
        if ($gr eq "all") {
          $mail_list .= ', '.$ms; 
        }
      }
      $mail_list=~s/^, //;      
    }
    if ($mail_list) {
      my $support_url = request->uri_base().'/support/specialist';
      my $body = template 'support_mail_notify_support_'.$_current_lang, { site_title => encode_entities_numeric($page_data->{site_title}), support_url => $support_url, site_logo_url => request->uri_base().config->{site_logo_url} }, { layout => undef };
      email {
          to      => $mail_list,
          subject => $lang->{email_subj_user_notify}.' '.$page_data->{site_title},
          body    => $body,
          type    => 'html',
          headers => { "X-Accept-Language" => $_current_lang }
      };
    }
  }
  return $json_xs->encode(\%res);
};

post '/answer/specialist/save' => sub {
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
  if (!$ticket) { 
    return '{"status":"0"}'; 
  }
  my $page_data = &taracot::_load_settings('site_title,support_topics', $_current_lang);
  my %topics_hash;
  foreach my $item(split(/;/, $page_data->{support_topics})) {
    my ($tid,$tv) = split(/,/, $item);
    $tid =~ s/^\s+//;
    $tid =~ s/\s+$//;
    $tv =~ s/^\s+//;
    $tv =~ s/\s+$//;
    $topics_hash{$tid} = $tv;
  }
  my $allow = undef;
  $allow = 1 if ($auth->{status} eq 2);
  $allow = 1 if ($auth->{groups_hash}->{'support_specialist'});
  if ($auth->{groups_hash}->{'support_specialist_'.$ticket->{stopic_id}}) { 
    $allow = 1;
  }
  if (!$allow) {
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
    $ans_html = decode_utf8($jevix->process(\encode_utf8($ans))->{text});
  }  
  if (length($ans_html) > 102400 || !$ans_html) {
    return '{"status":"0"}'; 
  }
  my $ans_html_hash = md5_hex(encode_utf8($ans_html));
  my $ahc = database->quick_select(config->{db_table_prefix}.'_support_ans', { smsg_hash => $ans_html_hash, tid => $tid });
  if ($ahc) {
    return '{"status":"-1"}';
  }
  my $status = $ticket->{sstatus};
  if ($status eq 0) {
    $status = 1;
  }
  database->quick_insert(config->{db_table_prefix}.'_support_ans', { susername => $auth->{username}, tid => $tid, sdate => time, smsg => $ans_html, smsg_hash => $ans_html_hash }); 
  database->quick_update(config->{db_table_prefix}.'_support', { id => $tid }, { susername_last => $auth->{username}, sdate => time, sstatus => $status, unread => 1, lastmodified => time });  
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
  my $user = database->quick_select(config->{db_table_prefix}.'_users', { username => $ticket->{susername} });
  if ($user->{email}) {
    my $support_url = request->uri_base().'/support';
    my $body = template 'support_mail_notify_user_'.$_current_lang, { site_title => encode_entities_numeric($page_data->{site_title}), support_url => $support_url, site_logo_url => request->uri_base().config->{site_logo_url} }, { layout => undef };
    email {
        to      => $user->{email},
        subject => $lang->{email_subj_user_notify}.': '.$page_data->{site_title},
        body    => $body,
        type    => 'html',
        headers => { "X-Accept-Language" => $_current_lang }
    };
  }
  return $json_xs->encode(\%res);
};

post '/answer/specialist/solved' => sub {
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
  if (!$ticket) { 
    return '{"status":"0"}'; 
  }
  my $page_data = &taracot::_load_settings('site_title,support_topics', $_current_lang);
  my %topics_hash;
  foreach my $item(split(/;/, $page_data->{support_topics})) {
    my ($tid,$tv) = split(/,/, $item);
    $tid =~ s/^\s+//;
    $tid =~ s/\s+$//;
    $tv =~ s/^\s+//;
    $tv =~ s/\s+$//;
    $topics_hash{$tid} = $tv;
  }
  my $allow = undef;
  $allow = 1 if ($auth->{status} eq 2);
  $allow = 1 if ($auth->{groups_hash}->{'support_specialist'});
  if ($auth->{groups_hash}->{'support_specialist_'.$ticket->{stopic_id}}) { 
    $allow = 1;
  }
  if (!$allow) {
    return '{"status":"0"}'; 
  }
  database->quick_insert(config->{db_table_prefix}.'_support_ans', { susername => $auth->{username}, tid => $tid, sdate => time, smsg => $lang->{ticked_solved}, smsg_hash => '' }); 
  database->quick_update(config->{db_table_prefix}.'_support', { id => $tid }, { susername_last => $auth->{username}, sdate => time, sstatus => 2, unread => 0, lastmodified => time });  
  my $user = database->quick_select(config->{db_table_prefix}.'_users', { username => $ticket->{susername} });
  if ($user->{email}) {
    my $support_url = request->uri_base().'/support';
    my $body = template 'support_mail_notify_user_'.$_current_lang, { site_title => encode_entities_numeric($page_data->{site_title}), support_url => $support_url, site_logo_url => request->uri_base().config->{site_logo_url} }, { layout => undef };
    email {
        to      => $user->{email},
        subject => $lang->{email_subj_user_notify}.': '.$page_data->{site_title},
        body    => $body,
        type    => 'html',
        headers => { "X-Accept-Language" => $_current_lang }
    };
  }
  return '{"status":"1"}'; 
};

post '/ticket/save' => sub {
  my $auth = &taracot::_auth();
  if (!$auth) { 
    return '{"status":"0","errmsg":"'.$lang->{error_unauth_long}.'"}'; 
  }
  my $msg = param('msg');
  if (length($msg) > 102400 || !$msg) {
    return '{"status":"0","errmsg":"'.$lang->{invalid_ticket_msg}.'","field":"msg"}'; 
  }
  my $topic_id = param('ticket_topic_id');
  if (length($topic_id) > 250 || !$topic_id) {
    return '{"status":"0","errmsg":"'.$lang->{invalid_ticket_topic_id}.'","field":"topic_id"}'; 
  }
  my $topic = param('ticket_topic');
  $topic =~ s/\</&lt;/gm;
  $topic =~ s/\>/&gt;/gm;
  $topic =~ s/\&/&amp;/gm;
  $topic =~ s/\"/&quot;/gm;
  $topic =~ s/^\s+//;
  $topic =~ s/\s+$//;
  if (length($topic) > 250 || !$topic) {
    return '{"status":"0","errmsg":"'.$lang->{invalid_ticket_topic}.'","field":"topic"}'; 
  }  
  my $_current_lang=_load_lang();  
  my $page_data = &taracot::_load_settings('site_title,support_topics,support_mail', $_current_lang);
  my $tidf = undef;
  foreach my $item(split(/;/, $page_data->{support_topics})) {
    my ($tid) = split(/,/, $item);
    $tid =~ s/^\s+//;
    $tid =~ s/\s+$//;
    if ($tid eq $topic_id) {
      $tidf = 1;
    }
  }
  if (!$tidf) {
    return '{"status":"0","errmsg":"'.$lang->{invalid_ticket_topic_id}.'","field":"topic_id"}'; 
  }
  my $aubbc = taracot::AUBBC->new();
  $msg =~ s/\</&lt;/gm;
  $msg =~ s/\>/&gt;/gm;
  my $msg_html = $aubbc->do_all_ubbc($msg);
  # Process typography
  if (langof($msg) eq 'ru') {
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
    $msg_html = decode_utf8($jevix->process(\encode_utf8($msg))->{text});
  }  
  if (length($msg_html) > 102400 || !$msg_html) {
    return '{"status":"0","errmsg":"'.$lang->{invalid_ticket_msg}.'","field":"msg"}'; 
  }
  my $msg_html_hash = md5_hex(encode_utf8($msg_html));
  my $ahc = database->quick_select(config->{db_table_prefix}.'_support', { smsg_hash => $msg_html_hash, susername => $auth->{username} });
  if ($ahc) {
    return '{"status":"0","errmsg":"'.$lang->{dupe_ticket_msg}.'","field":"msg"}';
  }
  database->quick_insert(config->{db_table_prefix}.'_support', { susername => $auth->{username}, sdate => time, smsg => $msg_html, smsg_hash => $msg_html_hash, stopic_id => $topic_id, stopic => $topic, unread => 0,  sstatus => 0, susername_last => $auth->{username} }); 
  my $mail_list = '';
  if ($page_data->{support_mail}) {    
    if ($page_data->{support_mail} !~ /\=/) {
      $mail_list = $page_data->{support_mail};
    } else {
      #$page_data->{support_mail}=~s/ //gm;
      my @arr = split(/;/, $page_data->{support_mail});
      foreach my $item(@arr) {
        my ($gr,$ms) = split(/\=/, $item);
        if ($gr eq $topic_id) {
          $mail_list = $ms;
        }
        if ($gr eq "all") {
          $mail_list .= ', '.$ms; 
        }
      }
      $mail_list=~s/^, //;      
    }
    if ($mail_list) {
      my $support_url = request->uri_base().'/support/specialist';
      my $body = template 'support_mail_notify_support_'.$_current_lang, { site_title => encode_entities_numeric($page_data->{site_title}), support_url => $support_url, site_logo_url => request->uri_base().config->{site_logo_url} }, { layout => undef };
      email {
          to      => $mail_list,
          subject => $lang->{email_subj_user_notify}.' '.$page_data->{site_title},
          body    => $body,
          type    => 'html',
          headers => { "X-Accept-Language" => $_current_lang }
      };
    }
  }
  return '{"status":"1"}';
};

# End

1;