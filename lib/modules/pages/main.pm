package modules::pages::main;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use JSON::XS();
use Digest::MD5 qw(md5_hex);
use taracot::loadpm;
use Text::Unidecode;

# Configuration

my $defroute = '/admin/pages';
my @columns = ('id','pagetitle','filename','lang','layout','status');
my @columns_mobile = ('id','pagetitle','lang','status');
my @columns_ft = ('pagetitle','filename');

# Module core settings 

my $lang;

sub _name() {
  _load_lang();
  return $lang->{module_name};
}           
sub _defroute() {
  return $defroute;
}

sub _load_lang {
  my $lng = &taracot::_detect_lang() || config->{lang_default};
  my $lang_adm = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/pages/lang/en.lng') || {};
  my $lang_adm_cnt={};
  if ($lng ne 'en') {
   $lang_adm_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/pages/lang/'.$lng.'.lng') || {};
  }
  my $lang_mod = YAML::XS::LoadFile(config->{root_dir}.'lib/taracot/lang/en.lng') || {};
  my $lang_mod_cnt={};
  if ($lng ne 'en') {
   $lang_mod_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/taracot/lang/'.$lng.'.lng') || {};
  }
  $lang = { %$lang_adm, %$lang_mod, %$lang_adm_cnt, %$lang_mod_cnt };
  return $lng;
}

# Frontend Routes

prefix '/';

get qr{(.*)} => sub {
  my $_current_lang=_load_lang();
  my $auth_data;
  if (session('user')) { 
   my $id = session('user');
   $auth_data  = database->quick_select(config->{db_table_prefix}."_users", { id => $id });
  } else {
   $auth_data->{id} = 0;
   $auth_data->{status} = 0;
   $auth_data->{username} = '';
   $auth_data->{password} = '';
  } 
  my ($url) = splat;
  # remove dupe chars
  $url=~s/(\/)\1+/$1/gi;
  # remove slash at the end
  $url = $1 if ($url=~/(.*)\/$/);
  # remove slash at the beginning
  $url = $1 if ($url=~/^\/(.*)/);
  if (!$url) { 
   $url='/'; 
  }
  if ($url !~ /^[A-Za-z0-9_\-\/]{0,254}$/) {
   pass();
  }
  my $db_data  = database->quick_select(config->{db_table_prefix}.'_pages', { filename => $url, lang => $_current_lang });
  my $page_data = &taracot::_load_settings('site_title,site_keywords,site_description', $_current_lang);  
  my $page_keywords = $db_data->{keywords}.', '.$page_data->{site_keywords};
  my $page_description = $db_data->{description}.'. '.$page_data->{site_description};
  $page_keywords=~s/^, //;
  $page_description=~s/^\. //;
  $page_keywords=~s/, $//;
  $page_description=~s/\. $//;
  $page_data->{site_keywords}=$page_keywords;
  $page_data->{site_description}=$page_description;
  if (defined $db_data && $db_data->{id}) {
   my $render_template;
   if ($db_data->{status} eq 1) {
    $render_template = &taracot::_process_template( template 'pages_view', { current_lang => $_current_lang, lang => $lang, auth_data => $auth_data, pagetitle => $db_data->{pagetitle}, page_data => $page_data, db_data => $db_data }, { layout => $db_data->{layout}.'_'.$db_data->{lang} } );
   }
   if ($db_data->{status} eq 0) {
    $render_template = &taracot::_process_template( template 'pages_status', { current_lang => $_current_lang, lang => $lang, auth_data => $auth_data, pagetitle => $db_data->{pagetitle}, page_data => $page_data, db_data => $db_data, status_icon => "disabled_32.png", status_header => $lang->{disabled_header}, status_text => $lang->{disabled_text} }, { layout => $db_data->{layout}.'_'.$db_data->{lang} } );
   }
   if ($db_data->{status} eq 2) {
    $render_template = &taracot::_process_template( template 'pages_status', { current_lang => $_current_lang, lang => $lang, auth_data => $auth_data, pagetitle => $db_data->{pagetitle}, page_data => $page_data, db_data => $db_data, status_icon => "under_construction_32.png", status_header => $lang->{construction_header}, status_text => $lang->{construction_text} }, { layout => $db_data->{layout}.'_'.$db_data->{lang} } );
   }
   if ($render_template) {
    return $render_template;
   }
  }
  pass();
};

