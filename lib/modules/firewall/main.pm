package modules::firewall::main;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use JSON::XS();
use Digest::MD5 qw(md5_hex);

# Configuration

my $defroute = '/admin/firewall';
my @columns = ('id','ipaddr','status');
my @columns_mobile = ('id','ipaddr','status');
my @columns_ft = ('ipaddr');

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
  my $lang_adm = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/firewall/lang/en.lng') || {};
  my $lang_adm_cnt={};
  if ($lng ne 'en') {
   $lang_adm_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/firewall/lang/'.$lng.'.lng') || {};
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
  return template 'admin_firewall_index', { lang => $lang, navdata => $navdata, authdata => $auth }, { layout => 'admin' };
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
   'SELECT COUNT(*) AS cnt FROM '.config->{db_table_prefix}.'_firewall WHERE 1'
  );
  if ($sth->execute()) {
   ($total) = $sth -> fetchrow_array;
  }
  $sth->finish();
  my $total_filtered=0;
  if ($where ne '1' && $total > 0) {
   my $sth = database->prepare(
    'SELECT COUNT(*) AS cnt FROM '.config->{db_table_prefix}.'_firewall WHERE '.$where
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
   'SELECT '.$columns.' FROM '.config->{db_table_prefix}.'_firewall WHERE '.$where.$sortorder.' LIMIT '.$iDisplayStart.', '.$iDisplayLength
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
  my $ipaddr=param('ipaddr') || '';
  my $status=param('status') || 0;
  $status=int($status);
  my $id=param('id') || 0;
  $id=int($id);
  
  if ($ipaddr !~ /^[A-Fa-f0-9\.\:]{1,45}$/) {
   return qq~{"result":"0","field":"ipaddr","error":"~.$lang->{form_error_invalid_ipaddr}.qq~"}~;
  }
  if ($status < 0 || $status > 1) {
   return qq~{"result":"0","error":"~.$lang->{form_error_invalid_status}.qq~"}~;
  }
  
  my $dupesql='';
  if ($id > 0) {
   $dupesql=' AND id != '.$id;
  }
  
  my $sth = database->prepare(
   'SELECT id FROM '.config->{db_table_prefix}.'_firewall WHERE ipaddr='.database->quote($ipaddr).$dupesql
  );
  if ($sth->execute()) {
   my ($tmpid) = $sth->fetchrow_array;
   if ($tmpid) {
    $sth->finish();
    return qq~{"result":"0","field":"ipaddr","error":"~.$lang->{form_error_duplicate_ipaddr}.qq~"}~;
   }
  }
  $sth->finish();

  if ($id > 0) {
    database->quick_update(config->{db_table_prefix}.'_firewall', { id => $id }, { ipaddr => $ipaddr, status => $status, lastchanged => time });
  } else {   
    database->quick_insert(config->{db_table_prefix}.'_firewall', { ipaddr => $ipaddr, status => $status, lastchanged => time });
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
  
  if ($field_name ne 'ipaddr' && $field_name ne 'status' ) {
   return '{"result":"0", "error":"'.$lang->{field_edit_error_unknown}.'"}'; 
  }
  
  # Check IP address
  
  if ($field_name eq 'ipaddr') {
   my $ipaddr=$field_value;
   if ($ipaddr !~ /^[A-Fa-f0-9\.\:]{1,45}$/) {
    return qq~{"result":"0","error":"~.$lang->{form_error_invalid_ipaddr}.qq~"}~;
   }
   my $sth = database->prepare(
    'SELECT id FROM '.config->{db_table_prefix}.'_firewall WHERE ipaddr='.database->quote($ipaddr).' AND id != '.$field_id
   );
   if ($sth->execute()) {
    my ($tmpid) = $sth->fetchrow_array;
    if ($tmpid) {
     $sth->finish();
     return qq~{"result":"0","error":"~.$lang->{form_error_duplicate_ipaddr}.qq~"}~;
    }
   }
   $sth->finish();
   database->quick_update(config->{db_table_prefix}.'_firewall', { id => $field_id }, { ipaddr => $ipaddr, lastchanged => time });
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
   database->quick_update(config->{db_table_prefix}.'_firewall', { id => $field_id }, { status => $status, lastchanged => time });
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
  
  my $db_data  = database->quick_select(config->{db_table_prefix}.'_firewall', { id => $id });
  
  if ($db_data->{id}) {
   $db_data->{result} = 1;
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
     'DELETE FROM '.config->{db_table_prefix}.'_firewall WHERE '.$del_sql
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