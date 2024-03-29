package modules::users::main;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use Time::HiRes qw ( time );
use JSON::XS();
use Digest::MD5 qw(md5_hex);
use Date::Format;
use Fcntl qw(:flock SEEK_END);

# Configuration

my $defroute = '/admin/users';
my @columns = ('id','username','realname','email','phone','status');
my @columns_mobile = ('id','username','status');
my @columns_ft = ('username','realname','email','phone');

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
  my $dl = &taracot::_detect_lang();
  my $lng = $dl->{lng} || config->{lang_default};
  my $lang_adm = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/users/lang/en.lng') || {};
  my $lang_adm_cnt={};
  if ($lng ne 'en') {
   $lang_adm_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/users/lang/'.$lng.'.lng') || {};
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
  return template 'admin_users_index', { lang => $lang, navdata => $navdata, authdata => $auth }, { layout => 'admin' };
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
   'SELECT COUNT(*) AS cnt FROM '.config->{db_table_prefix}.'_users WHERE 1'
  );
  if ($sth->execute()) {
   ($total) = $sth -> fetchrow_array;
  }
  $sth->finish();
  my $total_filtered=0;
  if ($where ne '1' && $total > 0) {
   my $sth = database->prepare(
    'SELECT COUNT(*) AS cnt FROM '.config->{db_table_prefix}.'_users WHERE '.$where
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
   'SELECT '.$columns.' FROM '.config->{db_table_prefix}.'_users WHERE '.$where.$sortorder.' LIMIT '.$iDisplayStart.', '.$iDisplayLength
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
  my $auth = &taracot::admin::_auth();
  if (!$auth) { redirect '/admin?'.md5_hex(time); return true }
  _load_lang();  
  content_type 'application/json';
  my $username=param('username') || '';
  my $password=param('password') || '';
  my $email=param('email') || '';
  my $phone=param('phone') || '';
  my $realname=param('realname') || '';
  my $groups=param('groups') || '';
  my $status=param('status') || 0;
  my $banned=param('banned');
  my $sex=param('sex') || 0;
  if ($sex) {
    $sex = 1;
  }
  if ($banned eq 'false') {
    $banned = 0;
  } else {
    $banned = time + 259200; # 72 hours
  }
  $status=int($status);
  my $id=param('id') || 0;
  $id=int($id);
  if ($id<0) { $id = 0; }  
  if ($username !~ /^[A-Za-z0-9_\-\.]{1,100}$/) {
   return qq~{"result":"0","field":"username","error":"~.$lang->{form_error_invalid_username}.qq~"}~;
  }
  $username=lc $username;
  if ($groups && $groups !~ /^[A-Za-z0-9_\-\.\, ]{1,255}$/) {
   return qq~{"result":"0","groups":"username","error":"~.$lang->{form_error_invalid_groups}.qq~"}~;
  }  
  if (($id > 0 && length($password) > 0) || $id eq 0) {
    if ($password !~ /^[A-Za-z0-9_\-\$\!\@\#\%\^\&\[\]\{\}\*\+\=\.\,\'\"\|\<\>\?]{6,100}$/) {
     return qq~{"result":"0","field":"password","error":"~.$lang->{form_error_invalid_password}.qq~"}~;
    }
  }
  if ($email && ($email !~ /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/ || length($email) >80)) {
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
  if ($auth->{id} eq $id && $auth->{status} eq 2) {
   $status=2;
  }  
  my $sth = database->prepare(
   'SELECT id FROM '.config->{db_table_prefix}.'_users WHERE username='.database->quote($username).$dupesql
  );
  if ($sth->execute()) {
   my ($tmpid) = $sth->fetchrow_array;
   if ($tmpid) {
    $sth->finish();
    return qq~{"result":"0","field":"username","error":"~.$lang->{form_error_duplicate_username}.qq~"}~;
   }
  }
  $sth->finish();

  if ($email) {  
    $sth = database->prepare(
     'SELECT id FROM '.config->{db_table_prefix}.'_users WHERE email='.database->quote($email).$dupesql
    );
    if ($sth->execute()) {
     my ($tmpid) = $sth->fetchrow_array;
     if ($tmpid) {
      $sth->finish();
      return qq~{"result":"0","field":"email","error":"~.$lang->{form_error_duplicate_email}.qq~"}~;
     } 
    }
    $sth->finish();
  }
  
  if ($id > 0) {
   my $dbd  = database->quick_select(config->{db_table_prefix}.'_users', { id => $id }); 
   if ($dbd->{banned} && $banned) {
    $banned = $dbd->{banned};
   }
   if ($password) {    
    $password = md5_hex(config->{salt}.$password);
    database->quick_update(config->{db_table_prefix}.'_users', { id => $id }, { username => $username, groups => $groups, password => $password, email => $email, phone => $phone, realname => $realname, sex => $sex, status => $status, banned => $banned, lastchanged => time });
   } else {
    database->quick_update(config->{db_table_prefix}.'_users', { id => $id }, { username => $username, groups => $groups, email => $email, phone => $phone, realname => $realname, sex => $sex, status => $status, banned => $banned, lastchanged => time });
   }
  } else {   
    $password = md5_hex(config->{salt}.$password);
   database->quick_insert(config->{db_table_prefix}.'_users', { username => $username, groups => $groups, password => $password, email => $email, phone => $phone, realname => $realname, sex => $sex, status => $status, banned => $banned, lastchanged => time });
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
   if ($username !~ /^[A-Za-z0-9_\-\.]{1,100}$/) {
    return qq~{"result":"0","error":"~.$lang->{form_error_invalid_username}.qq~"}~;
   }
   $username=lc $username;
   my $sth = database->prepare(
    'SELECT id FROM '.config->{db_table_prefix}.'_users WHERE username='.database->quote($username).' AND id != '.$field_id
   );
   if ($sth->execute()) {
    my ($tmpid) = $sth->fetchrow_array;
    if ($tmpid) {
     $sth->finish();
     return qq~{"result":"0","error":"~.$lang->{form_error_duplicate_username}.qq~"}~;
    }
   }
   $sth->finish();
   database->quick_update(config->{db_table_prefix}.'_users', { id => $field_id }, { username => $username, lastchanged => time });
   return qq~{"result":"1"}~;
  }
  
  # Check e-mail
  
  if ($field_name eq 'email') {
   my $email=$field_value;
   if ($email && ($email !~ /^[A-Za-z0-9_\-\$\!\@\#\%\^\&\[\]\{\}\*\+\=\.\,\'\"\|\<\>\?]{6,100}$/ || length($email) > 80)) {
    return qq~{"result":"0","error":"~.$lang->{form_error_invalid_email}.qq~"}~;
   }
   if ($email) {
     $email=lc $email;
     my $sth = database->prepare(
      'SELECT id FROM '.config->{db_table_prefix}.'_users WHERE email='.database->quote($email).' AND id != '.$field_id
     );
     if ($sth->execute()) {
      my ($tmpid) = $sth->fetchrow_array;
      if ($tmpid) {
       $sth->finish();
       return qq~{"result":"0","error":"~.$lang->{form_error_duplicate_email}.qq~"}~;
      }
     }
     $sth->finish();
   }
   database->quick_update(config->{db_table_prefix}.'_users', { id => $field_id }, { email => $email, lastchanged => time });
   return qq~{"result":"1"}~;
  }
  
  # Check realname
  
  if ($field_name eq 'realname') {
   my $realname=$field_value;
   $realname=~s/[\<\>\"\'\n\r\\\/]//gm;
   if ($realname !~ /^.{0,80}$/) {
    return qq~{"result":"0","error":"~.$lang->{form_error_invalid_realname}.qq~"}~;
   }
   database->quick_update(config->{db_table_prefix}.'_users', { id => $field_id }, { realname => $realname, lastchanged => time });
   return qq~{"result":"1"}~;
  }

  # Check phone
  
  if ($field_name eq 'phone') {
   my $phone=$field_value;
   $phone=~s/[^0-9]//gm;
   if (length($phone) > 40) {
    return qq~{"result":"0","error":"~.$lang->{form_error_invalid_phone}.qq~"}~;
   }
   database->quick_update(config->{db_table_prefix}.'_users', { id => $field_id }, { phone => $phone, lastchanged => time });
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
   database->quick_update(config->{db_table_prefix}.'_users', { id => $field_id }, { status => $status, lastchanged => time });
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
  
  my $db_data  = database->quick_select(config->{db_table_prefix}.'_users', { id => $id });
  
  if ($db_data->{id}) {
   $db_data->{result} = 1;
   $db_data->{password} = 0;
   if ($db_data->{banned}) {
    $db_data->{banned} = time2str($lang->{datetime_template}, $db_data->{banned});    
    $db_data->{banned} =~ s/\\//gm; 
   }
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
  my @pid;
  if(ref($id) eq 'ARRAY'){
   foreach my $item (@$id) {
    $item=int($item);
    if ($item ne $taracot::admin::authdata->{id}) {
     $del_sql.=' OR id='.$item;
     push @pid, $item;
    }
   }
   if ($del_sql) {
    $del_sql=~s/ OR //;
   }
  } else {
    if ($id ne $taracot::admin::authdata->{id}) {
     $del_sql='id='.int($id);
     push @pid, $id;
    }
  }
  if ($del_sql) {
    opendir(SD, config->{root_dir}.'/lib/modules/users/sql') || die $1;
    while (my $file = readdir(SD)) {
     next if ($file =~ m/^\./);
     if ($file =~ /^delete_/) {
      my $data = YAML::XS::LoadFile(config->{root_dir}.'/lib/modules/users/sql/'.$file) || {};      
      foreach my $pi (@pid) {
        foreach my $sq (@{$data}) {
          my $query = $sq->{query};
          $query =~s /\[id\]/$pi/gm;
          my $prefix = config->{db_table_prefix};
          $query =~s /\[prefix\]/$prefix/gm;
          my $sth = database->prepare( $query );
          $sth->execute();
          $sth->finish();
          open(DATA, '>>C:/XTreme/log.txt');
          print DATA "$query\n";
          close(DATA);
        }
      }
     }
    }
    closedir(SD);
    my $sth = database->prepare(
     'DELETE FROM '.config->{db_table_prefix}.'_users WHERE '.$del_sql
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