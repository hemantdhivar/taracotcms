package modules::billing::main;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use JSON::XS();
use Digest::MD5 qw(md5_hex);
use Date::Format;
use Date::Parse;

# Configuration

my $defroute = '/admin/billing';
my @columns = ('u.id','u.username','u.realname', 'u.email','f.amount');
my @columns_mobile = ('u.id','u.username','f.amount');
my @columns_funds = ('id', 'trans_objects','trans_amount', 'trans_date');

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
  $response{hosting_plans} = \@hosting_plans;
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
    database->quick_update(config->{db_table_prefix}.'_billing_hosting', { id => $id }, { host_acc => $haccount, host_plan_id => $hplan, host_days_remain => $hdays, lastchanged => time });
  } else {   
    database->quick_insert(config->{db_table_prefix}.'_billing_hosting', { user_id => $auth->{id}, host_acc => $haccount, host_plan_id => $hplan, host_days_remain => $hdays, lastchanged => time });
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
  my $id=param('id') || 0;
  $id=int($id);
  $domain_name=lc($domain_name);
  if ($domain_name !~ /^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,6}$/) {
   return qq~{"result":"0","field":"domain_name","error":"~.$lang->{form_error_invalid_domain_name}.qq~"}~;
  }
  if ($domain_exp !~ /^[0-9\.\/\-]{1,12}$/) {
   return qq~{"result":"0","field":"domain_exp","error":"~.$lang->{form_error_invalid_domain_exp}.qq~"}~;
  }
  $domain_exp = str2time($domain_exp);
  if (!$domain_exp) {
   return qq~{"result":"0","field":"domain_exp","error":"~.$lang->{form_error_invalid_domain_exp}.qq~"}~; 
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
    database->quick_update(config->{db_table_prefix}.'_billing_domains', { id => $id }, { domain_name => $domain_name, exp_date => $domain_exp, lastchanged => time });
  } else {   
    database->quick_insert(config->{db_table_prefix}.'_billing_domains', { user_id => $auth->{id}, domain_name => $domain_name, exp_date => $domain_exp, lastchanged => time });
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
   'SELECT host_acc, host_plan_id, host_days_remain FROM '.config->{db_table_prefix}.'_billing_hosting WHERE id='.$id
  );
  my ($haccount, $hplan, $hdays);
  if ($sth->execute()) {
   ($haccount, $hplan, $hdays) = $sth->fetchrow_array;
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
   'SELECT domain_name,exp_date FROM '.config->{db_table_prefix}.'_billing_domains WHERE id='.$id
  );
  my ($domain_name,$exp_date);
  if ($sth->execute()) {
   ($domain_name,$exp_date) = $sth->fetchrow_array;
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

# End

true;