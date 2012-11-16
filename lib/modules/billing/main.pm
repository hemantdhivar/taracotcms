package modules::billing::main;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use JSON::XS();
use Digest::MD5 qw(md5_hex);

# Configuration

my $defroute = '/admin/billing';
my @columns = ('u.id','u.username','u.realname', 'u.email','f.amount');
my @columns_mobile = ('u.id','u.username','f.amount');

# Module core settings 

my $lang;
prefix $defroute;

sub _name() {
 &_load_lang();
  return $lang->{module_name};
}           
sub _defroute() {
  return $defroute;
}
sub _load_lang {
  my $lng = &taracot::_detect_lang() || config->{lang_default};
  my $lang_adm = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/billing/lang/en.lng') || {};
  my $lang_adm_cnt={};
  if ($lng ne 'en') {
   $lang_adm_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/billing/lang/'.$lng.'.lng') || {};
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
  my $auth = &taracot::admin::_auth();
  if (!$auth) { redirect '/admin?'.md5_hex(time); return true }
  _load_lang();
  my $navdata=&taracot::admin::_navdata();
  return template 'admin_billing_index', { lang => $lang, navdata => $navdata, authdata => $auth }, { layout => 'admin' };
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
   $sSearch=database->quote('*'.$sSearch.'*');
   $where='(
    (MATCH (u.username) AGAINST ('.$sSearch.' IN BOOLEAN MODE)) OR 
    (MATCH (u.email) AGAINST ('.$sSearch.' IN BOOLEAN MODE)) OR 
    (MATCH (u.email) AGAINST ('.$sSearch.' IN BOOLEAN MODE)) OR 
    (MATCH (d.domain_name) AGAINST ('.$sSearch.' IN BOOLEAN MODE) AND d.user_id = u.id) OR 
    (MATCH (h.host_acc) AGAINST ('.$sSearch.' IN BOOLEAN MODE) AND h.user_id = u.id) OR 
    (MATCH (s.service_name) AGAINST ('.$sSearch.' IN BOOLEAN MODE) AND h.user_id = u.id))';   
  }
  my $total=0;
  my $sth = database->prepare(
   'SELECT COUNT(*) AS cnt FROM '.config->{db_table_prefix}.'_users WHERE 1'
  );
  if ($sth->execute()) {
   ($total) = $sth -> fetchrow_array;
  }
  $sth->finish();
  my $total_filtered=0;  
  if ($where ne '1' && $total > 0) {
   my $sth = database->prepare(    
    'SELECT COUNT(*) AS cnt FROM `'.config->{db_table_prefix}.'_users` u LEFT JOIN `'.config->{db_table_prefix}.'_billing_funds` f ON u.id=f.user_id LEFT JOIN `'.config->{db_table_prefix}.'_billing_hosting` h ON u.id=h.user_id LEFT JOIN `'.config->{db_table_prefix}.'_billing_domains` d ON u.id=d.user_id LEFT JOIN `'.config->{db_table_prefix}.'_billing_services` s ON u.id=s.user_id WHERE '.$where.' GROUP BY u.id'
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
   'SELECT '.$columns.' FROM `'.config->{db_table_prefix}.'_users` u LEFT JOIN `'.config->{db_table_prefix}.'_billing_funds` f ON u.id=f.user_id LEFT JOIN `'.config->{db_table_prefix}.'_billing_hosting` h ON u.id=h.user_id LEFT JOIN `'.config->{db_table_prefix}.'_billing_domains` d ON u.id=d.user_id LEFT JOIN `'.config->{db_table_prefix}.'_billing_services` s ON u.id=s.user_id WHERE '.$where.' GROUP BY u.id '.$sortorder.' LIMIT '.$iDisplayStart.', '.$iDisplayLength
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
};

post '/data/save' => sub {
  if (!&taracot::admin::_auth()) { redirect '/admin?'.md5_hex(time); return true }
  _load_lang();  
  content_type 'application/json';
  my $username=param('username') || '';
  my $password=param('password') || '';
  my $email=param('email') || '';
  my $phone=param('phone') || '';
  my $realname=param('realname') || '';
  my $status=param('status') || 0;
  $status=int($status);
  my $id=param('id') || 0;
  $id=int($id);
  
  if ($username !~ /^[A-Za-z0-9_\-]{1,100}$/) {
   return qq~{"result":"0","field":"username","error":"~.$lang->{form_error_invalid_username}.qq~"}~;
  }
  $username=lc $username;
  if (($id > 0 && length($password) > 0) || $id eq 0) {
    if ($password !~ /^[A-Za-z0-9_\-\$\!\@\#\%\^\&\[\]\{\}\*\+\=\.\,\'\"\|\<\>\?]{6,100}$/) {
     return qq~{"result":"0","field":"password","error":"~.$lang->{form_error_invalid_password}.qq~"}~;
    }
  }
  if ($email !~ /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/ || length($email) >80) {
   return qq~{"result":"0","field":"email","error":"~.$lang->{form_error_invalid_email}.qq~"}~;
  }
  $email=lc $email;
  $realname=~s/[\<\>\"\'\n\r\\\/]//gm;
    if ($realname !~ /^.{0,80}$/) {
   return qq~{"result":"0","field":"realname","error":"~.$lang->{form_error_invalid_realname}.qq~"}~;
  }
  if ($status < 0 || $status > 2) {
   return qq~{"result":"0","error":"~.$lang->{form_error_invalid_status}.qq~"}~;
  }
  $phone=~s/[^0-9]//gm;
  if (length($phone) > 40) {
   return qq~{"result":"0","error":"~.$lang->{form_error_invalid_phone}.qq~"}~; 
  }
  my $dupesql='';
  if ($id > 0) {
   $dupesql=' AND id != '.$id;
  }
  
  if ($taracot::admin::authdata->{username} eq $username && $taracot::admin::authdata->{status} eq 2) {
   $status=2;
  }
  
  my $sth = database->prepare(
   'SELECT id FROM '.config->{db_table_prefix}.'_billing WHERE username='.database->quote($username).$dupesql
  );
  if ($sth->execute()) {
   my ($tmpid) = $sth->fetchrow_array;
   if ($tmpid) {
    $sth->finish();
    return qq~{"result":"0","field":"username","error":"~.$lang->{form_error_duplicate_username}.qq~"}~;
   }
  }
  $sth->finish();
  
  $sth = database->prepare(
   'SELECT id FROM '.config->{db_table_prefix}.'_billing WHERE email='.database->quote($email).$dupesql
  );
  if ($sth->execute()) {
   my ($tmpid) = $sth->fetchrow_array;
   if ($tmpid) {
    $sth->finish();
    return qq~{"result":"0","field":"email","error":"~.$lang->{form_error_duplicate_email}.qq~"}~;
   } 
  }
  $sth->finish();
  
  if ($id > 0) {
   if ($password) {
    $password = md5_hex(config->{salt}.$password);
    database->quick_update(config->{db_table_prefix}.'_billing', { id => $id }, { username => $username, password => $password, email => $email, phone => $phone, realname => $realname, status => $status, lastchanged => time });
   } else {
    database->quick_update(config->{db_table_prefix}.'_billing', { id => $id }, { username => $username, email => $email, phone => $phone, realname => $realname, status => $status, lastchanged => time });
   }
  } else {   
   database->quick_insert(config->{db_table_prefix}.'_billing', { username => $username, password => $password, email => $email, phone => $phone, realname => $realname, status => $status, lastchanged => time });
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
  
  if ($field_name ne 'username' && $field_name ne 'realname' && $field_name ne 'email' && $field_name ne 'status' && $field_name ne 'phone' ) {
   return '{"result":"0", "error":"'.$lang->{field_edit_error_unknown}.'"}'; 
  }
  
  # Check username
  
  if ($field_name eq 'username') {
   my $username=$field_value;
   if ($username !~ /^[A-Za-z0-9_\-]{1,100}$/) {
    return qq~{"result":"0","error":"~.$lang->{form_error_invalid_username}.qq~"}~;
   }
   $username=lc $username;
   my $sth = database->prepare(
    'SELECT id FROM '.config->{db_table_prefix}.'_billing WHERE username='.database->quote($username).' AND id != '.$field_id
   );
   if ($sth->execute()) {
    my ($tmpid) = $sth->fetchrow_array;
    if ($tmpid) {
     $sth->finish();
     return qq~{"result":"0","error":"~.$lang->{form_error_duplicate_username}.qq~"}~;
    }
   }
   $sth->finish();
   database->quick_update(config->{db_table_prefix}.'_billing', { id => $field_id }, { username => $username, lastchanged => time });
   return qq~{"result":"1"}~;
  }
  
  # Check e-mail
  
  if ($field_name eq 'email') {
   my $email=$field_value;
   if ($email !~ /^[A-Za-z0-9_\-\$\!\@\#\%\^\&\[\]\{\}\*\+\=\.\,\'\"\|\<\>\?]{6,100}$/ || length($email) > 80) {
    return qq~{"result":"0","error":"~.$lang->{form_error_invalid_email}.qq~"}~;
   }
   $email=lc $email;
   my $sth = database->prepare(
    'SELECT id FROM '.config->{db_table_prefix}.'_billing WHERE email='.database->quote($email).' AND id != '.$field_id
   );
   if ($sth->execute()) {
    my ($tmpid) = $sth->fetchrow_array;
    if ($tmpid) {
     $sth->finish();
     return qq~{"result":"0","error":"~.$lang->{form_error_duplicate_email}.qq~"}~;
    }
   }
   $sth->finish();
   database->quick_update(config->{db_table_prefix}.'_billing', { id => $field_id }, { email => $email, lastchanged => time });
   return qq~{"result":"1"}~;
  }
  
  # Check realname
  
  if ($field_name eq 'realname') {
   my $realname=$field_value;
   $realname=~s/[\<\>\"\'\n\r\\\/]//gm;
   if ($realname !~ /^.{0,80}$/) {
    return qq~{"result":"0","error":"~.$lang->{form_error_invalid_realname}.qq~"}~;
   }
   database->quick_update(config->{db_table_prefix}.'_billing', { id => $field_id }, { realname => $realname, lastchanged => time });
   return qq~{"result":"1"}~;
  }

  # Check phone
  
  if ($field_name eq 'phone') {
   my $phone=$field_value;
   $phone=~s/[^0-9]//gm;
   if (length($phone) > 40) {
    return qq~{"result":"0","error":"~.$lang->{form_error_invalid_phone}.qq~"}~;
   }
   database->quick_update(config->{db_table_prefix}.'_billing', { id => $field_id }, { phone => $phone, lastchanged => time });
   return qq~{"result":"1"}~;
  }
  
  # Check status
  
  if ($field_name eq 'status') {
   my $status=int($field_value);
   if ($status < 0 || $status > 2) {
    return qq~{"result":"0","error":"~.$lang->{form_error_invalid_status}.qq~"}~;
   }
   if ($taracot::admin::authdata->{id} eq $field_id && $taracot::admin::authdata->{status} eq 2) {
    return qq~{"result":"0","error":"~.$lang->{form_error_invalid_status}.qq~"}~;
   }
   database->quick_update(config->{db_table_prefix}.'_billing', { id => $field_id }, { status => $status, lastchanged => time });
   return '{"result":"1"}';
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
  
  my $db_data  = database->quick_select(config->{db_table_prefix}.'_billing', { id => $id });
  
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
    if ($item ne $$taracot::admin::authdata->{id}) {
     $del_sql.=' OR id='.$item;
    }
   }
   if ($del_sql) {
    $del_sql=~s/ OR //;
   }
  } else {
    if ($id ne $taracot::admin::authdata->{id}) {
     $del_sql='id='.int($id);
    }
  }
  if ($del_sql) {
    my $sth = database->prepare(
     'DELETE FROM '.config->{db_table_prefix}.'_billing WHERE '.$del_sql
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

# End

true;