# Backend Routes

prefix $defroute;

get '/' => sub {
  my $auth = &taracot::admin::_auth();
  if (!$auth) { redirect '/admin?'.md5_hex(time); return true }
  my $_current_lang=_load_lang();
  my $navdata=&taracot::admin::_navdata();
  my $layouts=config->{layouts_available};
  $layouts=~s/ //gm;
  my @a_layouts=split(/,/, $layouts);
  my $list_layouts;
  foreach my $item (@a_layouts) {
   $list_layouts.=qq~<option value="$item">$item</option>~;
  }
  my $langs=config->{lang_available};
  $langs=~s/ //gm;
  my @a_langs=split(/,/, $langs);
  my $langs_long=config->{lang_available_long};
  $langs_long=~s/ //gm;
  my @a_langs_long=split(/,/, $langs_long);
  my $list_langs;
  my $_cnt;
  my $hash_langs;
  # one: 1, two: 2, three: 3, "i'm no 4": 4
  foreach my $item (@a_langs) {
   $list_langs.=qq~<option value="$item">$a_langs_long[$_cnt]</option>~;
   $hash_langs.=qq~, $item: "$a_langs_long[$_cnt]"~;
   $_cnt++;
  }
  $hash_langs=~s/, //;
  return template 'admin_pages_index', { current_lang => $_current_lang, default_lang => config->{lang_default}, lang => $lang, navdata => $navdata, authdata => $auth, list_layouts => $list_layouts, list_langs => $list_langs, hash_langs => $hash_langs }, { layout => 'admin' };
  
};

