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
  _load_lang();
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
  # load hosting plan names from settings
  
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

# End

true;