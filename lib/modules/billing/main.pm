package modules::billing::main;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use Digest::MD5 qw(md5_hex);
use Date::Format;
use Date::Parse;
use Fcntl qw(:flock SEEK_END); # import LOCK_* and SEEK_END constants
use taracot::fs;

# Configuration

my $defroute = '/admin/billing';
my @columns = ('u.id','u.username','u.realname', 'u.email','f.amount');
my @columns_mobile = ('u.id','u.username','f.amount');
my @columns_funds = ('id', 'trans_objects','trans_amount', 'trans_date');
my $domain_panel_plugin = 'api/regru.pl';

# Module core settings 

my $lang;
my $detect_lang;
prefix $defroute;

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

post '/data/config/generate' => sub {
  my $auth = &taracot::admin::_auth();
  if (!$auth) { redirect '/admin?'.md5_hex(time); return true }
  my $current_lang=_load_lang();
  content_type 'application/json';
  my %response;
  my $curlang = database->quote($current_lang);
  # load NS defaults
  my @nss;
  my $sth = database->prepare(
    'SELECT s_name, s_value FROM `'.config->{db_table_prefix}.'_settings` WHERE MATCH (s_name) AGAINST (\'billing_nss_*\' IN BOOLEAN MODE)'
  );
  if ($sth->execute()) {
    while (my ($s_name, $s_value) = $sth -> fetchrow_array()) {
      my %nh;
      $s_name=~s/^billing_nss_//;
      $nh{ns} = $s_name;
      $nh{host} = $s_value;
      push @nss, \%nh;
    }
  }
  $sth->finish();
  $response{nss} = \@nss;
  # load domain zones & costs
  my @domain_zones;  
  $sth = database->prepare(
    'SELECT s_name, s_value FROM `'.config->{db_table_prefix}.'_settings` WHERE MATCH (s_name) AGAINST (\'billing_domain_zone_*\' IN BOOLEAN MODE)'
  );
  if ($sth->execute()) {
    while (my ($s_name, $s_value) = $sth -> fetchrow_array()) {
      my %zone_data;
      $s_name=~s/^billing_domain_zone_//;
      $zone_data{zone}=$s_name;
      $s_value=~s/\s//gm;
      ($zone_data{cost}, $zone_data{cost_up}) = split(/,/, $s_value);
      if (!$zone_data{cost_up}) {
        $zone_data{cost_up} = $zone_data{cost};
      }
      push @domain_zones, \%zone_data;
    }
  }
  $sth->finish();
  $response{domain_zones}=\@domain_zones;
  # load hosting plan names and IDs from settings
  my %hosting_plan_names;
  my @hosting_plan_ids;
  $sth = database->prepare(
    'SELECT s_name, s_value FROM `'.config->{db_table_prefix}.'_settings` WHERE lang='.$curlang.' AND MATCH (s_name) AGAINST (\'billing_plan_name_*\' IN BOOLEAN MODE)'
  );
  if ($sth->execute()) {
    while (my ($s_name, $s_value) = $sth -> fetchrow_array()) {
      $s_name=~s/^billing_plan_name_//;
      $hosting_plan_names{$s_name} = $s_value;
      push @hosting_plan_ids, $s_name;
    }
  }
  $sth->finish();
  $response{hosting_plan_names} = \%hosting_plan_names;
  $response{hosting_plan_ids} = \@hosting_plan_ids;
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
  $response{hosting_plan_costs} = \%hosting_plan_costs;
  # generate hosting plan array
  my @hosting_plans;
  foreach my $pid (@hosting_plan_ids) {
   my %hosting_plan;
   $hosting_plan{id} = $pid;
   $hosting_plan{name} = $hosting_plan_names{$pid};
   $hosting_plan{cost} = $hosting_plan_costs{$pid};
   push @hosting_plans, \%hosting_plan;
  }
  my @sorted_hosting_plans = sort { $a->{cost} <=> $b->{cost} } @hosting_plans;
  $response{hosting_plans} = \@sorted_hosting_plans;
  # load service plan names and IDs from settings
  my %service_plan_names;
  my @service_plan_ids;
  $sth = database->prepare(
    'SELECT s_name, s_value FROM `'.config->{db_table_prefix}.'_settings` WHERE lang='.$curlang.' AND MATCH (s_name) AGAINST (\'billing_service_name_*\' IN BOOLEAN MODE)'
  );
  if ($sth->execute()) {
    while (my ($s_name, $s_value) = $sth -> fetchrow_array()) {
      $s_name=~s/^billing_service_name_//;
      $service_plan_names{$s_name} = $s_value;
      push @service_plan_ids, $s_name;
    }
  }
  $sth->finish();
  $response{service_plan_names} = \%service_plan_names;
  $response{service_plan_ids} = \@service_plan_ids;
  # load service plan costs from settings
  my %service_plan_costs;
  $sth = database->prepare(
    'SELECT s_name, s_value FROM `'.config->{db_table_prefix}.'_settings` WHERE MATCH (s_name) AGAINST (\'billing_service_cost_*\' IN BOOLEAN MODE)'
  );
  if ($sth->execute()) {
    while (my ($s_name, $s_value) = $sth -> fetchrow_array()) {
      $s_name=~s/^billing_service_cost_//;
      $service_plan_costs{$s_name} = $s_value;
    }
  }
  $response{service_plan_costs} = \%service_plan_costs;
  $sth->finish();
  # generate service plan array
  my @service_plans;
  foreach my $pid (@service_plan_ids) {
   my %service_plan;
   $service_plan{id} = $pid;
   $service_plan{name} = $service_plan_names{$pid};
   $service_plan{cost} = $service_plan_costs{$pid};
   push @service_plans, \%service_plan;
  }
  $response{service_plans} = \@service_plans;
  # load payment methods
  my @payment_methods;
  $sth = database->prepare(
    'SELECT s_name, s_value, s_value_html FROM `'.config->{db_table_prefix}.'_settings` WHERE lang='.$curlang.' AND MATCH (s_name) AGAINST (\'billing_payment_*\' IN BOOLEAN MODE)'
  );
  if ($sth->execute()) {
    while (my ($s_name, $s_value, $s_value_html) = $sth -> fetchrow_array()) {
      my %payment_method;
      $s_name=~s/^billing_payment_//;
      $s_value_html=~s/<.+?>//g;
      $s_value_html=~s/[\n\r]//g;
      $s_value_html=~s/^\s+//g;
      $s_value_html=~s/\s+$//g;
      $payment_method{id} = $s_name;
      $payment_method{name} = $s_value;
      $payment_method{desc} = $s_value_html;
      push @payment_methods, \%payment_method;
    }
  }
  $response{payment_methods} = \@payment_methods;
  $sth->finish();
  my %history_values;
  $sth = database->prepare(
   'SELECT s_name, s_value FROM '.config->{db_table_prefix}.'_settings WHERE (MATCH (s_name) AGAINST (\'billing_history_*\' IN BOOLEAN MODE)) AND lang='.database->quote($current_lang)
  );
  if ($sth->execute()) {
   while (my ($sname, $svalue) = $sth -> fetchrow_array) {
     $sname=~s/billing_history_//;
     $history_values{$sname} = $svalue;
   }
  }
  $sth->finish();
  $response{history_values} = \%history_values;
  my $json_xs = JSON::XS->new();
  my $json = $json_xs->encode(\%response);
  # Begin: return JSON data
  open(DATA, '>'.config->{root_dir}.'/'.config->{data_dir}.'/billing_'.$current_lang.'.json') || return '{"result":"0"}';
  flock(DATA, LOCK_EX) || return '{"result":"0"}'; 
  binmode(DATA);
  print DATA $json;
  close(DATA);
  return '{"result":"1"}'
};

get '/funds' => sub {
  my $auth = &taracot::admin::_auth();
  if (!$auth) { redirect '/admin?'.md5_hex(time); return true }
  my $id=param('id') || 0;
  $id=int($id);
  if ($id <= 0) {
   status 'not_found';
   pass();
  }
  _load_lang();
  my $navdata=&taracot::admin::_navdata();
  return template 'admin_billing_funds', { lang => $lang, navdata => $navdata, authdata => $auth, user_id => $id, pagetitle => $lang->{transactions_history} }, { layout => 'browser' };
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
    (MATCH (s.service_id) AGAINST ('.$sSearch.' IN BOOLEAN MODE) AND h.user_id = u.id))';   
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

