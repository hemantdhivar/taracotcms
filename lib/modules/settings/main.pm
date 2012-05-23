package modules::settings::main;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use JSON::XS();
use Digest::MD5 qw(md5_hex);

# Configuration

my $defroute = '/admin/settings';
my @columns = ('id','s_name','s_value','lang');
my @columns_ft = ('s_name','s_value');

# Module core settings 

my $navdata;
my $authdata;
my $lang;

sub _name() {
  _load_lang();
  return $lang->{module_name};
}           
sub _defroute() {
  return $defroute;
}
sub _navdata() {
  $navdata=$_[1];
}
sub _auth() {
  _load_lang();
  if (session('user')) { 
   my $id = session('user');
   $authdata  = database->quick_select(config->{db_table_prefix}."_users", { id => $id });
  } else {
   $authdata->{id} = 0;
   $authdata->{status} = 0;
   $authdata->{username} = '';
   $authdata->{password} = '';
  }                                                                    
  if ($authdata->{status}) {
   if ($authdata->{status} == 2) {
    return true;
   }
  }
  redirect '/admin';
  return false;
};

sub _load_lang {
  my $lng = config->{lang_default};;
  if (defined request) {
    my $_uribase=request->uri_base();
    $_uribase=~s/http(s)?\:\/\///im;
    my ($lang)=split(/\./, $_uribase);
    my $lang_avail=lc config->{lang_available};
    $lang_avail=~s/ //gm;
    my (@langs)=split(/,/, $lang_avail);
    if (exists {map { $_ => 1 } @langs}->{$lang}) {
     $lng=$lang;
    }                 
  }
  my $lang_adm = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/settings/lang/'.$lng.'.lng');
  my $lang_mod = YAML::XS::LoadFile(config->{root_dir}.'lib/taracot/lang/'.$lng.'.lng');
  if (defined $lang_adm && defined $lang_mod) {
   $lang = { %$lang_adm, %$lang_mod };
  }
  return $lng;
}

# Backend Routes

prefix $defroute;

get '/' => sub {

  # Important! Access control
  if (!_auth()) { return true; }
  # End: Important! Access control
  
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
  return template 'settings_index', { lang => $lang, navdata => $navdata, authdata => $authdata, list_layouts => $list_layouts, list_langs => $list_langs, hash_langs => $hash_langs }, { layout => 'admin' };
  
};

