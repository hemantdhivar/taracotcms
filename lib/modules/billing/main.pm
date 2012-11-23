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

post '/data/load' => sub {
  if (!&taracot::admin::_auth()) { redirect '/admin?'.md5_hex(time); return true }
  my $current_lang = _load_lang();
  content_type 'application/json';
  my $id=param('id') || 0;
  $id=int($id);
  if ($id <= 0) {
   return qq~{"result":"0"}~;
  }
  my %response;
  my $sth = database->prepare(
    'SELECT username FROM `'.config->{db_table_prefix}.'_users` WHERE id='.$id
  );
  if ($sth->execute()) {
    my ($username) = $sth -> fetchrow_array();
    $response{username} = $username;
  }
  $sth->finish();
  if (!$response{username}) {
    return qq~{"result":"0"}~;
  }  
  my $avatar = '/images/default_avatar.png';
  if (-e config->{files_dir}.'/avatars/'.$response{username}.'.jpg') {
    $avatar = config->{files_url}.'/avatars/'.$response{username}.'.jpg';
  } 
  $response{avatar} = $avatar;
  # select funds amount
  $sth = database->prepare(
    'SELECT amount FROM `'.config->{db_table_prefix}.'_billing_funds` WHERE user_id='.$id
  );
  if ($sth->execute()) {
    my ($amount) = $sth -> fetchrow_array();
    $response{amount} = $amount;
  }
  $sth->finish();
  if (!$response{amount}) {
    $response{amount} = '0';
  }
  # load hosting plan names and IDs from settings
  my %hosting_plan_names;
  my @hosting_plan_ids;
  my $lang = database->quote($current_lang);
  $sth = database->prepare(
    'SELECT s_name, s_value FROM `'.config->{db_table_prefix}.'_settings` WHERE lang='.$lang.' AND MATCH (s_name) AGAINST (\'billing_plan_name_*\' IN BOOLEAN MODE)'
  );
  if ($sth->execute()) {
    while (my ($s_name, $s_value) = $sth -> fetchrow_array()) {
      $s_name=~s/^billing_plan_name_//;
      $hosting_plan_names{$s_name} = $s_value;
      push @hosting_plan_ids, $s_name;
    }
  }
  $sth->finish();
  # load hosting plan costs from settings
  my %hosting_plan_costs;
  $sth = database->prepare(
    'SELECT s_name, s_value FROM `'.config->{db_table_prefix}.'_settings` WHERE MATCH (s_name) AGAINST (\'billing_plan_cost_*\' IN BOOLEAN MODE)'
  );
  if ($sth->execute()) {
    while (my ($s_name, $s_value) = $sth -> fetchrow_array()) {
      $s_name=~s/^billing_plan_cost_//;
      $hosting_plan_costs{$s_name} = $s_value;
    }
  }
  $sth->finish();
  # generate hosting plan array
  my @hosting_plans;
  foreach my $pid (@hosting_plan_ids) {
   my %hosting_plan;
   $hosting_plan{id} = $pid;
   $hosting_plan{name} = $hosting_plan_names{$pid};
   $hosting_plan{cost} = $hosting_plan_costs{$pid};
   push @hosting_plans, \%hosting_plan;
  }
  $response{hosting_plans} = \@hosting_plans;
  # select hosting accounts
  $sth = database->prepare(
    'SELECT host_acc,host_plan_id,host_days_remain FROM `'.config->{db_table_prefix}.'_billing_hosting` WHERE user_id='.$id
  );
  if ($sth->execute()) {
    my @host_accounts;
    while (my ($host_acc,$host_plan_id,$host_days_remain) = $sth -> fetchrow_array()) {
      my %data;
      $data{account} = $host_acc;
      $data{plan_id} = $host_plan_id;
      $data{plan_cost} = $hosting_plan_costs{$host_plan_id} || '0';
      $data{plan_name} = $hosting_plan_names{$host_plan_id} || $host_plan_id;
      $data{days} = $host_days_remain;
      push (@host_accounts, \%data);
    }
    $response{hosting} = \@host_accounts;
  }
  $sth->finish();
  # return data
  my $json_xs = JSON::XS->new();
  my $json = $json_xs->encode(\%response);
  return $json;
};  

post '/data/hosting/save' => sub {
  my $auth = &taracot::admin::_auth();
  if (!$auth) { redirect '/admin?'.md5_hex(time); return true }
  _load_lang();  
  content_type 'application/json';
  my $haccount=param('haccount') || '';
  my $hplan=param('hplan') || '';
  my $hdays=param('hdays') || 0;
  my $id=param('id') || 0;
  $id=int($id);
  $hdays=int($hdays);
  $hplan=lc($hplan);
  $haccount=lc($haccount);
  if ($haccount !~ /^[A-Za-z0-9_\-]{1,100}$/) {
   return qq~{"result":"0","field":"haccount","error":"~.$lang->{form_error_invalid_haccount}.qq~"}~;
  }
  if ($hdays > 9999 || $hdays < -9999) {
   return qq~{"result":"0","field":"hdays","error":"~.$lang->{form_error_invalid_hdays}.qq~"}~;
  }  
  my $dupesql='';
  if ($id > 0) {
   $dupesql=' AND id != '.$id;
  }    
  my $sth = database->prepare(
   'SELECT id FROM '.config->{db_table_prefix}.'_billing_hosting WHERE host_acc='.database->quote($haccount).$dupesql
  );
  if ($sth->execute()) {
   my ($tmpid) = $sth->fetchrow_array;
   if ($tmpid) {
    $sth->finish();
    return qq~{"result":"0","field":"haccount","error":"~.$lang->{form_error_duplicate_haccount}.qq~"}~;
   }
  }
  $sth->finish();
  $sth = database->prepare(
   'SELECT id FROM '.config->{db_table_prefix}.'_settings WHERE s_name='.database->quote('billing_plan_name_'.$hplan)
  );
  my $tmpid;
  if ($sth->execute()) {
   ($tmpid) = $sth->fetchrow_array;
  }
  $sth->finish();
  if (!$tmpid) {
    return qq~{"result":"0","field":"email","error":"~.$lang->{form_error_invalid_hplan}.qq~"}~;
  }
  
  if ($id > 0) {
    database->quick_update(config->{db_table_prefix}.'_billing_hosting', { id => $id }, { host_acc => $haccount, host_plan_id => $hplan, host_days_remain => $hdays, lastchanged => time });
  } else {   
    database->quick_insert(config->{db_table_prefix}.'_billing_hosting', { user_id => $auth->{id}, host_acc => $haccount, host_plan_id => $hplan, host_days_remain => $hdays, lastchanged => time });
  }      
  return qq~{"result":"1"}~;
}; 

# End

true;