get '/funds/data/list' => sub {
  if (!&taracot::admin::_auth()) { redirect '/admin?'.md5_hex(time); return true }
  my $clang = _load_lang();
  content_type 'application/json';
  my $id=param('id') || 0;
  $id=int($id);
  if ($id <= 0) {
   return qq~{"result":"0"}~;
  }
  my $sEcho = param('sEcho') || 0;
  $sEcho=int($sEcho);
  my $iDisplayStart = param('iDisplayStart') || 0;
  $iDisplayStart=int($iDisplayStart);
  my $iDisplayLength = param('iDisplayLength') || 0;
  $iDisplayLength=int($iDisplayLength);
  my $iColumns = param('iColumns') || @columns_funds;
  $iColumns=int($iColumns);
  my $sSearch = param('sSearch') || '';
  $sSearch=~s/^\s+//;
  $sSearch=~s/\s+$//;
  my $iSortingCols = param('iSortingCols') || 0;
  $iSortingCols=int($iSortingCols);
  my $iSortCol_0 = param('iSortCol_0') || 0;
  $iSortCol_0=int($iSortCol_0);
  my $sSortCol = $columns_funds[$iSortCol_0] || 'trans_date';
  my $sSortDir = param('sSortDir_0') || '';
  if ($sSortDir ne "asc" && $sSortDir ne "desc") {
   $sSortDir="asc";
  }
  my $where='1';
  if (length($sSearch) > 2 && length($sSearch) < 250) {
   $sSearch=database->quote('*'.$sSearch.'*');
   $where='(MATCH (trans_objects) AGAINST ('.$sSearch.' IN BOOLEAN MODE))';   
  }
  my $total=0;
  my $sth = database->prepare(
   'SELECT COUNT(*) AS cnt FROM '.config->{db_table_prefix}.'_billing_funds_history WHERE user_id='.$id
  );
  if ($sth->execute()) {
   ($total) = $sth -> fetchrow_array;
  }
  $sth->finish();
  my $total_filtered=0;  
  if ($where ne '1' && $total > 0) {
   my $sth = database->prepare(    
    'SELECT COUNT(*) AS cnt FROM `'.config->{db_table_prefix}.'_billing_funds_history` WHERE '.$where.' AND user_id='.$id
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
    
  my %history_values;
  my @history_id;
  my @history_val;
  $sth = database->prepare(
   'SELECT s_name, s_value FROM '.config->{db_table_prefix}.'_settings WHERE (MATCH (s_name) AGAINST (\'billing_history_*\' IN BOOLEAN MODE)) AND lang='.database->quote($clang)
  );
  if ($sth->execute()) {
   while (my ($sname, $svalue) = $sth -> fetchrow_array) {
     $sname=~s/billing_history_//;
     $history_values{$sname} = $svalue;
     push @history_id, $sname;
     push @history_val, $svalue;
   }
  }
  $sth->finish();

  my $columns=join(',',@columns_funds);
  $columns=~s/,$//;
  $sth = database->prepare(
   'SELECT '.$columns.',trans_id FROM `'.config->{db_table_prefix}.'_billing_funds_history` WHERE '.$where.' AND user_id='.$id.$sortorder.' LIMIT '.$iDisplayStart.', '.$iDisplayLength
  );
  if ($sth->execute()) {
   while(my (@ary) = $sth -> fetchrow_array) {
    my $trans_id = $ary[4];
    splice(@ary, 4, 1);
    if ($trans_id) {
      if ($history_values{$trans_id}) {
        $trans_id=$history_values{$trans_id};
      }
      if ($ary[1]) {
        $ary[1] = $trans_id." (".$ary[1].")"
      } else {
        $ary[1] = $trans_id;
      }
    }
    $ary[3] =  time2str($lang->{history_datetime_template}, $ary[3]);
    $ary[3] =~s/\\//gm;
    push(@ary, '');
    push(@data, \@ary);
   }
  }
  $sth->finish();
  
  my %response;
  $response{sEcho}=$sEcho;
  $response{iTotalRecords}=$total;
  $response{iTotalDisplayRecords}=$total_filtered;
  $response{aaData}=\@data;
  $response{history_ids} = \@history_id;
  $response{history_names} = \@history_val;
  my $json_xs = JSON::XS->new();
  my $json = $json_xs->encode(\%response);
  return $json;
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
  my $curlang = database->quote($current_lang);
  $sth = database->prepare(
    'SELECT s_name, s_value FROM `'.config->{db_table_prefix}.'_settings` WHERE lang='.$curlang.' AND MATCH (s_name) AGAINST (\'billing_plan_name_*\' IN BOOLEAN MODE)'
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
  my @sorted_hosting_plans = sort { $a->{cost} <=> $b->{cost} } @hosting_plans;
  $response{hosting_plans} = \@sorted_hosting_plans;
  # load service plan names and IDs from settings
  my %service_plan_names;
  my @service_plan_ids;
  $sth = database->prepare(
    'SELECT s_name, s_value FROM `'.config->{db_table_prefix}.'_settings` WHERE lang='.$curlang.' AND MATCH (s_name) AGAINST (\'billing_service_name_*\' IN BOOLEAN MODE)'
  );
  if ($sth->execute()) {
    while (my ($s_name, $s_value) = $sth -> fetchrow_array()) {
      $s_name=~s/^billing_service_name_//;
      $service_plan_names{$s_name} = $s_value;
      push @service_plan_ids, $s_name;
    }
  }
  $sth->finish();
  # load service plan costs from settings
  my %service_plan_costs;
  $sth = database->prepare(
    'SELECT s_name, s_value FROM `'.config->{db_table_prefix}.'_settings` WHERE MATCH (s_name) AGAINST (\'billing_service_cost_*\' IN BOOLEAN MODE)'
  );
  if ($sth->execute()) {
    while (my ($s_name, $s_value) = $sth -> fetchrow_array()) {
      $s_name=~s/^billing_service_cost_//;
      $service_plan_costs{$s_name} = $s_value;
    }
  }
  $sth->finish();
  # generate service plan array
  my @service_plans;
  foreach my $pid (@service_plan_ids) {
   my %service_plan;
   $service_plan{id} = $pid;
   $service_plan{name} = $service_plan_names{$pid};
   $service_plan{cost} = $service_plan_costs{$pid};
   push @service_plans, \%service_plan;
  }
  $response{service_plans} = \@service_plans;
  # select hosting accounts
  $sth = database->prepare(
    'SELECT id,host_acc,host_plan_id,host_days_remain FROM `'.config->{db_table_prefix}.'_billing_hosting` WHERE user_id='.$id
  );
  if ($sth->execute()) {
    my @host_accounts;
    while (my ($id,$host_acc,$host_plan_id,$host_days_remain) = $sth -> fetchrow_array()) {      
      my %data;
      $data{id} = $id;
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
  # select domain names
  $sth = database->prepare(
    'SELECT id,domain_name,exp_date FROM `'.config->{db_table_prefix}.'_billing_domains` WHERE user_id='.$id
  );
  if ($sth->execute()) {
    my @domain_names;
    while (my ($id,$domain_name,$exp_date) = $sth -> fetchrow_array()) {      
      my %data;
      $data{id} = $id;
      $data{domain_name} = $domain_name;
      $data{exp_date} = time2str($lang->{domain_date_template}, $exp_date);
      $data{exp_date} =~s/\\//gm;
      push (@domain_names, \%data);
    }
    $response{domains} = \@domain_names;
  }
  $sth->finish();
  # select services
  $sth = database->prepare(
    'SELECT id, service_id, service_days_remaining FROM `'.config->{db_table_prefix}.'_billing_services` WHERE user_id='.$id
  );
  if ($sth->execute()) {
    my @services;
    while (my ($id, $service_id, $service_days_remaining) = $sth -> fetchrow_array()) {      
      my %data;
      $data{id} = $id;
      $data{service_id} = $service_id;
      $data{service_days_remaining} = $service_days_remaining;
      $data{service_cost} = $service_plan_costs{$service_id} || '0';
      $data{service_name} = $service_plan_names{$service_id} || $service_id;
      push (@services, \%data);
    }
    $response{services} = \@services;
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
  my $h_queue=param('h_queue') || 0;
  if ($h_queue) {
    $h_queue=1;
  } else {
    $h_queue=0;
  }
  my $user_id=param('user_id') || 0;
  $user_id=int($user_id);
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
   'SELECT s_value FROM '.config->{db_table_prefix}.'_settings WHERE s_name='.database->quote('billing_plan_name_'.$hplan)
  );
  my $hplan_name;
  if ($sth->execute()) {
   ($hplan_name) = $sth->fetchrow_array;
  }
  $sth->finish();
  if (!$hplan_name) {
    return qq~{"result":"0","field":"email","error":"~.$lang->{form_error_invalid_hplan}.qq~"}~;
  }
  if ($id > 0) {
    database->quick_update(config->{db_table_prefix}.'_billing_hosting', { id => $id }, { host_acc => $haccount, host_plan_id => $hplan, host_days_remain => $hdays, in_queue => $h_queue, lastchanged => time });
  } else {   
    database->quick_insert(config->{db_table_prefix}.'_billing_hosting', { user_id => $user_id, host_acc => $haccount, host_plan_id => $hplan, host_days_remain => $hdays, in_queue => $h_queue, lastchanged => time });
    $id = database->{q{mysql_insertid}}; 
  }  
  if (!$id) {
   return qq~{"result":"0","error":"~.$lang->{db_save_error}.qq~"}~; 
  }
  $sth = database->prepare(
   'SELECT s_value FROM '.config->{db_table_prefix}.'_settings WHERE s_name='.database->quote('billing_plan_cost_'.$hplan)
  );
  my $hplan_cost;
  if ($sth->execute()) {
   ($hplan_cost) = $sth->fetchrow_array;
  }
  $sth->finish();
  if (!$hplan_cost) { 
   $hplan_cost="0";
  }
  my %response;
  my $json_xs = JSON::XS->new();  
  $response{result}="1";
  $response{id}=$id;
  $response{haccount}=$haccount;
  $response{hplan}=$hplan;
  $response{hplan_name}=$hplan_name;
  $response{hplan_cost}=$hplan_cost;
  $response{hdays}=$hdays;
  my $json = $json_xs->encode(\%response);
  return $json;    
}; 

post '/data/service/save' => sub {
  my $auth = &taracot::admin::_auth();
  if (!$auth) { redirect '/admin?'.md5_hex(time); return true }
  _load_lang();  
  content_type 'application/json';
  my $sid=param('sid') || '';
  my $sdays=param('sdays') || 0;
  my $id=param('id') || 0;
  my $user_id=param('user_id') || 0;
  $user_id=int($user_id);
  $id=int($id);
  $sdays=int($sdays);
  $sid=lc($sid);
  if ($sid !~ /^[A-Za-z0-9_\-]{1,100}$/) {
   return qq~{"result":"0","field":"sid","error":"~.$lang->{form_error_invalid_sid}.qq~"}~;
  }
  if ($sdays > 9999 || $sdays < -9999) {
   return qq~{"result":"0","field":"sdays","error":"~.$lang->{form_error_invalid_sdays}.qq~"}~;
  }  
  my $sth = database->prepare(
   'SELECT s_value FROM '.config->{db_table_prefix}.'_settings WHERE s_name='.database->quote('billing_service_name_'.$sid)
  );
  my $splan_name;
  if ($sth->execute()) {
   ($splan_name) = $sth->fetchrow_array;
  }
  $sth->finish();
  if (!$splan_name) {
    return qq~{"result":"0","field":"email","error":"~.$lang->{form_error_invalid_sid}.qq~"}~;
  }
  if ($id > 0) {
    database->quick_update(config->{db_table_prefix}.'_billing_services', { id => $id }, { service_id => $sid, service_days_remaining => $sdays, lastchanged => time });
  } else {   
    database->quick_insert(config->{db_table_prefix}.'_billing_services', { user_id => $user_id, service_id => $sid, service_days_remaining => $sdays, lastchanged => time });
    $id = database->{q{mysql_insertid}}; 
  }  
  if (!$id) {
   return qq~{"result":"0","error":"~.$lang->{db_save_error}.qq~"}~; 
  }
  $sth = database->prepare(
   'SELECT s_value FROM '.config->{db_table_prefix}.'_settings WHERE s_name='.database->quote('billing_service_cost_'.$sid)
  );
  my $splan_cost;
  if ($sth->execute()) {
   ($splan_cost) = $sth->fetchrow_array;
  }
  $sth->finish();
  if (!$splan_cost) { 
   $splan_cost="0";
  }
  my %response;
  my $json_xs = JSON::XS->new();  
  $response{result}="1";
  $response{id}=$id;
  $response{service_id}=$sid;
  $response{service_days_remaining}=$sdays;
  $response{service_name}=$splan_name;
  $response{service_cost}=$splan_cost;
  my $json = $json_xs->encode(\%response);
  return $json;    
};

post '/data/funds/save' => sub {
  my $auth = &taracot::admin::_auth();
  if (!$auth) { redirect '/admin?'.md5_hex(time); return true }
  _load_lang();  
  content_type 'application/json';
  my $user_id=param('user_id') || 0;
  $user_id=int($user_id);
  my $amount=param('amount') || 0;
  if (!$user_id) {
   return qq~{"result":"0"}~; 
  }
  if ($amount !~ /^[-+]?[0-9]*\.?[0-9]+$/) {
   return qq~{"result":"0"}~;
  } 
  my $res=0;
  my $sth = database->prepare(
   'INSERT INTO '.config->{db_table_prefix}.'_billing_funds (user_id,amount,lastchanged) VALUES ('.$user_id.','.database->quote($amount).','.time.') ON DUPLICATE KEY UPDATE amount=amount+'.database->quote($amount).',lastchanged='.time
  );
  if ($sth->execute()) {
    $res=1;
  }
  $sth->finish();
  if ($res) {
      return qq~{"result":"1"}~;
    } else {
      return qq~{"result":"0"}~;
    }
};

post '/data/funds/history/save' => sub {
  my $auth = &taracot::admin::_auth();
  if (!$auth) { redirect '/admin?'.md5_hex(time); return true }
  _load_lang();  
  content_type 'application/json';
  my $user_id=param('user_id') || 0;
  $user_id=int($user_id);
  if ($user_id <= 0) {
   return qq~{"result":"0"}~;
  }
  my $trans_id=param('trans_id') || '';
  my $trans_objects=param('trans_objects') || '';
  my $trans_amount=param('trans_amount') || 0;
  my $trans_date=param('trans_date') || '';
  my $id=param('id') || 0;
  $id=int($id);
  $trans_amount=int($trans_amount);
  $trans_id=lc($trans_id);
  if ($trans_id !~ /^[a-z_]{0,250}$/) {
   return qq~{"result":"0","field":"trans_id","error":"~.$lang->{form_error_invalid_trans_id}.qq~"}~;
  }
  if ($trans_amount !~ /^[-+]?[0-9]*\.?[0-9]+$/) {
   return qq~{"result":"0","field":"trans_amount","error":"~.$lang->{form_error_invalid_trans_amount}.qq~"}~;
  }
  if ($trans_objects !~ /^.{0,250}$/) {
   return qq~{"result":"0","field":"trans_objects","error":"~.$lang->{form_error_invalid_trans_objects}.qq~"}~;
  }
  if ($trans_date !~ /^[0-9AMP\.\/\-\: ]{1,20}$/) {
   return qq~{"result":"0","field":"trans_date","error":"~.$lang->{form_error_invalid_trans_date}.qq~"}~;
  }
  $trans_date = str2time($trans_date);
  if (!$trans_date) {
   return qq~{"result":"0","field":"trans_date","error":"~.$lang->{form_error_invalid_trans_date}.qq~"}~; 
  }
  my $sth;
  my $trans_id_name;
  if ($trans_id) {
    $sth = database->prepare(
     'SELECT s_value FROM '.config->{db_table_prefix}.'_settings WHERE s_name='.database->quote('billing_history_'.$trans_id)
    );
    if ($sth->execute()) {
     ($trans_id_name) = $sth->fetchrow_array;
    }
    $sth->finish();
  }
  if ($trans_id && !$trans_id_name) {
    return qq~{"result":"0","field":"trans_id","error":"~.$lang->{form_error_invalid_trans_id}.qq~"}~;
  }
  if ($id > 0) {
    database->quick_update(config->{db_table_prefix}.'_billing_funds_history', { id => $id }, { trans_id => $trans_id, trans_amount => $trans_amount, trans_objects => $trans_objects, trans_date => $trans_date, lastchanged => time });
  } else {   
    database->quick_insert(config->{db_table_prefix}.'_billing_funds_history', { user_id => $user_id, trans_id => $trans_id, trans_amount => $trans_amount, trans_objects => $trans_objects, trans_date => $trans_date, lastchanged => time });
    $id = database->{q{mysql_insertid}}; 
  }  
  if (!$id) {
   return qq~{"result":"0","error":"~.$lang->{db_save_error}.qq~"}~; 
  }
  return qq~{"result":"1"}~;
}; 

post '/data/domain/save' => sub {
  my $auth = &taracot::admin::_auth();
  if (!$auth) { redirect '/admin?'.md5_hex(time); return true }
  _load_lang();  
  content_type 'application/json';
  my $domain_name=param('domain_name') || '';
  my $domain_exp=param('domain_exp') || '';
  my $ns1=param('ns1') || '';
  my $ns2=param('ns2') || '';
  my $ns3=param('ns3') || '';
  my $ns4=param('ns4') || '';
  my $ns1_ip=param('ns1_ip') || '';
  my $ns2_ip=param('ns2_ip') || '';
  my $ns3_ip=param('ns3_ip') || '';
  my $ns4_ip=param('ns4_ip') || '';
  my $id=param('id') || 0;
  my $in_queue=param('d_queue') || 0;
  if ($in_queue) {
    $in_queue=1;
  } else {
    $in_queue=0;
  }
  my $user_id=param('user_id') || 0;
  $user_id=int($user_id);
  $id=int($id);
  $domain_name=lc($domain_name);
  if ($domain_name !~ /^[A-Za-z0-9\-]{2,100}$/) {
   return qq~{"result":"0","field":"domain_name","error":"~.$lang->{form_error_invalid_domain_name}.qq~"}~;
  }
  if ($domain_exp !~ /^[0-9\.\/\-]{1,12}$/) {
   return qq~{"result":"0","field":"domain_exp","error":"~.$lang->{form_error_invalid_domain_exp}.qq~"}~;
  }
  $domain_exp = str2time($domain_exp);
  if (!$domain_exp) {
   return qq~{"result":"0","field":"domain_exp","error":"~.$lang->{form_error_invalid_domain_exp}.qq~"}~; 
  }
  if ($ns1 !~ /^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ || length($ns1) > 80) {
   return qq~{"result":"0","field":"ns1","error":"~.$lang->{form_error_invalid_ns}.qq~"}~;
  }
  if ($ns2 !~ /^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ || length($ns2) > 80) {
   return qq~{"result":"0","field":"ns2","error":"~.$lang->{form_error_invalid_ns}.qq~"}~;
  }
  if ($ns3 && $ns3 !~ /^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ || length($ns3) > 80) {
   return qq~{"result":"0","field":"ns3","error":"~.$lang->{form_error_invalid_ns}.qq~"}~;
  }
  if ($ns4 && $ns4 !~ /^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ || length($ns4) > 80) {
   return qq~{"result":"0","field":"ns4","error":"~.$lang->{form_error_invalid_ns}.qq~"}~;
  }
  if ($ns1_ip && $ns1_ip !~ /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/ || length($ns1_ip) > 42) {
   return qq~{"result":"0","field":"ns1_ip","error":"~.$lang->{form_error_invalid_ns}.qq~"}~;
  }
  if ($ns2_ip && $ns2_ip !~ /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/ || length($ns2_ip) > 42) {
   return qq~{"result":"0","field":"ns2_ip","error":"~.$lang->{form_error_invalid_ns}.qq~"}~;
  }
  if ($ns3_ip && $ns3_ip !~ /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/ || length($ns3_ip) > 42) {
   return qq~{"result":"0","field":"ns3_ip","error":"~.$lang->{form_error_invalid_ns}.qq~"}~;
  }
  if ($ns4_ip && $ns4_ip !~ /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/ || length($ns4_ip) > 42) {
   return qq~{"result":"0","field":"ns4_ip","error":"~.$lang->{form_error_invalid_ns}.qq~"}~;
  }
  my $dupesql='';
  if ($id > 0) {
   $dupesql=' AND id != '.$id;
  }    
  my $sth = database->prepare(
   'SELECT id FROM '.config->{db_table_prefix}.'_billing_domains WHERE domain_name='.database->quote($domain_name).$dupesql
  );
  if ($sth->execute()) {
   my ($tmpid) = $sth->fetchrow_array;
   if ($tmpid) {
    $sth->finish();
    return qq~{"result":"0","field":"domain_name","error":"~.$lang->{form_error_duplicate_domain}.qq~"}~;
   }
  }
  $sth->finish();
  if ($id > 0) {
    database->quick_update(config->{db_table_prefix}.'_billing_domains', { id => $id }, { domain_name => $domain_name, exp_date => $domain_exp, ns1 => $ns1, ns2 => $ns2, ns3 => $ns3, ns4 => $ns4, ns1_ip => $ns1_ip, ns2_ip => $ns2_ip, ns3_ip => $ns3_ip, ns4_ip => $ns4_ip, in_queue => $in_queue, lastchanged => time });
  } else {   
    database->quick_insert(config->{db_table_prefix}.'_billing_domains', { user_id => $user_id, domain_name => $domain_name, exp_date => $domain_exp, ns1 => $ns1, ns2 => $ns2, ns3 => $ns3, ns4 => $ns4, ns1_ip => $ns1_ip, ns2_ip => $ns2_ip, ns3_ip => $ns3_ip, ns4_ip => $ns4_ip, in_queue => $in_queue, lastchanged => time });
    $id = database->{q{mysql_insertid}}; 
  }  
  if (!$id) {
   return qq~{"result":"0","error":"~.$lang->{db_save_error}.qq~"}~; 
  }
  my %response;
  my $json_xs = JSON::XS->new();  
  $response{result}="1";
  $response{id}=$id;
  $response{domain_name}=$domain_name;
  $response{domain_exp}=time2str($lang->{domain_date_template}, $domain_exp);
  $response{domain_exp}=~s/\\//gm;
  my $json = $json_xs->encode(\%response);
  return $json;    
};

post '/data/profile/save' => sub {
  my $auth = &taracot::admin::_auth();
  if (!$auth) { redirect '/admin?'.md5_hex(time); return true }
  my $id=param('id') || 0;
  $id = int($id);
  if (!$id) {
    return qq~{"result":"0","error":"~.$lang->{db_save_error}.qq~"}~;   
  }
  _load_lang();  
  content_type 'application/json';
  my $n1r = param('n1r');
  my $n1e = param('n1e');
  my $n2r = param('n2r');
  my $n2e = param('n2e');
  my $n3r = param('n3r');
  my $n3e = param('n3e');
  my $email = param('email');
  my $phone = param('phone');
  my $fax = param('fax');
  my $country = param('country');
  my $city = param('city');
  my $state = param('state');
  my $addr = param('addr');
  my $postcode = param('postcode');
  my $passport = param('passport');
  my $birth_date = param('birth_date');
  my $addr_ru = param('addr_ru');
  my $org = param('org');
  my $org_r = param('org_r');
  my $code = param('code');
  my $kpp = param('kpp');
  my $private = param('private');  
  # verify using regexp
  if ($n1r || $n2r || $n3r || $passport || $addr_ru) {
    if ($n1r !~ /^[А-Яа-я\-]{1,19}$/) {
     return qq~{"result":"0","field":"n1r","error":"~.$lang->{invalid_field}.' ('.$lang->{p_last_name}.')"}';
    }
    if ($n2r !~ /^[А-Яа-я\-]{1,19}$/) {
     return qq~{"result":"0","field":"n2r","error":"~.$lang->{invalid_field}.' ('.$lang->{p_first_name}.')"}';
    }
    if ($n3r !~ /^[А-Яа-я\-]{1,24}$/) {
     return qq~{"result":"0","field":"n3r","error":"~.$lang->{invalid_field}.' ('.$lang->{p_patronym}.')"}';
    }
    $passport=~s/\</&lt;/gm;
    $passport=~s/\>/&gt;/gm;
    if ($passport !~ /^([0-9]{2})(\s)([0-9]{2})(\s)([0-9]{6})(\s)(.*)([0-9]{2})(\.)([0-9]{2})(\.)([0-9]{4})$/) {
     return qq~{"result":"0","field":"passport","error":"~.$lang->{invalid_field}.' ('.$lang->{p_passport}.')"}';
    }
    $addr_ru=~s/\</&lt;/gm;
    $addr_ru=~s/\>/&gt;/gm;
    if ($addr_ru !~ /^([0-9]{6}),(\s)(.*)$/) {
     return qq~{"result":"0","field":"addr_ru","error":"~.$lang->{invalid_field}.' ('.$lang->{p_addr_ru}.')"}';
    }
  }
  if ($n1e !~ /^[A-Za-z\-]{1,30}$/) {
   return qq~{"result":"0","field":"n1e","error":"~.$lang->{invalid_field}.' ('.$lang->{p_last_name}.')"}';
  }
  if ($n2e !~ /^[A-Za-z\-]{1,30}$/) {
   return qq~{"result":"0","field":"n2e","error":"~.$lang->{invalid_field}.' ('.$lang->{p_first_name}.')"}';
  }
  if ($n3e !~ /^[A-Z]{1}$/) {
   return qq~{"result":"0","field":"n3e","error":"~.$lang->{invalid_field}.' ('.$lang->{p_patronym_first}.')"}';
  }
  if ($email !~ /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/ || length($email) > 80) {
   return qq~{"result":"0","field":"email","error":"~.$lang->{form_error_invalid_email}.qq~"}~;
  } 
  if ($phone !~ /^(\+)([0-9]{1,5})(\s)([0-9]{1,6})(\s)([0-9]{1,10})$/ || length($phone) > 20) {
   return qq~{"result":"0","field":"phone","error":"~.$lang->{invalid_field}.' ('.$lang->{p_phone}.')"}';
  } 
  if ($fax && ($fax !~ /^(\+)([0-9]{1,5})(\s)([0-9]{1,6})(\s)([0-9]{1,10})$/ || length($fax) > 20)) {
   return qq~{"result":"0","field":"fax","error":"~.$lang->{invalid_field}.' ('.$lang->{p_fax}.')"}';
  }
  if ($country !~ /^[A-Z]{2}$/) {
   return qq~{"result":"0","field":"country","error":"~.$lang->{invalid_field}.' ('.$lang->{p_country}.')"}';
  }
  if ($postcode !~ /^([0-9]{5,6})$/) {
    return qq~{"result":"0","field":"postcode","error":"~.$lang->{invalid_field}.' ('.$lang->{p_postcode}.')"}';
  }  
  if ($birth_date !~ /^([0-9]{2})(\.)([0-9]{2})(\.)([0-9]{4})$/) {
   return qq~{"result":"0","field":"birth_date","error":"~.$lang->{invalid_field}.' ('.$lang->{p_birth_date}.')"}';
  }  
  if ($org_r || $org || $code || $kpp) {
    $org_r=~s/\</&lt;/gm;
    $org_r=~s/\>/&gt;/gm;
    if ($org_r !~ /^(.{1,80})$/) {
      return qq~{"result":"0","field":"org_r","error":"~.$lang->{invalid_field}.' ('.$lang->{p_org_r}.')"}';
    }
    $org=~s/\</&lt;/gm;
    $org=~s/\>/&gt;/gm;
    if ($org !~ /^(.{1,80})$/) {
      return qq~{"result":"0","field":"org","error":"~.$lang->{invalid_field}.' ('.$lang->{p_org}.')"}';
    }
    if ($code !~ /^([0-9]{10})$/) {
      return qq~{"result":"0","field":"code","error":"~.$lang->{invalid_field}.' ('.$lang->{p_code}.')"}';
    }
    if ($kpp !~ /^([0-9]{9})$/) {
      return qq~{"result":"0","field":"kpp","error":"~.$lang->{invalid_field}.' ('.$lang->{p_kpp}.')"}';
    }
  }
  if ($city !~ /^([A-Za-z\-\. ]{2,64})$/) {
   return qq~{"result":"0","field":"city","error":"~.$lang->{invalid_field}.' ('.$lang->{p_city}.')"}';
  }
  if ($state !~ /^([A-Za-z\-\. ]{2,40})$/) {
   return qq~{"result":"0","field":"state","error":"~.$lang->{invalid_field}.' ('.$lang->{p_state}.')"}';
  }
  $addr=~s/\</&lt;/gm;
  $addr=~s/\>/&gt;/gm;
  if ($addr !~ /^(.{2,80})$/) {
   return qq~{"result":"0","field":"addr","error":"~.$lang->{invalid_field}.' ('.$lang->{p_addr}.')"}';
  }
  if ($private) {
    $private='1';
  } else {
    $private='0';
  }
  my $countries = $lang->{countries};
  my @countries_list = split(/\=/, $countries);
  my $country_exists=0;
  foreach my $crec (@countries_list) {
    my ($cn) = split(/\,/, $crec);
    if ($cn eq $country) {
      $country_exists=1;
    }
  }
  if (!$country_exists) {
   return qq~{"result":"0","field":"country","error":"~.$lang->{invalid_field}.' ('.$lang->{p_country}.')"}';
  }
  my $sth = database->prepare(
   'INSERT INTO '.config->{db_table_prefix}.'_billing_profiles (user_id,n1r,n1e,n2r,n2e,n3r,n3e,email,phone,fax,country,city,state,addr,postcode,passport,birth_date,addr_ru,org,org_r,code,kpp,private,lastchanged) VALUES ('.database->quote($id).','.database->quote($n1r).','.database->quote($n1e).','.database->quote($n2r).','.database->quote($n2e).','.database->quote($n3r).','.database->quote($n3e).','.database->quote($email).','.database->quote($phone).','.database->quote($fax).','.database->quote($country).','.database->quote($city).','.database->quote($state).','.database->quote($addr).','.database->quote($postcode).','.database->quote($passport).','.database->quote($birth_date).','.database->quote($addr_ru).','.database->quote($org).','.database->quote($org_r).','.database->quote($code).','.database->quote($kpp).','.database->quote($private).','.time.') ON DUPLICATE KEY UPDATE n1r='.database->quote($n1r).',n1e='.database->quote($n1e).',n2r='.database->quote($n2r).',n2e='.database->quote($n2e).',n3r='.database->quote($n3r).',n3e='.database->quote($n3e).',email='.database->quote($email).',phone='.database->quote($phone).',fax='.database->quote($fax).',country='.database->quote($country).',city='.database->quote($city).',state='.database->quote($state).',addr='.database->quote($addr).',postcode='.database->quote($postcode).',passport='.database->quote($passport).',birth_date='.database->quote($birth_date).',addr_ru='.database->quote($addr_ru).',org='.database->quote($org).',org_r='.database->quote($org_r).',code='.database->quote($code).',kpp='.database->quote($kpp).',private='.database->quote($private).',lastchanged='.time
  );
  if ($sth->execute()) {   
  }
  $sth->finish();
  my %response;
  my $json_xs = JSON::XS->new();    
  my $json = $json_xs->encode(\%response);
  return $json;    
};

post '/data/hosting/load' => sub {
  my $auth = &taracot::admin::_auth();
  if (!$auth) { redirect '/admin?'.md5_hex(time); return true }
  content_type 'application/json';
  my $id=param('id') || 0;
  $id = int($id);
  if (!$id) {
   return qq~{"result":"0"}~; 
  }
  my $sth = database->prepare(
   'SELECT host_acc, host_plan_id, host_days_remain, in_queue FROM '.config->{db_table_prefix}.'_billing_hosting WHERE id='.$id
  );
  my ($haccount, $hplan, $hdays, $h_queue);
  if ($sth->execute()) {
   ($haccount, $hplan, $hdays, $h_queue) = $sth->fetchrow_array;
  }
  $sth->finish();
  if (!$haccount) {
   return qq~{"result":"0"}~; 
  }
  my %response;
  my $json_xs = JSON::XS->new();  
  $response{result}="1";
  $response{haccount}=$haccount;
  $response{hplan}=$hplan;
  $response{hdays}=$hdays;
  $response{h_queue}=$h_queue;
  my $json = $json_xs->encode(\%response);
  return $json;    
};

post '/data/domain/load' => sub {
  my $auth = &taracot::admin::_auth();
  if (!$auth) { redirect '/admin?'.md5_hex(time); return true }
  content_type 'application/json';
  my $id=param('id') || 0;
  $id = int($id);
  if (!$id) {
   return qq~{"result":"0"}~; 
  }
  my $sth = database->prepare(
   'SELECT domain_name,exp_date,ns1,ns2,ns3,ns4,ns1_ip,ns2_ip,ns3_ip,ns4_ip,in_queue FROM '.config->{db_table_prefix}.'_billing_domains WHERE id='.$id
  );
  my ($domain_name,$exp_date,$ns1,$ns2,$ns3,$ns4,$ns1_ip,$ns2_ip,$ns3_ip,$ns4_ip,$d_queue);
  if ($sth->execute()) {
   ($domain_name,$exp_date,$ns1,$ns2,$ns3,$ns4,$ns1_ip,$ns2_ip,$ns3_ip,$ns4_ip,$d_queue) = $sth->fetchrow_array;
  }
  $sth->finish();
  if (!$domain_name) {
   return qq~{"result":"0"}~; 
  }
  my %response;
  my $json_xs = JSON::XS->new();  
  $response{result}="1";
  $response{domain_name}=$domain_name;
  $response{domain_exp}=time2str($lang->{domain_date_template}, $exp_date);
  $response{domain_exp}=~s/\\//gm;
  $response{ns1}=$ns1;
  $response{ns2}=$ns2;
  $response{ns3}=$ns3;
  $response{ns4}=$ns4;
  $response{ns1_ip}=$ns1_ip;
  $response{ns2_ip}=$ns2_ip;
  $response{ns3_ip}=$ns3_ip;
  $response{ns4_ip}=$ns4_ip;
  $response{d_queue}=$d_queue;
  my $json = $json_xs->encode(\%response);
  return $json;    
};

post '/data/service/load' => sub {
  my $auth = &taracot::admin::_auth();
  if (!$auth) { redirect '/admin?'.md5_hex(time); return true }
  content_type 'application/json';
  my $id=param('id') || 0;
  $id = int($id);
  if (!$id) {
   return qq~{"result":"0"}~; 
  }
  my $sth = database->prepare(
   'SELECT service_id, service_days_remaining FROM '.config->{db_table_prefix}.'_billing_services WHERE id='.$id
  );
  my ($service_id, $service_days_remaining);
  if ($sth->execute()) {
   ($service_id, $service_days_remaining) = $sth->fetchrow_array;
  }
  $sth->finish();
  if (!$service_id) {
   return qq~{"result":"0"}~; 
  }
  my %response;
  my $json_xs = JSON::XS->new();  
  $response{result}="1";
  $response{sid}=$service_id;
  $response{sdays}=$service_days_remaining;
  my $json = $json_xs->encode(\%response);
  return $json;    
};

post '/data/profile/load' => sub {
  my $auth = &taracot::admin::_auth();
  if (!$auth) { redirect '/admin?'.md5_hex(time); return true }
  content_type 'application/json';
  my $id=param('id') || 0;
  $id = int($id);
  if (!$id) {
   return qq~{"result":"0"}~; 
  }
  my $sth = database->prepare(
   'SELECT id,n1r,n1e,n2r,n2e,n3r,n3e,email,phone,fax,country,city,state,addr,postcode,passport,birth_date,addr_ru,org,org_r,code,kpp,private FROM '.config->{db_table_prefix}.'_billing_profiles WHERE user_id='.$id
  );
  my $resp;
  if ($sth->execute()) {
   $resp = $sth->fetchrow_hashref;
  }
  $sth->finish();
  my %response;
  my $json_xs = JSON::XS->new();  
  $response{result}="1";
  $response{db}=$resp;
  my $json = $json_xs->encode(\%response);
  return $json;    
};

post '/data/funds/history/load' => sub {
  my $auth = &taracot::admin::_auth();
  if (!$auth) { redirect '/admin?'.md5_hex(time); return true }
  content_type 'application/json';
  my $id=param('id') || 0;
  $id = int($id);
  if (!$id) {
   return qq~{"result":"0"}~; 
  }
  my $sth = database->prepare(
   'SELECT trans_id, trans_objects, trans_amount, trans_date FROM '.config->{db_table_prefix}.'_billing_funds_history WHERE id='.$id
  );
  my ($trans_id, $trans_objects, $trans_amount, $trans_date);
  if ($sth->execute()) {
   ($trans_id, $trans_objects, $trans_amount, $trans_date) = $sth->fetchrow_array;
  }
  $sth->finish();
  if (!$trans_date) {
   return qq~{"result":"0"}~; 
  }
  my %response;
  my $json_xs = JSON::XS->new();  
  $response{result}="1";
  $response{trans_id}=$trans_id;
  $response{trans_objects}=$trans_objects;
  $response{trans_amount}=$trans_amount;
  $response{trans_date}=time2str($lang->{trans_date_template}, $trans_date);
  $response{trans_date}=~s/\\//gm;
  $response{trans_time}=time2str($lang->{trans_time_template}, $trans_date);
  $response{trans_time}=~s/\\//gm;
  my $json = $json_xs->encode(\%response);
  return $json;    
};

post '/data/hosting/delete' => sub {
  my $auth = &taracot::admin::_auth();
  if (!$auth) { redirect '/admin?'.md5_hex(time); return true }
  content_type 'application/json';
  my $id=param('id') || 0;
  $id = int($id);
  if (!$id) {
   return qq~{"result":"0"}~; 
  }
  my $sth = database->prepare(
    'DELETE FROM '.config->{db_table_prefix}.'_billing_hosting WHERE id='.$id
  );
  my $res;
  if ($sth->execute()) {
   $res=qq~{"result":"1"}~;
  } else {
   $res=qq~{"result":"0"}~;
  }
  $sth->finish();
  return $res; 
};

post '/data/domain/delete' => sub {
  my $auth = &taracot::admin::_auth();
  if (!$auth) { redirect '/admin?'.md5_hex(time); return true }
  content_type 'application/json';
  my $id=param('id') || 0;
  $id = int($id);
  if (!$id) {
   return qq~{"result":"0"}~; 
  }
  my $sth = database->prepare(
    'DELETE FROM '.config->{db_table_prefix}.'_billing_domains WHERE id='.$id
  );
  my $res;
  if ($sth->execute()) {
   $res=qq~{"result":"1"}~;
  } else {
   $res=qq~{"result":"0"}~;
  }
  $sth->finish();
  return $res; 
};

post '/data/service/delete' => sub {
  my $auth = &taracot::admin::_auth();
  if (!$auth) { redirect '/admin?'.md5_hex(time); return true }
  content_type 'application/json';
  my $id=param('id') || 0;
  $id = int($id);
  if (!$id) {
   return qq~{"result":"0"}~; 
  }
  my $sth = database->prepare(
    'DELETE FROM '.config->{db_table_prefix}.'_billing_services WHERE id='.$id
  );
  my $res;
  if ($sth->execute()) {
   $res=qq~{"result":"1"}~;
  } else {
   $res=qq~{"result":"0"}~;
  }
  $sth->finish();
  return $res; 
};

post '/data/funds/history/delete' => sub {
  my $auth = &taracot::admin::_auth();
  if (!$auth) { redirect '/admin?'.md5_hex(time); return true }
  content_type 'application/json';
  my $id=param('id') || 0;
  $id = int($id);
  if (!$id) {
   return qq~{"result":"0"}~; 
  }
  my $sth = database->prepare(
    'DELETE FROM '.config->{db_table_prefix}.'_billing_funds_history WHERE id='.$id
  );
  my $res;
  if ($sth->execute()) {
   $res=qq~{"result":"1"}~;
  } else {
   $res=qq~{"result":"0"}~;
  }
  $sth->finish();
  return $res; 
};

# Frontend begins here
#####################################################

prefix '/customer';

get '/' => sub {
  my $auth_data = &taracot::_auth();
  if (!$auth_data) { redirect '/user/authorize?comeback=/customer' } 
  my $_current_lang=_load_lang();
  database->quick_update(config->{db_table_prefix}.'_users', { id => $auth_data->{id} }, { last_lang => $_current_lang, lastchanged => time }); 
  my $page_data = &taracot::_load_settings('site_title,keywords,description,billing_currency', $_current_lang);
  my $render_template = &taracot::_process_template( template 'billing_customer', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'billing_customer.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{billing_customer}, auth_data => $auth_data }, { layout => config->{layout}.'_'.$_current_lang } );
  if ($render_template) {
    return $render_template;
  }
  pass();
}; 

post '/data/load' => sub {
  my $auth_data = &taracot::_auth();
  content_type 'application/json';
  if (!$auth_data) { return qq~{"result":"0"}~;  } 
  my %response;
  my $current_lang = _load_lang();  
  my $curlang = database->quote($current_lang);
  my $lf = loadFile(config->{root_dir}.'/'.config->{data_dir}.'/billing_'.$current_lang.'.json');
  if (!$lf) {
    return '{"result":"0"}';
  }
  my $json_config=from_json $$lf;
  my $domain_zones = $json_config->{domain_zones};
  $response{domain_zones} = $domain_zones;
  my $hosting_plan_names = $json_config->{hosting_plan_names};
  my $hosting_plan_ids = $json_config->{hosting_plan_ids};
  my $hosting_plan_costs = $json_config->{hosting_plan_costs};
  my $hosting_plans = $json_config->{hosting_plans};
  $response{hosting_plans} = $hosting_plans;
  my $service_plan_names = $json_config->{service_plan_names};
  my $service_plan_ids = $json_config->{service_plan_ids};
  my $service_plan_costs = $json_config->{service_plan_costs};
  my $service_plans = $json_config->{service_plans};
  $response{service_plans} = $service_plans;
  my $payment_methods= $json_config->{payment_methods};
  $response{payment_methods} = $payment_methods;
  my $history_values = $json_config->{history_values};
  my $nss = $json_config->{nss};
  $response{nss} = $nss;
  # select hosting accounts
  my $sth = database->prepare(
    'SELECT id,host_acc,host_plan_id,host_days_remain,error_msg,in_queue FROM `'.config->{db_table_prefix}.'_billing_hosting` WHERE user_id='.$auth_data->{id}.' ORDER BY id'
  );
  if ($sth->execute()) {
    my @host_accounts;
    while (my ($id,$host_acc,$host_plan_id,$host_days_remain,$error_msg,$in_queue) = $sth -> fetchrow_array()) {      
      my %data;
      $data{id} = $id;
      $data{account} = $host_acc;
      $data{plan_id} = $host_plan_id;
      $data{plan_cost} = $hosting_plan_costs->{$host_plan_id} || '0';
      $data{plan_name} = $hosting_plan_names->{$host_plan_id} || $host_plan_id;
      $data{in_queue} = $in_queue;
      $data{error_msg} = $error_msg;
      $data{days} = $host_days_remain;
      push (@host_accounts, \%data);
    }
    $response{hosting} = \@host_accounts;
  }
  $sth->finish();
  # select domain names
  $sth = database->prepare(
    'SELECT id,domain_name,exp_date,error_msg,in_queue FROM `'.config->{db_table_prefix}.'_billing_domains` WHERE user_id='.$auth_data->{id}
  );
  if ($sth->execute()) {
    my @domain_names;
    while (my ($id, $domain_name, $exp_date,$error_msg,$in_queue) = $sth -> fetchrow_array()) {      
      if ($exp_date - time + 864000 < 0) { # 10 days
        next;
      }
      my $zone=lc $domain_name;
      $zone=~s/^[^\.]*\.//;
      my $allow_update='0';
      my $expired='0';
      if ((($zone eq 'ru' || $zone eq 'su') && ( $exp_date - time < 4838400)) || ($zone ne 'ru' && $zone ne 'su')) {
        $allow_update='1';
      }
      if ($exp_date - time < 0) {
        $expired='1';
      }
      my %data;
      $data{id} = $id;
      $data{domain_name} = $domain_name;
      $data{exp_date} = time2str($lang->{domain_date_template}, $exp_date);
      $data{exp_date} =~s/\\//gm;
      $data{update} = $allow_update;
      $data{expired} = $expired;
      $data{in_queue} = $in_queue;
      $data{error_msg} = $error_msg;
      $data{zone} = $zone;
      push (@domain_names, \%data);
    }
    $response{domains} = \@domain_names;
  }
  $sth->finish();
  # select services
  $sth = database->prepare(
    'SELECT id, service_id, service_days_remaining FROM `'.config->{db_table_prefix}.'_billing_services` WHERE user_id='.$auth_data->{id}
  );
  if ($sth->execute()) {
    my @services;
    while (my ($id, $service_id, $service_days_remaining) = $sth -> fetchrow_array()) {      
      my %data;
      $data{id} = $id;
      $data{service_id} = $service_id;
      $data{days} = $service_days_remaining;
      $data{cost} = $service_plan_costs->{$service_id} || '0';
      $data{name} = $service_plan_names->{$service_id} || $service_id;
      push (@services, \%data);
    }
    $response{services} = \@services;
  }
  $sth->finish();
  # select funds amount
  $sth = database->prepare(
    'SELECT amount FROM `'.config->{db_table_prefix}.'_billing_funds` WHERE user_id='.$auth_data->{id}
  );
  if ($sth->execute()) {
    my ($amount) = $sth -> fetchrow_array();
    $response{amount} = $amount;
  }
  $sth->finish();
  if (!$response{amount}) {
    $response{amount}='0';
  }
  # select history  
  my @history;
  $sth = database->prepare(
   'SELECT trans_id, trans_objects, trans_amount, trans_date FROM `'.config->{db_table_prefix}.'_billing_funds_history` WHERE user_id='.$auth_data->{id}.' ORDER BY trans_date DESC LIMIT 50'
  );
  if ($sth->execute()) {
   while(my ($trans_id, $trans_objects, $trans_amount, $trans_date) = $sth -> fetchrow_array) {
    my %hr;
    my $event;
    if ($trans_id) {
      if ($history_values->{$trans_id}) {
        $event=$history_values->{$trans_id}.' ';
      } else {
        $event=$trans_id.' ';
      }
    }
    if ($trans_objects) {
      if ($event) {
        $event.=' ('.$trans_objects.')';
      } else {
        $event.=$trans_objects;
      }
    }
    $trans_date =  time2str($lang->{history_datetime_template}, $trans_date);
    $trans_date =~s/\\//gm;
    $hr{event}=$event;
    $hr{date}=$trans_date;
    $hr{amount}=$trans_amount;
    push @history, \%hr;
   }
   $response{history} = \@history;
  }
  $sth->finish();
  # select profile
  my $profile_hash;
  $sth = database->prepare(
   'SELECT id,n1r,n1e,n2r,n2e,n3r,n3e,email,phone,fax,country,city,state,addr,postcode,passport,birth_date,addr_ru,org,org_r,code,kpp,private FROM '.config->{db_table_prefix}.'_billing_profiles WHERE user_id='.$auth_data->{id}
  );
  if ($sth->execute()) {
   $profile_hash = $sth->fetchrow_hashref;
  }
  $sth->finish();
  $response{profile}=$profile_hash;
  # return data
  $response{result} = 1;
  my $json_xs = JSON::XS->new();
  my $json = $json_xs->encode(\%response);
  return $json;
};

post '/data/load/history' => sub {
  my $auth_data = &taracot::_auth();
  content_type 'application/json';
  if (!$auth_data) { return qq~{"result":"0"}~;  } 
  my %response;
  my $current_lang = _load_lang();  
  # select history
  my %history_values;
  my $sth = database->prepare(
   'SELECT s_name, s_value FROM '.config->{db_table_prefix}.'_settings WHERE (MATCH (s_name) AGAINST (\'billing_history_*\' IN BOOLEAN MODE)) AND lang='.database->quote($current_lang)
  );
  if ($sth->execute()) {
   while (my ($sname, $svalue) = $sth -> fetchrow_array) {
     $sname=~s/billing_history_//;
     $history_values{$sname} = $svalue;
   }
  }
  $sth->finish();
  my @history;
  $sth = database->prepare(
   'SELECT trans_id, trans_objects, trans_amount, trans_date FROM `'.config->{db_table_prefix}.'_billing_funds_history` WHERE user_id='.$auth_data->{id}.' ORDER BY trans_date DESC LIMIT 50'
  );
  if ($sth->execute()) {
   while(my ($trans_id, $trans_objects, $trans_amount, $trans_date) = $sth -> fetchrow_array) {
    my %hr;
    my $event;
    if ($trans_id) {
      if ($history_values{$trans_id}) {
        $event=$history_values{$trans_id}.' ';
      } else {
        $event=$trans_id.' ';
      }
    }
    if ($trans_objects) {
      if ($event) {
        $event.=' ('.$trans_objects.')';
      } else {
        $event.=$trans_objects;
      }
    }
    $trans_date =  time2str($lang->{history_datetime_template}, $trans_date);
    $trans_date =~s/\\//gm;
    $hr{event}=$event;
    $hr{date}=$trans_date;
    $hr{amount}=$trans_amount;
    push @history, \%hr;
   }
   $response{history} = \@history;
  }
  $sth->finish();  
  # return data
  $response{result} = 1;
  my $json_xs = JSON::XS->new();
  my $json = $json_xs->encode(\%response);
  return $json;
};

post '/data/get_bill' => sub {
  my $auth_data = &taracot::_auth();
  content_type 'application/json';
  if (!$auth_data) { return qq~{"result":"0"}~;  } 
  my $curlang=_load_lang();
  my $amount=param('amount');
  my $plugin=param('plugin');
  if ($amount !~ /^[0-9]*\.?[0-9]+$/) {
   return qq~{"result":"0","field":"amnt","error":"~.$lang->{form_error_invalid_amount}.qq~"}~;
  }
  if ($plugin !~ /^[a-z]{1,40}$/) {
   return qq~{"result":"0","error":"~.$lang->{form_error_invalid_paysys}.qq~"}~;
  }
  my $pay_sys;
  my $sth = database->prepare(
    'SELECT s_value FROM `'.config->{db_table_prefix}.'_settings` WHERE lang='.database->quote($curlang).' AND s_name=\'billing_payment_'.$plugin.'\''
  );
  if ($sth->execute()) {
    ($pay_sys) = $sth -> fetchrow_array();
  }
  $sth->finish();
  if (!$pay_sys) {
   return qq~{"result":"0","error":"~.$lang->{form_error_invalid_paysys}.qq~"}~;
  }
  my $json_xs = JSON::XS->new();
  my %response;
  eval { require "api/$plugin.pl"; };
  if ($@) {   
   $response{result} = 0;
   $response{error} = $lang->{form_error_invalid_plugin};  
   my $json = $json_xs->encode(\%response);
   return $json;
  }
  database->quick_insert(config->{db_table_prefix}.'_billing_bills', { user_id => $auth_data->{id}, amount => $amount, created => time });
  my $id = database->{q{mysql_insertid}};
  if (!$id) {
    $response{result} = 0;
    $response{error} = $lang->{form_error_creating_bill};  
    my $json = $json_xs->encode(\%response);
    return $json;  
  }
  my $pdata = &getFieldsAPI($amount, $id);
  $response{result} = 1;  
  $response{amount} = $amount;
  $response{id} = $id;
  $response{paysys} = $pay_sys;
  $response{pdata} = $pdata;
  my $json = $json_xs->encode(\%response);
  return $json;
}; 

post '/data/profile/save' => sub {
  my $auth_data = &taracot::_auth();
  content_type 'application/json';
  if (!$auth_data) { return qq~{"result":"0"}~;  } 
  my $id=$auth_data->{id} || 0;
  if (!$id) {
    return qq~{"result":"0","error":"~.$lang->{db_save_error}.qq~"}~;   
  }
  _load_lang();  
  content_type 'application/json';
  my $n1r = param('n1r');
  my $n1e = param('n1e');
  my $n2r = param('n2r');
  my $n2e = param('n2e');
  my $n3r = param('n3r');
  my $n3e = param('n3e');
  my $email = param('email');
  my $phone = param('phone');
  my $fax = param('fax');
  my $country = param('country');
  my $city = param('city');
  my $state = param('state');
  my $addr = param('addr');
  my $postcode = param('postcode');
  my $passport = param('passport');
  my $birth_date = param('birth_date');
  my $addr_ru = param('addr_ru');
  my $org = param('org');
  my $org_r = param('org_r');
  my $code = param('code');
  my $kpp = param('kpp');
  my $private = param('private');  
  # verify using regexp
  if ($n1r || $n2r || $n3r || $passport || $addr_ru) {
    if ($n1r !~ /^[А-Яа-я\-]{1,19}$/) {
     return qq~{"result":"0","field":"n1r","error":"~.$lang->{invalid_field}.' ('.$lang->{p_last_name}.')"}';
    }
    if ($n2r !~ /^[А-Яа-я\-]{1,19}$/) {
     return qq~{"result":"0","field":"n2r","error":"~.$lang->{invalid_field}.' ('.$lang->{p_first_name}.')"}';
    }
    if ($n3r !~ /^[А-Яа-я\-]{1,24}$/) {
     return qq~{"result":"0","field":"n3r","error":"~.$lang->{invalid_field}.' ('.$lang->{p_patronym}.')"}';
    }
    $passport=~s/\</&lt;/gm;
    $passport=~s/\>/&gt;/gm;
    if ($passport !~ /^([0-9]{2})(\s)([0-9]{2})(\s)([0-9]{6})(\s)(.*)([0-9]{2})(\.)([0-9]{2})(\.)([0-9]{4})$/) {
     return qq~{"result":"0","field":"passport","error":"~.$lang->{invalid_field}.' ('.$lang->{p_passport}.')"}';
    }
    $addr_ru=~s/\</&lt;/gm;
    $addr_ru=~s/\>/&gt;/gm;
    if ($addr_ru !~ /^([0-9]{6}),(\s)(.*)$/) {
     return qq~{"result":"0","field":"addr_ru","error":"~.$lang->{invalid_field}.' ('.$lang->{p_addr_ru}.')"}';
    }
  }
  if ($n1e !~ /^[A-Za-z\-]{1,30}$/) {
   return qq~{"result":"0","field":"n1e","error":"~.$lang->{invalid_field}.' ('.$lang->{p_last_name}.')"}';
  }
  if ($n2e !~ /^[A-Za-z\-]{1,30}$/) {
   return qq~{"result":"0","field":"n2e","error":"~.$lang->{invalid_field}.' ('.$lang->{p_first_name}.')"}';
  }
  if ($n3e !~ /^[A-Z]{1}$/) {
   return qq~{"result":"0","field":"n3e","error":"~.$lang->{invalid_field}.' ('.$lang->{p_patronym_first}.')"}';
  }
  if ($email !~ /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/ || length($email) > 80) {
   return qq~{"result":"0","field":"email","error":"~.$lang->{form_error_invalid_email}.qq~"}~;
  } 
  if ($phone !~ /^(\+)([0-9]{1,5})(\s)([0-9]{1,6})(\s)([0-9]{1,10})$/ || length($phone) > 20) {
   return qq~{"result":"0","field":"phone","error":"~.$lang->{invalid_field}.' ('.$lang->{p_phone}.')"}';
  } 
  if ($fax && ($fax !~ /^(\+)([0-9]{1,5})(\s)([0-9]{1,6})(\s)([0-9]{1,10})$/ || length($fax) > 20)) {
   return qq~{"result":"0","field":"fax","error":"~.$lang->{invalid_field}.' ('.$lang->{p_fax}.')"}';
  }
  if ($country !~ /^[A-Z]{2}$/) {
   return qq~{"result":"0","field":"country","error":"~.$lang->{invalid_field}.' ('.$lang->{p_country}.')"}';
  }
  if ($postcode !~ /^([0-9]{5,6})$/) {
    return qq~{"result":"0","field":"postcode","error":"~.$lang->{invalid_field}.' ('.$lang->{p_postcode}.')"}';
  }  
  if ($birth_date !~ /^([0-9]{2})(\.)([0-9]{2})(\.)([0-9]{4})$/) {
   return qq~{"result":"0","field":"birth_date","error":"~.$lang->{invalid_field}.' ('.$lang->{p_birth_date}.')"}';
  }  
  if ($org_r || $org || $code || $kpp) {
    $org_r=~s/\</&lt;/gm;
    $org_r=~s/\>/&gt;/gm;
    if ($org_r !~ /^(.{1,80})$/) {
      return qq~{"result":"0","field":"org_r","error":"~.$lang->{invalid_field}.' ('.$lang->{p_org_r}.')"}';
    }
    $org=~s/\</&lt;/gm;
    $org=~s/\>/&gt;/gm;
    if ($org !~ /^(.{1,80})$/) {
      return qq~{"result":"0","field":"org","error":"~.$lang->{invalid_field}.' ('.$lang->{p_org}.')"}';
    }
    if ($code !~ /^([0-9]{10})$/) {
      return qq~{"result":"0","field":"code","error":"~.$lang->{invalid_field}.' ('.$lang->{p_code}.')"}';
    }
    if ($kpp !~ /^([0-9]{9})$/) {
      return qq~{"result":"0","field":"kpp","error":"~.$lang->{invalid_field}.' ('.$lang->{p_kpp}.')"}';
    }
  }
  if ($city !~ /^([A-Za-z\-\. ]{2,64})$/) {
   return qq~{"result":"0","field":"city","error":"~.$lang->{invalid_field}.' ('.$lang->{p_city}.')"}';
  }
  if ($state !~ /^([A-Za-z\-\. ]{2,40})$/) {
   return qq~{"result":"0","field":"state","error":"~.$lang->{invalid_field}.' ('.$lang->{p_state}.')"}';
  }
  $addr=~s/\</&lt;/gm;
  $addr=~s/\>/&gt;/gm;
  if ($addr !~ /^(.{2,80})$/) {
   return qq~{"result":"0","field":"addr","error":"~.$lang->{invalid_field}.' ('.$lang->{p_addr}.')"}';
  }
  if ($private) {
    $private='1';
  } else {
    $private='0';
  }
  my $countries = $lang->{countries};
  my @countries_list = split(/\=/, $countries);
  my $country_exists=0;
  foreach my $crec (@countries_list) {
    my ($cn) = split(/\,/, $crec);
    if ($cn eq $country) {
      $country_exists=1;
    }
  }
  if (!$country_exists) {
   return qq~{"result":"0","field":"country","error":"~.$lang->{invalid_field}.' ('.$lang->{p_country}.')"}';
  }
  my $in_queue=0;
  my $sth = database->prepare(
   'SELECT id FROM '.config->{db_table_prefix}.'_billing_queue WHERE user_id='.$auth_data->{id}.' LIMIT 1'
  );
  if ($sth->execute()) {
    ($in_queue) = $sth->fetchrow_array;
  }
  $sth->finish();
  if ($in_queue) {
    return qq~{"result":"0","field":"haccount","error":"~.$lang->{queue_active}.qq~"}~; 
  }
  $sth = database->prepare(
   'INSERT INTO '.config->{db_table_prefix}.'_billing_profiles (user_id,n1r,n1e,n2r,n2e,n3r,n3e,email,phone,fax,country,city,state,addr,postcode,passport,birth_date,addr_ru,org,org_r,code,kpp,private,lastchanged) VALUES ('.database->quote($id).','.database->quote($n1r).','.database->quote($n1e).','.database->quote($n2r).','.database->quote($n2e).','.database->quote($n3r).','.database->quote($n3e).','.database->quote($email).','.database->quote($phone).','.database->quote($fax).','.database->quote($country).','.database->quote($city).','.database->quote($state).','.database->quote($addr).','.database->quote($postcode).','.database->quote($passport).','.database->quote($birth_date).','.database->quote($addr_ru).','.database->quote($org).','.database->quote($org_r).','.database->quote($code).','.database->quote($kpp).','.database->quote($private).','.time.') ON DUPLICATE KEY UPDATE n1r='.database->quote($n1r).',n1e='.database->quote($n1e).',n2r='.database->quote($n2r).',n2e='.database->quote($n2e).',n3r='.database->quote($n3r).',n3e='.database->quote($n3e).',email='.database->quote($email).',phone='.database->quote($phone).',fax='.database->quote($fax).',country='.database->quote($country).',city='.database->quote($city).',state='.database->quote($state).',addr='.database->quote($addr).',postcode='.database->quote($postcode).',passport='.database->quote($passport).',birth_date='.database->quote($birth_date).',addr_ru='.database->quote($addr_ru).',org='.database->quote($org).',org_r='.database->quote($org_r).',code='.database->quote($code).',kpp='.database->quote($kpp).',private='.database->quote($private).',lastchanged='.time
  );
  my $res=$sth->execute();
  $sth->finish();
  if (!$res) {
    return qq~{"result":"0","error":"~.$lang->{db_save_error}.qq~"}~;   
  } else {
    return qq~{"result":"1"}~;   
  }
};

post '/data/hosting/save' => sub {
  my $auth_data = &taracot::_auth();
  content_type 'application/json';
  if (!$auth_data) { return qq~{"result":"0"}~;  }
  my $clng = _load_lang();  
  content_type 'application/json';
  my $haccount=param('haccount') || '';
  my $hplan=param('hplan') || '';
  my $hdays=param('hdays') || 0;
  my $h_queue=param('h_queue') || 0;
  my $hpwd=param('hpwd') || '';
  my $user_id=$auth_data->{id};
  $hdays=int($hdays);
  $hplan=lc($hplan);
  $haccount=lc($haccount);
  if ($haccount !~ /^[A-Za-z0-9]{4,8}$/) {
   return qq~{"result":"0","field":"haccount","error":"~.$lang->{form_error_invalid_haccount}.qq~"}~;
  }
  if ($hpwd !~ /^[A-Za-z0-9_\-\$\!\@\#\%\^\&\[\]\{\}\*\+\=\.\,\'\"\|\<\>\?]{8,100}$/) { 
    return qq~{"result":"0","field":"hpwd","error":"~.$lang->{invalid_password}.qq~"}~;
  }   
  my $hmonths = $hdays;
  $hdays=$hdays*30; 
  if (!$hdays || $hdays > 9999) {
   return qq~{"result":"0","field":"hdays","error":"~.$lang->{form_error_invalid_hdays}.qq~"}~;
  }  
  my $sth = database->prepare(
   'SELECT id FROM '.config->{db_table_prefix}.'_billing_hosting WHERE host_acc='.database->quote($haccount)
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
   'SELECT s_value FROM '.config->{db_table_prefix}.'_settings WHERE s_name='.database->quote('billing_plan_name_'.$hplan)
  );
  my $hplan_name;
  if ($sth->execute()) {
   ($hplan_name) = $sth->fetchrow_array;
  }
  $sth->finish();
  if (!$hplan_name) {
    return qq~{"result":"0","field":"email","error":"~.$lang->{form_error_invalid_hplan}.qq~"}~;
  }
  my $month_cost=0;
  $sth = database->prepare(
    'SELECT s_value FROM `'.config->{db_table_prefix}.'_settings` WHERE s_name=\'billing_plan_cost_'.$hplan.'\''
  );
  if ($sth->execute()) {
    ($month_cost) = $sth -> fetchrow_array();
  }
  $sth->finish();
  my $funds_avail=0;
  $sth = database->prepare(
    'SELECT amount FROM `'.config->{db_table_prefix}.'_billing_funds` WHERE user_id='.$auth_data->{id}
  );
  if ($sth->execute()) {
    ($funds_avail) = $sth -> fetchrow_array();
  }
  $sth->finish();
  if (($month_cost * $hmonths) > $funds_avail) {
    return qq~{"result":"0","error":"~.$lang->{insufficent_funds}.qq~"}~; 
  }
  my $funds_remain = $funds_avail - ($month_cost * $hmonths);
  my $total_cost = $month_cost * $hmonths;
  if ($total_cost > $funds_avail) {
    return qq~{"result":"0","error":"~.$lang->{insufficent_funds}.qq~"}~; 
  }
  require "api/".config->{billing_cpanel_plugin}.".pl";
  my $login_avail = &APICheckLogin($haccount);
  if ($login_avail ne -1) {
    return qq~{"result":"0","field":"haccount","error":"~.$lang->{form_error_duplicate_haccount}.qq~"}~;
  }
  if (!database->quick_insert(config->{db_table_prefix}.'_billing_hosting', { user_id => $user_id, host_acc => $haccount, host_plan_id => $hplan, host_days_remain => $hdays, pwd => $hpwd, in_queue => 1, lastchanged => time })) {
    return qq~{"result":"0","error":"~.$lang->{db_save_error}.qq~"}~; 
  }
  my $id = database->{q{mysql_insertid}}; 
  if (!$id) {
      return qq~{"result":"0","error":"~.$lang->{db_save_error}.qq~1"}~; 
  }  
  if (      
      !database->quick_insert(config->{db_table_prefix}.'_billing_funds_history', { user_id => $user_id, trans_id => 'hostingregister', trans_objects => $haccount, trans_amount => -$total_cost, trans_date => time, lastchanged => time })
       ||
      !database->quick_update(config->{db_table_prefix}.'_billing_funds', { user_id => $user_id }, { amount => $funds_remain, lastchanged => time })
       ||
      !database->quick_insert(config->{db_table_prefix}.'_billing_queue', { user_id => $user_id, action => 'hostingregister', object => $haccount, amount => $total_cost, lang => $clng, tstamp => time }) 
     ) 
  {
    return qq~{"result":"0","error":"~.$lang->{db_save_error}.qq~"}~; 
  }  
  $sth = database->prepare(
   'SELECT s_value FROM '.config->{db_table_prefix}.'_settings WHERE s_name='.database->quote('billing_plan_cost_'.$hplan)
  );
  my $hplan_cost;
  if ($sth->execute()) {
   ($hplan_cost) = $sth->fetchrow_array;
  }
  $sth->finish();
  if (!$hplan_cost) { 
   $hplan_cost="0";
  }
  my %response;
  my $json_xs = JSON::XS->new();  
  $response{result}="1";
  $response{id}=$id;
  $response{haccount}=$haccount;
  $response{hplan}=$hplan;
  $response{hplan_name}=$hplan_name;
  $response{hplan_cost}=$hplan_cost;
  $response{funds_remain} = $funds_remain;
  $response{hdays}=$hdays;
  my $json = $json_xs->encode(\%response);
  return $json;    
};

post '/data/domain/save' => sub {
  my $auth_data = &taracot::_auth();
  content_type 'application/json';
  if (!$auth_data) { return qq~{"result":"0"}~;  }
  my $clng = _load_lang();  
  content_type 'application/json';
  my $domain_name=param('domain_name') || '';
  my $domain_zone=param('domain_zone') || '';
  my $ns1=param('ns1') || '';
  my $ns2=param('ns2') || '';
  my $ns3=param('ns3') || '';
  my $ns4=param('ns4') || '';
  my $ns1_ip=param('ns1_ip') || '';
  my $ns2_ip=param('ns2_ip') || '';
  my $ns3_ip=param('ns3_ip') || '';
  my $ns4_ip=param('ns4_ip') || '';
  my $user_id=$auth_data->{id};
  if ($domain_name !~ /^([a-zA-Z0-9\-]{1,100})$/) {
   return qq~{"result":"0","field":"domain_name","error":"~.$lang->{form_error_invalid_domain_name}.qq~"}~;
  }
  if ($domain_zone !~ /^([a-z]{1,8})$/) {
   return qq~{"result":"0","field":"domain_zone","error":"~.$lang->{form_error_invalid_domain_zone}.qq~"}~;
  }
  if ($ns1 !~ /^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ || length($ns1) > 80) {
   return qq~{"result":"0","field":"ns1","error":"~.$lang->{form_error_invalid_ns}.qq~"}~;
  }
  if ($ns2 !~ /^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ || length($ns2) > 80) {
   return qq~{"result":"0","field":"ns2","error":"~.$lang->{form_error_invalid_ns}.qq~"}~;
  }
  if ($ns3 && $ns3 !~ /^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ || length($ns3) > 80) {
   return qq~{"result":"0","field":"ns3","error":"~.$lang->{form_error_invalid_ns}.qq~"}~;
  }
  if ($ns4 && $ns4 !~ /^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ || length($ns4) > 80) {
   return qq~{"result":"0","field":"ns4","error":"~.$lang->{form_error_invalid_ns}.qq~"}~;
  }
  if ($ns1_ip && $ns1_ip !~ /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/ || length($ns1_ip) > 42) {
   return qq~{"result":"0","field":"ns1_ip","error":"~.$lang->{form_error_invalid_ns}.qq~"}~;
  }
  if ($ns2_ip && $ns2_ip !~ /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/ || length($ns2_ip) > 42) {
   return qq~{"result":"0","field":"ns2_ip","error":"~.$lang->{form_error_invalid_ns}.qq~"}~;
  }
  if ($ns3_ip && $ns3_ip !~ /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/ || length($ns3_ip) > 42) {
   return qq~{"result":"0","field":"ns3_ip","error":"~.$lang->{form_error_invalid_ns}.qq~"}~;
  }
  if ($ns4_ip && $ns4_ip !~ /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/ || length($ns4_ip) > 42) {
   return qq~{"result":"0","field":"ns4_ip","error":"~.$lang->{form_error_invalid_ns}.qq~"}~;
  }
  my $sth = database->prepare(
   'SELECT id FROM '.config->{db_table_prefix}.'_billing_domains WHERE domain_name='.database->quote($domain_name.'.'.$domain_zone)
  );
  if ($sth->execute()) {
   my ($tmpid) = $sth->fetchrow_array;
   if ($tmpid) {
    $sth->finish();
    return qq~{"result":"0","field":"domain_name","error":"~.$lang->{form_error_duplicate_domain}.qq~"}~;
   }
  }
  $sth->finish();
  $sth = database->prepare(
   'SELECT s_value FROM '.config->{db_table_prefix}.'_settings WHERE s_name='.database->quote('billing_domain_zone_'.$domain_zone)
  );
  my $zone_cost;
  if ($sth->execute()) {
   ($zone_cost) = $sth->fetchrow_array;
  }
  $sth->finish();
  if (!$zone_cost) {
    return qq~{"result":"0","field":"email","error":"~.$lang->{form_error_invalid_domain_zone}.qq~"}~;
  }
  $zone_cost=~s/\s//gm;
  my ($reg_cost, $up_cost)=split(/,/, $zone_cost);
  my $profile_hash;
  $sth = database->prepare(
   'SELECT id,n1r,n1e,n2r,n2e,n3r,n3e,email,phone,fax,country,city,state,addr,postcode,passport,birth_date,addr_ru,org,org_r,code,kpp,private FROM '.config->{db_table_prefix}.'_billing_profiles WHERE user_id='.$auth_data->{id}
  );
  if ($sth->execute()) {
   $profile_hash = $sth->fetchrow_hashref;
  }
  $sth->finish();
  if (!$profile_hash->{id}) {
    return qq~{"result":"0","field":"domain_name","error":"~.$lang->{incomplete_profile}.qq~"}~;  
  }
  if (!$profile_hash->{n1e} || !$profile_hash->{n2e} || !$profile_hash->{n3e} || !$profile_hash->{email} || !$profile_hash->{phone} || !$profile_hash->{country} || !$profile_hash->{city} || !$profile_hash->{state} || !$profile_hash->{addr} || !$profile_hash->{postcode} || !$profile_hash->{birth_date}) {
    return qq~{"result":"0","field":"domain_name","error":"~.$lang->{incomplete_profile}.qq~"}~;  
  }
  if (($domain_zone eq 'ru' || $domain_zone eq 'su') && (!$profile_hash->{n1r} || !$profile_hash->{n2r} || !$profile_hash->{n3r} || !$profile_hash->{passport} || !$profile_hash->{addr_ru})) {
    return qq~{"result":"0","field":"domain_name","error":"~.$lang->{incomplete_profile}.qq~"}~;  
  }
  my $funds_avail=0;
  $sth = database->prepare(
    'SELECT amount FROM `'.config->{db_table_prefix}.'_billing_funds` WHERE user_id='.$auth_data->{id}
  );
  if ($sth->execute()) {
    ($funds_avail) = $sth -> fetchrow_array();
  }
  $sth->finish();
  if ($reg_cost > $funds_avail) {
    return qq~{"result":"0","error":"~.$lang->{insufficent_funds}.qq~"}~; 
  }
  my $funds_remain = $funds_avail - $reg_cost;
  if ($reg_cost > $funds_avail) {
    return qq~{"result":"0","error":"~.$lang->{insufficent_funds}.qq~"}~; 
  }
  eval { require $domain_panel_plugin; };
  if ($@) {   
    return qq~{"result":"0","field":"domain_name","error":"~.$lang->{form_error_duplicate_domain}.qq~"}~;
  }
  my $avail = &APICheckDomainAvailability($domain_name.'.'.$domain_zone);
  if (!$avail) {
    return qq~{"result":"0","field":"domain_name","error":"~.$lang->{form_error_duplicate_domain}.qq~"}~;
  }

  my $exp_date = time + 31557600; # 1 year
  my $remote_ip = request->env->{'HTTP_X_REAL_IP'} || request->env->{'REMOTE_ADDR'} || '';
  if (!$remote_ip) {
    return qq~{"result":"0","error":"~.$lang->{db_save_error}.qq~"}~; 
  }
  if (!database->quick_insert(config->{db_table_prefix}.'_billing_domains', { user_id => $user_id, domain_name => $domain_name.'.'.$domain_zone, exp_date => $exp_date, ns1 => $ns1, ns2 => $ns2, ns3 => $ns3, ns4 => $ns4, ns1_ip => $ns1_ip, ns2_ip => $ns2_ip, ns3_ip => $ns3_ip, ns4_ip => $ns4_ip, remote_ip => $remote_ip, in_queue => 1, lastchanged => time })) {
    return qq~{"result":"0","error":"~.$lang->{db_save_error}.qq~"}~; 
  }
  my $id = database->{q{mysql_insertid}}; 
  if (!$id) {
      return qq~{"result":"0","error":"~.$lang->{db_save_error}.qq~1"}~; 
  }  
  if (      
      !database->quick_insert(config->{db_table_prefix}.'_billing_funds_history', { user_id => $user_id, trans_id => 'domainregister', trans_objects => $domain_name.'.'.$domain_zone, trans_amount => -$reg_cost, trans_date => time, lastchanged => time })
       ||
      !database->quick_update(config->{db_table_prefix}.'_billing_funds', { user_id => $user_id }, { amount => $funds_remain, lastchanged => time })
       ||
      !database->quick_insert(config->{db_table_prefix}.'_billing_queue', { user_id => $user_id, action => 'domainregister', object => $domain_name.'.'.$domain_zone, amount => $reg_cost, lang => $clng, tstamp => time })
     ) 
  {
    return qq~{"result":"0","error":"~.$lang->{db_save_error}.qq~"}~; 
  }  
  my %response;
  my $json_xs = JSON::XS->new();  
  $response{result}="1";
  $response{id}=$id;
  $response{domain_name}=$domain_name.'.'.$domain_zone;
  $response{zone}=$domain_zone;
  $response{funds_remain} = $funds_remain;
  $response{exp_date} = time2str($lang->{domain_date_template}, $exp_date);
  $response{exp_date} =~s/\\//gm;
  my $json = $json_xs->encode(\%response);
  return $json;    
};

post '/data/hosting/update/save' => sub {
  my $auth_data = &taracot::_auth();
  content_type 'application/json';
  if (!$auth_data) { return qq~{"result":"0"}~;  }
  my $clng = _load_lang();  
  content_type 'application/json';
  my $haccount=param('haccount') || '';
  my $hdays=param('hdays') || 0;
  my $user_id=$auth_data->{id};
  $hdays=int($hdays);
  $haccount=lc($haccount);
  if ($haccount !~ /^[A-Za-z0-9]{4,8}$/) {
   return qq~{"result":"0","field":"haccount","error":"~.$lang->{form_error_invalid_haccount}.qq~"}~;
  }
  my $hmonths = $hdays; 
  $hdays=$hdays*30; 
  if (!$hdays || $hdays > 9999) {
   return qq~{"result":"0","field":"hdays","error":"~.$lang->{form_error_invalid_hdays}.qq~"}~;
  }  
  my $sth = database->prepare(
   'SELECT id, user_id, host_days_remain, host_plan_id, in_queue FROM '.config->{db_table_prefix}.'_billing_hosting WHERE host_acc='.database->quote($haccount)
  );
  my $old_days=0;
  my ($db_user_id, $id, $plan_id, $in_queue);
  if ($sth->execute()) {
   ($id, $db_user_id, $old_days, $plan_id, $in_queue) = $sth->fetchrow_array;
   if (!$db_user_id || $db_user_id ne $user_id) {
    $sth->finish();
    return qq~{"result":"0","field":"haccount","error":"~.$lang->{access_denied}.qq~"}~;
   }
  } else {
    return qq~{"result":"0","field":"haccount","error":"~.$lang->{access_denied}.qq~"}~;
  }
  $sth->finish();
  if ($in_queue) {
    return qq~{"result":"0","field":"haccount","error":"~.$lang->{queue_task_active}.qq~"}~; 
  }
  my $month_cost=0;
  $sth = database->prepare(
    'SELECT s_value FROM `'.config->{db_table_prefix}.'_settings` WHERE s_name=\'billing_plan_cost_'.$plan_id.'\''
  );
  if ($sth->execute()) {
    ($month_cost) = $sth -> fetchrow_array();
  }
  $sth->finish();
  my $funds_avail=0;
  $sth = database->prepare(
    'SELECT amount FROM `'.config->{db_table_prefix}.'_billing_funds` WHERE user_id='.$auth_data->{id}
  );
  if ($sth->execute()) {
    ($funds_avail) = $sth -> fetchrow_array();
  }
  $sth->finish();
  my $total_cost = $month_cost * $hmonths;
  if ($total_cost > $funds_avail) {
    return qq~{"result":"0","error":"~.$lang->{insufficent_funds}.qq~"}~; 
  }
  my $funds_remain = $funds_avail - $total_cost;
  if (
      !database->quick_update(config->{db_table_prefix}.'_billing_hosting', { host_acc => $haccount }, { host_days_remain => $hdays + $old_days, host_days_last => $hdays, in_queue => 1, error_msg => '', lastchanged => time })
       ||      
      !database->quick_insert(config->{db_table_prefix}.'_billing_funds_history', { user_id => $user_id, trans_id => 'hostingupdate', trans_objects => $haccount, trans_amount => -$total_cost, trans_date => time, lastchanged => time })
       ||
      !database->quick_update(config->{db_table_prefix}.'_billing_funds', { user_id => $user_id }, { amount => $funds_remain, lastchanged => time })
       ||
      !database->quick_insert(config->{db_table_prefix}.'_billing_queue', { user_id => $user_id, action => 'hostingupdate', object => $haccount, amount => $total_cost, lang => $clng, tstamp => time })
     ) {
    return qq~{"result":"0","error":"~.$lang->{db_save_error}.qq~"}~; 
  }
  my %response;
  my $json_xs = JSON::XS->new();  
  $response{result}="1";
  $response{id}=$id;
  $response{haccount}=$haccount;
  $response{hdays}=$hdays+$old_days;
  $response{funds_remain} = $funds_remain;
  my $json = $json_xs->encode(\%response);
  return $json;    
};

post '/data/service/update/save' => sub {
  my $auth_data = &taracot::_auth();
  content_type 'application/json';
  if (!$auth_data) { return qq~{"result":"0"}~;  }
  _load_lang();  
  content_type 'application/json';
  my $sid=param('sid') || '';
  my $sdays=param('sdays') || 0;
  my $user_id=$auth_data->{id};
  $sdays=int($sdays);
  $sid=lc($sid);
  if ($sid !~ /^[a-z0-9]{1,40}$/) {
   return qq~{"result":"0","field":"sn","error":"~.$lang->{form_error_invalid_sid}.qq~"}~;
  }
  my $smonths = $sdays; 
  $sdays=$sdays*30; 
  if (!$sdays || $sdays > 9999) {
   return qq~{"result":"0","field":"sdays","error":"~.$lang->{form_error_invalid_sdays}.qq~"}~;
  }  
  my $sth = database->prepare(
   'SELECT user_id, service_days_remaining FROM '.config->{db_table_prefix}.'_billing_services WHERE service_id='.database->quote($sid)
  );
  my $old_days=0;
  my $suid;
  if ($sth->execute()) {
   ($suid, $old_days) = $sth->fetchrow_array;
   if (!$suid || $suid ne $user_id) {
    $sth->finish();
    return qq~{"result":"0","field":"haccount","error":"~.$lang->{access_denied}.qq~"}~;
   }
  } else {
    return qq~{"result":"0","field":"haccount","error":"~.$lang->{access_denied}.qq~"}~;
  }
  $sth->finish();
  my $month_cost=0;
  $sth = database->prepare(
    'SELECT s_value FROM `'.config->{db_table_prefix}.'_settings` WHERE s_name=\'billing_service_cost_'.$sid.'\''
  );
  if ($sth->execute()) {
    ($month_cost) = $sth -> fetchrow_array();
  }
  $sth->finish();
  my $funds_avail=0;
  $sth = database->prepare(
    'SELECT amount FROM `'.config->{db_table_prefix}.'_billing_funds` WHERE user_id='.$user_id
  );
  if ($sth->execute()) {
    ($funds_avail) = $sth -> fetchrow_array();
  }
  $sth->finish();
  my $total_cost = $month_cost * $smonths;
  if ($total_cost > $funds_avail) {
    return qq~{"result":"0","error":"~.$lang->{insufficent_funds}.qq~"}~; 
  }
  my $funds_remain = $funds_avail - $total_cost;
  if (
      !database->quick_update(config->{db_table_prefix}.'_billing_services', { service_id => $sid }, { service_days_remaining => $sdays + $old_days, lastchanged => time })
       ||
      !database->quick_insert(config->{db_table_prefix}.'_billing_funds_history', { user_id => $user_id, trans_id => 'serviceupdate', trans_objects => $sid, trans_amount => -$total_cost, trans_date => time, lastchanged => time })
       ||
      !database->quick_update(config->{db_table_prefix}.'_billing_funds', { user_id => $user_id }, { amount => $funds_remain, lastchanged => time })
     ) {
    return qq~{"result":"0","error":"~.$lang->{db_save_error}.qq~"}~; 
  }
  my %response;
  my $json_xs = JSON::XS->new();  
  $response{result}="1";
  $response{sid}=$sid;
  $response{sdays}=$sdays+$old_days;
  $response{funds_remain} = $funds_remain;
  my $json = $json_xs->encode(\%response);
  return $json;    
};

post '/data/domain/update/save' => sub {
  my $auth_data = &taracot::_auth();
  content_type 'application/json';
  if (!$auth_data) { return qq~{"result":"0"}~;  }
  my $clng = _load_lang();  
  content_type 'application/json';
  my $domain_name=param('domain_name') || '';
  my $user_id=$auth_data->{id};
  $domain_name=lc($domain_name);
  if ($domain_name !~ /^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,6}$/) {
   return qq~{"result":"0","field":"domain_name","error":"~.$lang->{form_error_invalid_domain_name}.qq~"}~;
  }  
  my $sth = database->prepare(
   'SELECT id, exp_date, user_id, in_queue FROM '.config->{db_table_prefix}.'_billing_domains WHERE domain_name='.database->quote($domain_name)
  );
  my ($id, $exp_date, $domain_user_id, $in_queue);
  if ($sth->execute()) {
   ($id, $exp_date, $domain_user_id, $in_queue) = $sth->fetchrow_array;
  } else {
    return qq~{"result":"0","field":"domain_name","error":"~.$lang->{form_error_invalid_domain_name}.qq~"}~;
  }
  $sth->finish();  
  if (!$id) {
    return qq~{"result":"0","field":"domain_name","error":"~.$lang->{form_error_invalid_domain_name}.qq~"}~;
  }
  if ($domain_user_id ne $user_id) {
    return qq~{"result":"0","field":"domain_name","error":"~.$lang->{access_denied}.qq~"}~;
  }
  if ($in_queue) {
    return qq~{"result":"0","field":"domain_name","error":"~.$lang->{queue_task_active}.qq~"}~; 
  }
  my $zone=$domain_name;
  $zone=~s/^[^\.]*\.//;
  my $cost;
  my $cost_up;
  $sth = database->prepare(
    'SELECT s_value FROM `'.config->{db_table_prefix}.'_settings` WHERE s_name=\'billing_domain_zone_'.$zone.'\''
  );
  if ($sth->execute()) {
    ($cost) = $sth -> fetchrow_array();
  }
  $sth->finish();
  $cost=~s/\s//gm;
  ($cost, $cost_up) = split(/,/, $cost);
  if (!$cost_up) {
    $cost_up = $cost;
  }
  if (!$cost_up) {
    return qq~{"result":"0","error":"~.$lang->{db_save_error}.qq~"}~; 
  }
  my $funds_avail;
  $sth = database->prepare(
    'SELECT amount FROM `'.config->{db_table_prefix}.'_billing_funds` WHERE user_id='.$user_id
  );
  if ($sth->execute()) {
    ($funds_avail) = $sth -> fetchrow_array();
  }
  $sth->finish();
  my $total_cost = $cost_up;
  if ($total_cost > $funds_avail) {
    return qq~{"result":"0","error":"~.$lang->{insufficent_funds}.qq~"}~; 
  }
  my $allow_update='0';
  if ((($zone eq 'ru' || $zone eq 'su') && ( $exp_date - time < 4838400)) || ($zone ne 'ru' && $zone ne 'su')) {
    $allow_update='1';
  }
  if (!$allow_update) {
    return qq~{"result":"0","error":"~.$lang->{cant_update}.qq~"}~;   
  }
  $exp_date = $exp_date + 31557600; # 1 year
  my $funds_remain = $funds_avail - $total_cost;
  if (
      !database->quick_update(config->{db_table_prefix}.'_billing_domains', { id => $id }, { exp_date => $exp_date, in_queue => 1, error_msg => '', lastchanged => time })
       ||      
      !database->quick_insert(config->{db_table_prefix}.'_billing_funds_history', { user_id => $user_id, trans_id => 'domainupdate', trans_objects => $domain_name, trans_amount => -$total_cost, trans_date => time, lastchanged => time })
       ||
      !database->quick_update(config->{db_table_prefix}.'_billing_funds', { user_id => $user_id }, { amount => $funds_remain, lastchanged => time })
       ||
      !database->quick_insert(config->{db_table_prefix}.'_billing_queue', { user_id => $user_id, action => 'domainupdate', object => $domain_name, amount => $total_cost, lang => $clng, tstamp => time })
     ) {
    return qq~{"result":"0","error":"~.$lang->{db_save_error}.qq~"}~; 
  }
  my %response;
  my $json_xs = JSON::XS->new();  
  $response{result}="1";
  $response{id}=$id;
  $response{domain_name}=$domain_name;
  $response{exp_date}=$exp_date;
  $response{exp_date} = time2str($lang->{domain_date_template}, $exp_date);
  $response{exp_date} =~s/\\//gm;
  $response{funds_remain} = $funds_remain;
  my $json = $json_xs->encode(\%response);
  return $json;    
};

any '/data/queue' => sub {
  my $auth_data = &taracot::_auth();
  content_type 'application/json';
  if (!$auth_data) { return qq~{"result":"0"}~;  }
  _load_lang();  
  content_type 'application/json';  
  my @qdata;
  my @hosting;
  my @domains;
  my $data;
  my $sth = database->prepare(
   'SELECT id, action, object, tstamp FROM '.config->{db_table_prefix}.'_billing_queue WHERE user_id='.$auth_data->{id}
  );
  if ($sth->execute()) {
   while (my $data = $sth->fetchrow_hashref) {
    push @qdata, $data;
   }
  }
  $sth->finish();
  $sth = database->prepare(
   'SELECT host_acc, host_days_remain, error_msg FROM '.config->{db_table_prefix}.'_billing_hosting WHERE user_id='.$auth_data->{id}
  );
  if ($sth->execute()) {
   while (my ($acc, $days, $error_msg) = $sth->fetchrow_array) {
    my %hsh;
    $hsh{host_acc} = $acc;
    $hsh{host_days_remain} = $days;
    $hsh{error_msg} = $error_msg;
    push @hosting, \%hsh;    
   }
  }
  $sth->finish();
  $sth = database->prepare(
   'SELECT domain_name, exp_date, error_msg FROM '.config->{db_table_prefix}.'_billing_domains WHERE user_id='.$auth_data->{id}
  );
  if ($sth->execute()) {
   while (my ($dn, $exp, $error_msg) = $sth->fetchrow_array) {
    my %hsh;
    $hsh{domain_name} = $dn;
    if ($exp <= time) {
     $hsh{expired} = 1;
    } else {
     $hsh{expired} = 0;
    }
    $exp =  time2str($lang->{domain_date_template}, $exp);
    $exp =~s/\\//gm;
    $hsh{exp_date} = $exp;
    $hsh{error_msg} = $error_msg;
    push @domains, \%hsh;
   }
  }
  $sth->finish();
  my $funds_avail;
  $sth = database->prepare(
    'SELECT amount FROM `'.config->{db_table_prefix}.'_billing_funds` WHERE user_id='.$auth_data->{id}
  );
  if ($sth->execute()) {
    ($funds_avail) = $sth -> fetchrow_array();
  }
  $sth->finish();
  my %response;
  $response{queue}=\@qdata;
  $response{hosting}=\@hosting;
  $response{domains}=\@domains;
  $response{funds}=$funds_avail;
  my $json_xs = JSON::XS->new();  
  my $json = $json_xs->encode(\%response);
  return $json;    
};

# End

true;