get '/data/list' => sub {
  # Important! Access control
  if (!_auth()) { return true; }
  # End: Important! Access control
  
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
   'SELECT COUNT(*) AS cnt FROM '.config->{db_table_prefix}.'_settings WHERE 1'
  );
  if ($sth->execute()) {
   ($total) = $sth -> fetchrow_array;
  }
  $sth->finish();
  my $total_filtered=0;
  if ($where ne '1' && $total > 0) {
   my $sth = database->prepare(
    'SELECT COUNT(*) AS cnt FROM '.config->{db_table_prefix}.'_settings WHERE '.$where
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
  my $columns=join(',',@columns);
  $columns=~s/,$//;
  $sth = database->prepare(
   'SELECT '.$columns.' FROM '.config->{db_table_prefix}.'_settings WHERE '.$where.$sortorder.' LIMIT '.$iDisplayStart.', '.$iDisplayLength
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
  # Important! Access control
  if (!_auth()) { return true; }
  # End: Important! Access control
  
  content_type 'application/json';
  
  my $s_name=param('s_name') || '';
  my $s_value=param('s_value') || '';
  my $plang=param('lang') || '';
  my $id=param('id') || 0;
  $id=int($id);
  
  $s_name=~s/[\n\r ]//gm;
  if ($s_name !~ /^[A-Za-z0-9_\-]{1,254}$/) {
   return qq~{"result":"0","field":"s_name","error":"~.$lang->{form_error_invalid_s_name}.qq~"}~;
  }
  $s_value=~s/\"/&quot;/gm;
  $s_value=~s/\</&lt;/gm;
  $s_value=~s/\>/&gt;/gm;
  $s_value=~s/\&/&amp;/gm;
  if (length($s_value) > 1048576) {
   return qq~{"result":"0","field":"s_value","error":"~.$lang->{form_error_invalid_s_value}.qq~"}~;
  }

  my $lang_avail=lc config->{lang_available};
  $lang_avail=~s/ //gm;
  my (@langs)=split(/,/, $lang_avail);
  if (!exists {map { $_ => 1 } @langs}->{$plang}) {
   return qq~{"result":"0","error":"~.$lang->{form_error_invalid_lang}.qq~"}~;
  }
  my $sth;
  my $s_name_tmp;
  $sth = database->prepare(
   'SELECT s_name FROM '.config->{db_table_prefix}.'_settings WHERE id = '.$id
  );
  if ($sth->execute()) {
   ($s_name_tmp) = $sth->fetchrow_array;
  }
  $sth->finish();  
  if ($s_name_tmp) {
    $sth = database->prepare(
     'SELECT id FROM '.config->{db_table_prefix}.'_settings WHERE s_name = '.database->quote($s_name).' AND id != '.$id.' AND lang = '.database->quote($plang)
    );
    if ($sth->execute()) {
     my ($tmpid) = $sth->fetchrow_array;
      if ($tmpid) {
       $sth->finish();
       return qq~{"result":"0","field":"s_name","error":"~.$lang->{form_error_duplicate_s_name}.qq~"}~;
      }
    }
    $sth->finish();
  }
  
  if ($id > 0) {
   database->quick_update(config->{db_table_prefix}.'_settings', { id => $id }, { s_name => $s_name, s_value => $s_value, lang => $plang, lastchanged => time });
  } else {   
   database->quick_insert(config->{db_table_prefix}.'_settings', { s_name => $s_name, s_value => $s_value, lang => $plang, lastchanged => time });
  }
      
  return qq~{"result":"1"}~;
};

post '/data/save/field' => sub {
  # Important! Access control
  if (!_auth()) { return true; }
  # End: Important! Access control
  
  content_type 'application/json';

  my $field_name=param('field_name') || '';
  my $field_id=param('field_id') || 0;
  $field_id=int($field_id);
  my $field_value=param('field_value') || '';

  # Pre-check all fields
  
  if ($field_name ne 's_name' && $field_name ne 's_value' && $field_name ne 'lang') {
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
   my $s_name;
   $sth = database->prepare(
    'SELECT s_name FROM '.config->{db_table_prefix}.'_settings WHERE id = '.$field_id
   );
   if ($sth->execute()) {
    ($s_name) = $sth->fetchrow_array;
   }
   $sth->finish();
   if (!$s_name) {
    return qq~{"result":"0","error":"~.$lang->{field_edit_error_unknown}.qq~"}~;
   }
   $sth = database->prepare(
    'SELECT id FROM '.config->{db_table_prefix}.'_settings WHERE s_name = '.database->quote($s_name).' AND lang = '.database->quote($field_value)
   );
   if ($sth->execute()) {
    my ($tmpid) = $sth->fetchrow_array;
    if ($tmpid) {
     $sth->finish();
     return qq~{"result":"0","error":"~.$lang->{form_error_duplicate_s_name}.qq~"}~;
    }
   }
   $sth->finish();
    database->quick_update(config->{db_table_prefix}.'_settings', { id => $field_id }, { lang => $field_value, lastchanged => time });
    return '{"result":"1"}';
   }
   
  # Check s_name
  
  if ($field_name eq 's_name') {
   my $s_name=$field_value;
   $s_name=~s/[\n\r ]//gm;
   if ($s_name !~ /^[A-Za-z0-9_\-]{1,254}$/) {
    return qq~{"result":"0","error":"~.$lang->{form_error_invalid_s_name}.qq~"}~;
   }
   database->quick_update(config->{db_table_prefix}.'_settings', { id => $field_id }, { s_name => $s_name, lastchanged => time });
   return '{"result":"1"}';
  }
  
  # Check s_value
  
  if ($field_name eq 's_value') {
   my $s_value=$field_value;
   if ($s_value ne '/') {
    # remove dupe chars
    $s_value=~s/(\/)\1+/$1/gi;
    # remove slash at the end
    $s_value = $1 if ($s_value=~/(.*)\/$/);
    # remove slash at the beginning
    $s_value = $1 if ($s_value=~/^\/(.*)/);
   }
   $s_value=~s/\"/&quot;/gm;
   $s_value=~s/\</&lt;/gm;
   $s_value=~s/\>/&gt;/gm;
   $s_value=~s/\&/&amp;/gm;
   if (length($s_value) > 1048576) {
    return qq~{"result":"0","field":"s_value","error":"~.$lang->{form_error_invalid_s_value}.qq~"}~;
   }
   
   my $page_data  = database->quick_select(config->{db_table_prefix}.'_settings', { id => $field_id });
   
   my $sth = database->prepare(
    'SELECT id FROM '.config->{db_table_prefix}.'_settings WHERE s_value='.database->quote($s_value).' AND id != '.$field_id.' AND lang='.database->quote($page_data->{lang})
   );
   if ($sth->execute()) {
    my ($tmpid) = $sth->fetchrow_array;
    if ($tmpid) {
     $sth->finish();
     return qq~{"result":"0","error":"~.$lang->{form_error_duplicate_s_value}.qq~"}~;
    }
   }
   $sth->finish();
   database->quick_update(config->{db_table_prefix}.'_settings', { id => $field_id }, { s_value => $s_value, lastchanged => time });
   return '{"result":"1","value":"'.$s_value.'"}';
  }
  
  return '{"result":"0", "error":"'.$lang->{field_edit_error_unknown}.'"}';
};

post '/data/load' => sub {
  # Important! Access control
  if (!_auth()) { return true; }
  # End: Important! Access control
  
  content_type 'application/json';
  
  my $id=param('id') || 0;
  $id=int($id);
  
  if ($id <= 0) {
   return qq~{"result":"0"}~;
  }
  
  my $db_data  = database->quick_select(config->{db_table_prefix}.'_settings', { id => $id });
  
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
  # Important! Access control
  if (!_auth()) { return true; }
  # End: Important! Access control
  
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
     'DELETE FROM '.config->{db_table_prefix}.'_settings WHERE '.$del_sql
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