get '/data/list' => sub {
  if (!&taracot::admin::_auth()) { redirect '/admin?'.md5_hex(time); return true }
  _load_lang();
  content_type 'application/json';
  my $sEcho = param('sEcho') || 0;
  $sEcho=int($sEcho);
  my $iDisplayStart = param('iDisplayStart') || 0;
  $iDisplayStart=int($iDisplayStart);
  my $iDisplayLength = param('iDisplayLength') || 0;
  $iDisplayLength=int($iDisplayLength);
  my $iColumns = param('iColumns') || @columns;
  $iColumns=int($iColumns);
  my $sSearch = param('sSearch') || '';
  $sSearch=~s/^\s+//;
  $sSearch=~s/\s+$//;
  my $iSortingCols = param('iSortingCols') || 0;
  $iSortingCols=int($iSortingCols);
  my $iSortCol_0 = param('iSortCol_0') || 0;
  $iSortCol_0=int($iSortCol_0);
  my $sSortCol = $columns[$iSortCol_0] || 'id';
  my $sSortDir = param('sSortDir_0') || '';
  if ($sSortDir ne "asc" && $sSortDir ne "desc") {
   $sSortDir="asc";
  }
  my $where='1';
  if (length($sSearch) > 2 && length($sSearch) < 250) {
   $where='';
   $sSearch=database->quote('*'.$sSearch.'*');
   foreach my $item(@columns_ft) {
    $where.=' OR MATCH ('.$item.') AGAINST ('.$sSearch.' IN BOOLEAN MODE)';
   }
   $where=~s/ OR//;
   $where='('.$where.')';
  }
  my $total=0;
  my $sth = database->prepare(
   'SELECT COUNT(*) AS cnt FROM '.config->{db_table_prefix}.'_pages WHERE 1'
  );
  if ($sth->execute()) {
   ($total) = $sth -> fetchrow_array;
  }
  $sth->finish();
  my $total_filtered=0;
  if ($where ne '1' && $total > 0) {
   my $sth = database->prepare(
    'SELECT COUNT(*) AS cnt FROM '.config->{db_table_prefix}.'_pages WHERE '.$where
   );
   if ($sth->execute()) {
    ($total_filtered) = $sth -> fetchrow_array;
   }
   $sth->finish();
  } else {
   $total_filtered=$total;
  }
  my $sortorder=' ';  
  my @data;
  if ($sSortCol) {
   $sortorder=" ORDER BY $sSortCol $sSortDir";
  }
  my $columns;
  if (param('mobile')) {
    $columns=join(',',@columns_mobile);
  } else {
    $columns=join(',',@columns);
  }
  $columns=~s/,$//;
  $sth = database->prepare(
   'SELECT '.$columns.' FROM '.config->{db_table_prefix}.'_pages WHERE '.$where.$sortorder.' LIMIT '.$iDisplayStart.', '.$iDisplayLength
  );
  if ($sth->execute()) {
   while(my (@ary) = $sth -> fetchrow_array) {
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
   # End: return JSON data

};

post '/data/save' => sub {
  if (!&taracot::admin::_auth()) { redirect '/admin?'.md5_hex(time); return true }
  _load_lang();
  content_type 'application/json';
  my $pagetitle=param('pagetitle') || '';
  my $filename=param('filename') || '';
  my $keywords=param('keywords') || '';
  my $description=param('description') || '';
  my $content=param('content') || '';
  my $status=param('status') || 0;
  my $plang=param('lang') || '';
  my $layout=param('layout') || '';
  $status=int($status);
  my $id=param('id') || 0;
  $id=int($id);
  
  $pagetitle=~s/[\n\r]//gm;
  $pagetitle=~s/\"/&quot;/gm;
  $pagetitle=~s/\</&lt;/gm;
  $pagetitle=~s/\>/&gt;/gm;
  $pagetitle=~s/\&/&amp;/gm;
  if ($pagetitle !~ /^.{0,254}$/) {
   return qq~{"result":"0","field":"pagetitle","error":"~.$lang->{form_error_invalid_pagetitle}.qq~"}~;
  }
  if ($filename ne '/') {
   # remove dupe chars
   $filename=~s/(\/)\1+/$1/gi;
   # remove slash at the end
   $filename = $1 if ($filename=~/(.*)\/$/);
   # remove slash at the beginning
   $filename = $1 if ($filename=~/^\/(.*)/);
  }
  if ($filename !~ /^[A-Za-z0-9_\.\-\/]{1,254}$/) {
   return qq~{"result":"0","field":"filename","error":"~.$lang->{form_error_invalid_filename}.qq~"}~;
  }
  $keywords=~s/[\n\r]//gm;
  $keywords=~s/\"/&quot;/gm;
  $keywords=~s/\</&lt;/gm;
  $keywords=~s/\>/&gt;/gm;
  $keywords=~s/\&/&amp;/gm;
  if ($keywords !~ /^.{0,254}$/) {
   return qq~{"result":"0","field":"keywords","error":"~.$lang->{form_error_invalid_keywords}.qq~"}~;
  }
  $description=~s/[\n\r]//gm;
  $description=~s/\"/&quot;/gm;
  $description=~s/\</&lt;/gm;
  $description=~s/\>/&gt;/gm;
  $description=~s/\&/&amp;/gm;
  if ($description !~ /^.{0,254}$/) {
   return qq~{"result":"0","field":"description","error":"~.$lang->{form_error_invalid_description}.qq~"}~;
  }
  if ($status < 0 || $status > 2) {
   return qq~{"result":"0","error":"~.$lang->{form_error_invalid_status}.qq~"}~;
  }
  $content=~s/\0//gm;
  
  my $lang_avail=lc config->{lang_available};
  $lang_avail=~s/ //gm;
  my (@langs)=split(/,/, $lang_avail);
  if (!exists {map { $_ => 1 } @langs}->{$plang}) {
   return qq~{"result":"0","field":"lang","error":"~.$lang->{form_error_invalid_lang}.qq~"}~;
  }
  
  my $layouts_avail=lc config->{layouts_available};
  $layouts_avail=~s/ //gm;
  my (@layouts)=split(/,/, $layouts_avail);
  if (!exists {map { $_ => 1 } @layouts}->{$layout}) {
   return qq~{"result":"0","field":"layout","error":"~.$lang->{form_error_invalid_layout}.qq~"}~;
  }
  
  my $dupesql='';
  if ($id > 0) {
   $dupesql=' AND id != '.$id;
  }
  $dupesql.=' AND lang = '.database->quote($plang);
  
  my $sth = database->prepare(
   'SELECT id FROM '.config->{db_table_prefix}.'_pages WHERE filename='.database->quote($filename).$dupesql
  );
  if ($sth->execute()) {
   my ($tmpid) = $sth->fetchrow_array;
   if ($tmpid) {
    $sth->finish();
    return qq~{"result":"0","field":"filename","error":"~.$lang->{form_error_duplicate_filename}.qq~"}~;
   }
  }
  $sth->finish();
  
  if ($id > 0) {
   database->quick_update(config->{db_table_prefix}.'_pages', { id => $id }, { pagetitle => $pagetitle, filename => $filename, keywords => $keywords, description => $description, status => $status, content => $content, lang => $plang, layout => $layout, lastchanged => time });
  } else {   
   database->quick_insert(config->{db_table_prefix}.'_pages', { pagetitle => $pagetitle, filename => $filename, keywords => $keywords, description => $description, status => $status, content => $content, lang => $plang, layout => $layout, lastchanged => time });
  }
      
  return qq~{"result":"1"}~;
};

post '/data/save/field' => sub {
  if (!&taracot::admin::_auth()) { redirect '/admin?'.md5_hex(time); return true }
  _load_lang();
  content_type 'application/json';
  my $field_name=param('field_name') || '';
  my $field_id=param('field_id') || 0;
  $field_id=int($field_id);
  my $field_value=param('field_value') || '';

  # Pre-check all fields
  
  if ($field_name ne 'pagetitle' && $field_name ne 'filename' && $field_name ne 'lang' && $field_name ne 'layout' && $field_name ne 'status') {
   return '{"result":"0", "error":"'.$lang->{field_edit_error_unknown}.'"}'; 
  }
  
  # Check language
  
  if ($field_name eq 'lang') {
   my $lang_avail=lc config->{lang_available};
   $lang_avail=~s/ //gm;
   my (@langs)=split(/,/, $lang_avail);
   if (!exists {map { $_ => 1 } @langs}->{$field_value}) {
    return qq~{"result":"0","error":"~.$lang->{form_error_invalid_lang}.qq~"}~;
   }
   my $sth;
   my $filename;
   $sth = database->prepare(
    'SELECT filename FROM '.config->{db_table_prefix}.'_pages WHERE id = '.$field_id
   );
   if ($sth->execute()) {
    ($filename) = $sth->fetchrow_array;
   }
   $sth->finish();
   if (!$filename) {
    return qq~{"result":"0","error":"~.$lang->{field_edit_error_unknown}.qq~"}~;
   }
   $sth = database->prepare(
    'SELECT id FROM '.config->{db_table_prefix}.'_pages WHERE filename = '.database->quote($filename).' AND lang = '.database->quote($field_value)
   );
   if ($sth->execute()) {
    my ($tmpid) = $sth->fetchrow_array;
    if ($tmpid) {
     $sth->finish();
     return qq~{"result":"0","error":"~.$lang->{form_error_duplicate_filename}.qq~"}~;
    }
   }
   $sth->finish();
    database->quick_update(config->{db_table_prefix}.'_pages', { id => $field_id }, { lang => $field_value, lastchanged => time });
    return '{"result":"1"}';
   }
   
  # Check layout
  
  if ($field_name eq 'layout') {
   my $layout_avail=lc config->{layouts_available};
   $layout_avail=~s/ //gm;
   my (@layouts)=split(/,/, $layout_avail);
   if (!exists {map { $_ => 1 } @layouts}->{$field_value}) {
    return qq~{"result":"0","error":"~.$lang->{form_error_invalid_layout}.qq~"}~;
   }
   database->quick_update(config->{db_table_prefix}.'_pages', { id => $field_id }, { layout => $field_value, lastchanged => time });
   return '{"result":"1"}';
  } 
  
  # Check pagetitle
  
  if ($field_name eq 'pagetitle') {
   my $pagetitle=$field_value;
   if ($pagetitle !~ /^.{1,254}$/) {
    return qq~{"result":"0","error":"~.$lang->{form_error_invalid_pagetitle}.qq~"}~;
   }
   database->quick_update(config->{db_table_prefix}.'_pages', { id => $field_id }, { pagetitle => $pagetitle, lastchanged => time });
   return '{"result":"1"}';
  }
  
  # Check status
  
  if ($field_name eq 'status') {
   my $status=int($field_value);
   if ($status < 0 || $status > 2) {
    return qq~{"result":"0","error":"~.$lang->{form_error_invalid_status}.qq~"}~;
   }
   database->quick_update(config->{db_table_prefix}.'_pages', { id => $field_id }, { status => $status, lastchanged => time });
   return '{"result":"1"}';
  }
  
  # Check URL (filename)
  
  if ($field_name eq 'filename') {
   my $filename=$field_value;
   if ($filename ne '/') {
    # remove dupe chars
    $filename=~s/(\/)\1+/$1/gi;
    # remove slash at the end
    $filename = $1 if ($filename=~/(.*)\/$/);
    # remove slash at the beginning
    $filename = $1 if ($filename=~/^\/(.*)/);
   }
   if ($filename !~ /^[A-Za-z0-9_\.\-\/]{1,254}$/) {
    return qq~{"result":"0","field":"filename","error":"~.$lang->{form_error_invalid_filename}.qq~"}~;
   }
   
   my $page_data  = database->quick_select(config->{db_table_prefix}.'_pages', { id => $field_id });
   
   my $sth = database->prepare(
    'SELECT id FROM '.config->{db_table_prefix}.'_pages WHERE filename='.database->quote($filename).' AND id != '.$field_id.' AND lang='.database->quote($page_data->{lang})
   );
   if ($sth->execute()) {
    my ($tmpid) = $sth->fetchrow_array;
    if ($tmpid) {
     $sth->finish();
     return qq~{"result":"0","error":"~.$lang->{form_error_duplicate_filename}.qq~"}~;
    }
   }
   $sth->finish();
   database->quick_update(config->{db_table_prefix}.'_pages', { id => $field_id }, { filename => $filename, lastchanged => time });
   return '{"result":"1","value":"'.$filename.'"}';
  }
  
  return '{"result":"0", "error":"'.$lang->{field_edit_error_unknown}.'"}';
};

post '/data/load' => sub {
  if (!&taracot::admin::_auth()) { redirect '/admin?'.md5_hex(time); return true }
  _load_lang();
  content_type 'application/json';
  my $id=param('id') || 0;
  $id=int($id);
  
  if ($id <= 0) {
   return qq~{"result":"0"}~;
  }
  
  my $db_data  = database->quick_select(config->{db_table_prefix}.'_pages', { id => $id });
  
  if ($db_data->{id}) {
   $db_data->{result} = 1;
   $db_data->{password} = 0;
   my $json_xs = JSON::XS->new();
   my $json = $json_xs->encode($db_data);
   return $json;
  } else {
   return qq~{"result":"0"}~;
  }   
};  

post '/data/delete' => sub {
  if (!&taracot::admin::_auth()) { redirect '/admin?'.md5_hex(time); return true }
  _load_lang();
  content_type 'application/json';
  my $id=param('delete_data[]') || '';
  
  if (length($id) == 0) {
   return qq~{"result":"0"}~;
  }

  my $del_sql;
  if(ref($id) eq 'ARRAY'){
   foreach my $item (@$id) {
    $item=int($item);
    $del_sql.=' OR id='.$item;
   }
   if ($del_sql) {
    $del_sql=~s/ OR //;
   }
  } else {
    $del_sql='id='.int($id);
  }
  
  if ($del_sql) {
    my $sth = database->prepare(
     'DELETE FROM '.config->{db_table_prefix}.'_pages WHERE '.$del_sql
    );
    my $res;
    if ($sth->execute()) {
     $res=qq~{"result":"1"}~;
    } else {
     $res=qq~{"result":"0"}~;
    }
    $sth->finish();
    return $res;
  } else {
    return qq~{"result":"0"}~;
  }
};

post '/data/unidecode' => sub {
  if (!&taracot::admin::_auth()) { redirect '/admin?'.md5_hex(time); return true }
  content_type 'application/json';
  my $val=param('val');
  if (!$val || length($val)>2048) {
   return '{"result":"0"}';
  }
  $val=lc unidecode($val);
  $val=~s/ /_/gm;
  $val=~s/[^a-z0-9\-_\.\/]//gm;
  if ($val) {
   return '{"result":"1","data":"'.$val.'"}';
  }
  return '{"result":"0"}';
}; 

# End

true;