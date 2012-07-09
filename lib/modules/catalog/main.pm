package modules::catalog::main;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use JSON::XS();
use Digest::MD5 qw(md5_hex);
use taracot::loadpm;
use Text::Unidecode;
use taracot::fs;
use Fcntl qw(:flock SEEK_END); # import LOCK_* and SEEK_END constants 

# Configuration

my $defroute = '/admin/catalog';
my @columns = ('id','pagetitle','filename','groupid','lang','layout','status');
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
  my $lang_adm = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/catalog/lang/en.lng') || {};
  my $lang_adm_cnt={};
  if ($lng ne 'en') {
   $lang_adm_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/catalog/lang/'.$lng.'.lng') || {};
  }
  my $lang_mod = YAML::XS::LoadFile(config->{root_dir}.'lib/taracot/lang/en.lng') || {};
  my $lang_mod_cnt={};
  if ($lng ne 'en') {
   $lang_mod_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/taracot/lang/'.$lng.'.lng') || {};
  }
  $lang = { %$lang_adm, %$lang_mod, %$lang_adm_cnt, %$lang_mod_cnt };
  return $lng;
}

sub generate_special_html {
 my $current_lang=shift;
 my $items;
 my $sth; 
 $sth = database->prepare(
   'SELECT id,pagetitle,filename,groupid,description_short FROM '.config->{db_table_prefix}.'_catalog WHERE status=1 AND special_flag=1 AND lang='.database->quote($current_lang)
 );
 if ($sth->execute()) {
  while(my ($id,$pagetitle,$filename,$groupid,$description_short) = $sth -> fetchrow_array) {
    my $picture;
    if (-d config->{files_dir}.'/images_catalog/'.$id) {
      opendir(DIR, config->{files_dir}.'/images_catalog/'.$id) || die "Fatal error: can't open directory\n";
      while((my $filename = readdir(DIR))) {
        if ($filename =~  m/^\.\.?/) {
          next;
         }
         $picture="/files/images_catalog/$id/.".md5_hex($filename).".jpg";
         last;
      }
      closedir(DIR);       
    } # if dir exists
    if (!$picture) {
      $picture="/images/placeholder_200.png";
    }
    $items .= template 'catalog_special_item', { lang => $lang, picture => $picture, id => $id,  pagetitle => $pagetitle, filename => $filename, groupid => $groupid, description_short => $description_short }, { layout => undef };
  } # while     
 } 
 $sth->finish();  
 my $tmp = template 'catalog_special', { items => $items }, { layout => undef };
 open(DATA, '>'.config->{root_dir}.'/'.config->{data_dir}.'/special_'.$current_lang.'.html') || return;
 flock(DATA, LOCK_EX) || return;
 binmode DATA, ':utf8';
 print DATA $tmp || return;
 close(DATA) || return; 
}

# Frontend Routes

prefix '/catalog';

get qr{(.*)} => sub {
  my $_current_lang=_load_lang();
  my $stitle = database->quick_select(config->{db_table_prefix}."_settings", { s_name => 'site_title', lang => $_current_lang });
  if (session('user')) { 
   my $id = session('user');
   $taracot::taracot_auth_data  = database->quick_select(config->{db_table_prefix}."_users", { id => $id });
  } else {
   $taracot::taracot_auth_data->{id} = 0;
   $taracot::taracot_auth_data->{status} = 0;
   $taracot::taracot_auth_data->{username} = '';
   $taracot::taracot_auth_data->{password} = '';
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
  my ($groupid) = split(/\//, $url);
  $url=~s/$groupid(\/?)//;
  if (!$url || !$groupid) {
    my $sth;
    if ($groupid) {
      $sth = database->prepare(
       'SELECT id,pagetitle,filename,groupid,description_short FROM '.config->{db_table_prefix}.'_catalog WHERE status=1 AND groupid='.database->quote($groupid).' AND lang='.database->quote($_current_lang)
      );
    } else {
      $sth = database->prepare(
       'SELECT id,pagetitle,filename,groupid,description_short FROM '.config->{db_table_prefix}.'_catalog WHERE status=1 AND lang='.database->quote($_current_lang)
      );
    }
    my $items;
    if ($sth->execute()) {
     while(my ($id,$pagetitle,$filename,$groupid,$description_short) = $sth -> fetchrow_array) {
       my $picture;
       if (-d config->{files_dir}.'/images_catalog/'.$id) {
         opendir(DIR, config->{files_dir}.'/images_catalog/'.$id) || die "Fatal error: can't open directory\n";
         while((my $filename = readdir(DIR))) {
          if ($filename =~  m/^\.\.?/) {
            next;
          }
          $picture="/files/images_catalog/$id/.".md5_hex($filename).".jpg";
          last;
         }
         closedir(DIR);       
       } # if dir exists
       if (!$picture) {
        $picture="/images/placeholder_200.png";
       }
       if (!$description_short) {
        $description_short='<br>';
       }
       $items .= template 'catalog_item', { lang => $lang, picture => $picture, id => $id,  pagetitle => $pagetitle, filename => $filename, groupid => $groupid, description_short => $description_short }, { layout => undef };
     } # while     
    }
    $sth->finish();
    if (!$items) {
      status 'not_found';
      my $render_404 = template 'error_404', { lang => $lang }, { layout => undef };
      return $render_404; 
    }
    my $var1="catalog_title";
    if ($groupid) {
      $var1.="_".$groupid;
    }
    my $db_var1  = database->quick_select(config->{db_table_prefix}.'_settings', { s_name => $var1, lang => $_current_lang });
    my %page_data;
    $page_data{'content'} = $db_var1->{s_value_html}.template 'catalog_list', { items => $items }, { layout => undef };
    $page_data{'pagetitle'} = $db_var1->{s_value} || $lang->{module_name}; 
    $taracot::taracot_render_template = template 'index_'.$_current_lang, { current_lang => $_current_lang, lang => $lang, authdata => \$taracot::taracot_auth_data, site_title => $stitle->{s_value}, page_data => \%page_data }, { layout => config->{layout}.'_'.$_current_lang };
    pass();
    return;
  } 
  if ($url !~ /^[A-Za-z0-9_\-\/]{0,254}$/) {
   pass();
   return;
  }
  my $db_data  = database->quick_select(config->{db_table_prefix}.'_catalog', { groupid => $groupid, filename => $url, lang => $_current_lang });
  if (defined $db_data && $db_data->{id}) {
   if ($db_data->{status} eq 1) {
    my %img_pics;
    my %img_urls;  
    if (-d config->{files_dir}.'/images_catalog/'.$db_data->{id}) {
      opendir(DIR, config->{files_dir}.'/images_catalog/'.$db_data->{id}) || die "Fatal error: can't open directory\n";
      my $cnt=1;
      while((my $filename = readdir(DIR))) {
       if ($filename =~  m/^\.\.?/) {
        next;
       }
       $img_pics{$cnt} = "/files/images_catalog/".$db_data->{id}."/.".md5_hex($filename).".jpg";
       $img_urls{$cnt} = "/files/images_catalog/".$db_data->{id}."/".$filename;
       $cnt++;
      }
      closedir(DIR);
    }
    for (my $i=1; $i<10; $i++) {
      if (!$img_pics{$i}) {
        $img_pics{$i}="/images/blank.gif";
        $img_urls{$i}="#";
      }
    }    
    my $grid=template 'catalog_images_grid', { id => $db_data->{id}, img_pics => \%img_pics, img_urls => \%img_urls }, { layout => undef };
    my $db_var1  = database->quick_select(config->{db_table_prefix}.'_settings', { s_name => "catalog_title_".$groupid, lang => $_current_lang });
    my $groupid_title = $db_var1->{s_value} || $groupid;
    $taracot::taracot_render_template = template 'catalog_view', { current_lang => $_current_lang, lang => $lang, authdata => \$taracot::taracot_auth_data, site_title => $stitle->{s_value}, page_data => $db_data, grid => $grid, url => $url, groupid => $groupid, groupid_title => $groupid_title }, { layout => $db_data->{layout}.'_'.$db_data->{lang} };
   }
   if ($db_data->{status} eq 0) {
    $taracot::taracot_render_template = template 'catalog_status', { site_title => $stitle->{s_value}, page_data => $db_data, status_icon => "disabled_32.png", status_header => $lang->{disabled_header}, status_text => $lang->{disabled_text} }, { layout => $db_data->{layout}.'_'.$db_data->{lang} };
   }
   if ($db_data->{status} eq 2) {
    $taracot::taracot_render_template = template 'catalog_status', { site_title => $stitle->{s_value}, page_data => $db_data, status_icon => "under_construction_32.png", status_header => $lang->{construction_header}, status_text => $lang->{construction_text} }, { layout => $db_data->{layout}.'_'.$db_data->{lang} };
   }
  }
  pass();
};

# Backend Routes

prefix $defroute;

get '/' => sub {
  if (!&taracot::admin::_auth()) { redirect '/admin?'.md5_hex(time); return true }
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
  return template 'catalog_index', { current_lang => $_current_lang, default_lang => config->{lang_default}, lang => $lang, navdata => $navdata, authdata => $taracot::taracot_auth_data, list_layouts => $list_layouts, list_langs => $list_langs, hash_langs => $hash_langs }, { layout => 'admin' };
  
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
   'SELECT COUNT(*) AS cnt FROM '.config->{db_table_prefix}.'_catalog WHERE 1'
  );
  if ($sth->execute()) {
   ($total) = $sth -> fetchrow_array;
  }
  $sth->finish();
  my $total_filtered=0;
  if ($where ne '1' && $total > 0) {
   my $sth = database->prepare(
    'SELECT COUNT(*) AS cnt FROM '.config->{db_table_prefix}.'_catalog WHERE '.$where
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
   'SELECT '.$columns.' FROM '.config->{db_table_prefix}.'_catalog WHERE '.$where.$sortorder.' LIMIT '.$iDisplayStart.', '.$iDisplayLength
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
  my $_current_lang=_load_lang();
  content_type 'application/json';
  my $pagetitle=param('pagetitle') || '';
  my $filename=param('filename') || '';
  my $groupid=param('groupid') || '';
  my $keywords=param('keywords') || '';
  my $description=param('description') || '';
  my $description_short=param('description_short') || '';
  my $special_flag=param('special_flag') || 0;
  my $content=param('content') || '';
  my $status=param('status') || 0;
  my $plang=param('lang') || '';
  my $layout=param('layout') || '';
  $status=int($status);
  my $id=param('id') || 0;
  $id=int($id);
  if ($special_flag) {
    $special_flag=1;
  } else {
    $special_flag=0;
  }
  
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
  if ($filename !~ /^[A-Za-z0-9_\-\/]{1,254}$/) {
   return qq~{"result":"0","field":"filename","error":"~.$lang->{form_error_invalid_filename}.qq~"}~;
  }  
  if ($groupid !~ /^[A-Za-z0-9_\-]{1,80}$/) {
   return qq~{"result":"0","field":"groupid","error":"~.$lang->{form_error_invalid_groupid}.qq~"}~;
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
  $description_short=~s/[\n\r]//gm;
  $description_short=~s/\"/&quot;/gm;
  $description_short=~s/\</&lt;/gm;
  $description_short=~s/\>/&gt;/gm;
  $description_short=~s/\&/&amp;/gm;
  if ($description_short !~ /^.{0,2047}$/) {
   return qq~{"result":"0","field":"description_short","error":"~.$lang->{form_error_invalid_description_short}.qq~"}~;
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
  $dupesql.=' AND lang = '.database->quote($plang).' AND groupid='.database->quote($groupid);
  
  my $sth = database->prepare(
   'SELECT id FROM '.config->{db_table_prefix}.'_catalog WHERE filename='.database->quote($filename).$dupesql
  );
  if ($sth->execute()) {
   my ($tmpid) = $sth->fetchrow_array;
   if ($tmpid) {
    $sth->finish();
    return qq~{"result":"0","field":"filename","error":"~.$lang->{form_error_duplicate_filename}.qq~"}~;
   }
  }
  $sth->finish();
  
  my $ins_id=0;

  if ($id > 0) {
   database->quick_update(config->{db_table_prefix}.'_catalog', { id => $id }, { pagetitle => $pagetitle, filename => $filename, groupid => $groupid, keywords => $keywords, description => $description, description_short => $description_short, status => $status, content => $content, lang => $plang, layout => $layout, special_flag => $special_flag, lastchanged => time });
  } else {   
   database->quick_insert(config->{db_table_prefix}.'_catalog', { pagetitle => $pagetitle, filename => $filename, groupid => $groupid, keywords => $keywords, description => $description, description_short => $description_short,  status => $status, content => $content, lang => $plang, layout => $layout, special_flag => $special_flag, lastchanged => time });
   $id = database->{q{mysql_insertid}};
  }

  if (!$ins_id) {
    $ins_id=$id;
  }
  generate_special_html($_current_lang);
  return qq~{"result":"1", "id":"$ins_id"}~;
};

post '/data/save/field' => sub {
  if (!&taracot::admin::_auth()) { redirect '/admin?'.md5_hex(time); return true }
  my $_current_lang=_load_lang();
  content_type 'application/json';
  my $field_name=param('field_name') || '';
  my $field_id=param('field_id') || 0;
  $field_id=int($field_id);
  my $field_value=param('field_value') || '';

  # Pre-check all fields
  
  if ($field_name ne 'pagetitle' && $field_name ne 'filename' && $field_name ne 'lang' && $field_name ne 'layout' && $field_name ne 'status' && $field_name ne 'groupid') {
   return '{"result":"0", "error":"'.$lang->{field_edit_error_unknown}.'"}'; 
  }

  generate_special_html($_current_lang);
  
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
    'SELECT filename FROM '.config->{db_table_prefix}.'_catalog WHERE id = '.$field_id
   );
   if ($sth->execute()) {
    ($filename) = $sth->fetchrow_array;
   }
   $sth->finish();
   if (!$filename) {
    return qq~{"result":"0","error":"~.$lang->{field_edit_error_unknown}.qq~"}~;
   }
   $sth = database->prepare(
    'SELECT id FROM '.config->{db_table_prefix}.'_catalog WHERE filename = '.database->quote($filename).' AND lang = '.database->quote($field_value)
   );
   if ($sth->execute()) {
    my ($tmpid) = $sth->fetchrow_array;
    if ($tmpid) {
     $sth->finish();
     return qq~{"result":"0","error":"~.$lang->{form_error_duplicate_filename}.qq~"}~;
    }
   }
   $sth->finish();
    database->quick_update(config->{db_table_prefix}.'_catalog', { id => $field_id }, { lang => $field_value, lastchanged => time });
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
   database->quick_update(config->{db_table_prefix}.'_catalog', { id => $field_id }, { layout => $field_value, lastchanged => time });
   return '{"result":"1"}';
  } 

  # Check group ID

  if ($field_name eq 'groupid') {
    my $groupid=$field_value;
    if ($groupid !~ /^[A-Za-z0-9_\-]{1,80}$/) {
     return qq~{"result":"0","field":"groupid","error":"~.$lang->{form_error_invalid_groupid}.qq~"}~;
    }
    my $page_data  = database->quick_select(config->{db_table_prefix}.'_catalog', { id => $field_id });
    my $sth = database->prepare(
     'SELECT id FROM '.config->{db_table_prefix}.'_catalog WHERE filename='.database->quote($page_data->{filename}).' AND id != '.$field_id.' AND lang='.database->quote($page_data->{lang}).' AND groupid='.database->quote($groupid)
    );
    if ($sth->execute()) {
     my ($tmpid) = $sth->fetchrow_array;
     if ($tmpid) {
      $sth->finish();
      return qq~{"result":"0","error":"~.$lang->{form_error_duplicate_filename}.qq~", "tmpid":"$tmpid"}~;
     }
    }
    $sth->finish();
    database->quick_update(config->{db_table_prefix}.'_catalog', { id => $field_id }, { groupid => $groupid, lastchanged => time });
    return '{"result":"1"}';
  } 
  
  # Check pagetitle
  
  if ($field_name eq 'pagetitle') {
   my $pagetitle=$field_value;
   if ($pagetitle !~ /^.{1,254}$/) {
    return qq~{"result":"0","error":"~.$lang->{form_error_invalid_pagetitle}.qq~"}~;
   }   
   database->quick_update(config->{db_table_prefix}.'_catalog', { id => $field_id }, { pagetitle => $pagetitle, lastchanged => time });
   return '{"result":"1"}';
  }
  
  # Check status
  
  if ($field_name eq 'status') {
   my $status=int($field_value);
   if ($status < 0 || $status > 2) {
    return qq~{"result":"0","error":"~.$lang->{form_error_invalid_status}.qq~"}~;
   }
   database->quick_update(config->{db_table_prefix}.'_catalog', { id => $field_id }, { status => $status, lastchanged => time });
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
   if ($filename !~ /^[A-Za-z0-9_\-\/]{1,254}$/) {
    return qq~{"result":"0","field":"filename","error":"~.$lang->{form_error_invalid_filename}.qq~"}~;
   }
   
   my $page_data  = database->quick_select(config->{db_table_prefix}.'_catalog', { id => $field_id });
   
   my $sth = database->prepare(
    'SELECT id FROM '.config->{db_table_prefix}.'_catalog WHERE filename='.database->quote($filename).' AND id != '.$field_id.' AND lang='.database->quote($page_data->{lang}).' AND groupid='.database->quote($page_data->{groupid})
   );
   if ($sth->execute()) {
    my ($tmpid) = $sth->fetchrow_array;
    if ($tmpid) {
     $sth->finish();
     return qq~{"result":"0","error":"~.$lang->{form_error_duplicate_filename}.qq~"}~;
    }
   }
   $sth->finish();
   database->quick_update(config->{db_table_prefix}.'_catalog', { id => $field_id }, { filename => $filename, lastchanged => time });
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
  
  my $db_data  = database->quick_select(config->{db_table_prefix}.'_catalog', { id => $id });
  
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
    if (-d config->{files_dir}.'/images_catalog/'.$item) {
      removeDir(config->{files_dir}.'/images_catalog/'.$item);
    }
   }
   if ($del_sql) {
    $del_sql=~s/ OR //;    
   }
  } else {
    $del_sql='id='.int($id);
    if (-d config->{files_dir}.'/images_catalog/'.int($id)) {
      removeDir(config->{files_dir}.'/images_catalog/'.int($id));
    }
  }
  
  if ($del_sql) {
    my $sth = database->prepare(
     'DELETE FROM '.config->{db_table_prefix}.'_catalog WHERE '.$del_sql
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

sub getDir {
  my $dir = shift || '';
  my $root_dir = shift || '';
  return unless (defined $dir && -d $dir);
  $dir =~ s#\\#/#g;
  my @a_dirs=();
  my @a_files=();
  opendir(DIR, $dir) || die "Fatal error: can't open $dir\n";
  my @files = grep {!/^\.\.?/} readdir(DIR);
  closedir(DIR);
  foreach my $file (@files) {
   my %dd;
   if (-d $dir.'/'.$file) {
    $dd{'type'}="d";
   } else {
    $dd{'type'}="f";
    $dd{'fmt'}='';
    if ($file=~m/\.jp(e?)g$/i) {
     $dd{'fmt'}='j';
    }
    if ($file=~m/\.gif$/i) {
     $dd{'fmt'}='g';
    }
    if ($file=~m/\.png$/i) {
     $dd{'fmt'}='p';
    }
    if (-e $dir.'/.'.md5_hex($file).'.jpg') {
     $dd{'hash'}=md5_hex($file);
    } else {
     $dd{'hash'}='na';
    }
   }
   $dd{'file'}=$file;
   $dd{'id'}=$root_dir.$file;
   if ($dd{'type'} eq 'd') {
    push (@a_dirs, \%dd);
   } else {
    push (@a_files, \%dd);
   }
  }
  push(@a_dirs, @a_files);
  return \@a_dirs;
}

get '/images' => sub {             
  if (!&taracot::admin::_auth()) { redirect '/admin?'.md5_hex(time); return true }
  my $_current_lang=_load_lang();
  my $dir=param('dir');
  if ($dir) {
   $dir=int($dir) || '0';
  } else {
   return;
  }
  if ($dir eq 0) {
    return;
  }
  return template 'catalog_images', { lang => $lang, pagetitle => $lang->{pagetitle}, files_url => config->{files_url}, dir => $dir }, { layout => 'browser_'.$_current_lang };
};

get '/data/images/dirdata' => sub {
  if (!&taracot::admin::_auth()) { redirect '/admin?'.md5_hex(time); return true }
  _load_lang();
  my $dir=param('dir');
  if ($dir) {
   $dir=int($dir) || '0';
  } else {
   return;
  }
  if ($dir eq 0) {
    return;
  }
  if (!-d config->{files_dir}.'/images_catalog/'.$dir) {
   makePath(config->{files_dir}.'/images_catalog/'.$dir);
  }
  my %resp = ( 
   current_dir => $dir,
   files => getDir(config->{files_dir}.'/images_catalog/'.$dir, $dir)  
  );  
  my $json_xs = JSON::XS->new();
  my $json = $json_xs->encode(\%resp);
  content_type 'application/json'; 
  return $json;
};

post '/data/images/upload' => sub {
  if (!&taracot::admin::_auth()) { redirect '/admin?'.md5_hex(time); return true }
  _load_lang();
  content_type 'application/json';
  my $file=upload('file');
  my $dir=param('dir');
  if ($dir !~ /^[\.A-Za-z0-9_\-\/]{0,200}$/ || $dir eq '/' || $dir =~ m/\.\./) {
   return '{"error":"1","reason":"dir_syntax"}';
  }
  if (!-d config->{files_dir}."images_catalog/".$dir) {
   return '{"error":"1","reason":"dir_not_found"}';
  } 
  if (!defined $file) {
   return '{"error":"1","reason":"bad_upload"}';
  } 
  my $fn = $file->basename();
  if ($fn =~ m/\.\./) {
   return '{"error":"1","reason":"filename_syntax"}';
  }
  $fn=~s/ /_/gm;
  $fn=unidecode($fn);
  $fn=~s/[^a-zA-Z0-9\-_\.]//gm;
  my $fp=config->{files_dir}."images_catalog/".$dir.'/'.$fn;
  $fp=~s/\/\//\//gm;
  $file->copy_to($fp);
  if (-e $fp) {
   my $img = Imager->new(file=>$fp) || die Imager->errstr();
   my $x = $img->getwidth();
   my $y = $img->getheight();
   if ($x ne $y) {
    my $cb = undef;
    if ($x > $y) {
      $cb = $y;
      $x =int(($x - $cb )/2);
      $y =0;
    }
    else {
      $cb = $x ;
      $y =int(($y - $cb )/2);
      $x = 0;
    }
    $img = $img->crop( width=>$cb, height=>$cb );
   }
   $img = $img->scale(xpixels=>200, ypixels=>200);
   $img->write(file => config->{files_dir}."images_catalog/".$dir.'/.'.md5_hex($fn).'.jpg');
  }
  return '{"filename":"'.$fn.'","dir":"'.param('dir').'"}';
}; 

post '/data/images/delete' => sub {
  if (!&taracot::admin::_auth()) { redirect '/admin?'.md5_hex(time); return true }
  _load_lang();
  content_type 'application/json';
  my $dir=param('dir');
  if ($dir !~ /^[0-9]{0,80}$/ || !int($dir) || !-d config->{files_dir}."images_catalog/".$dir) {
   return '{"status":"0","reason":"'.$lang->{dir_syntax_error}.'"}';
  }
  my $data=param('data[]');
  my @files=[];
  if(ref($data) eq 'ARRAY'){
   @files=@$data;
  } else {
   push(@files, '');
   $files[0]=$data;
  }
  my $cnt=@files;
  if ($cnt eq 0) {
   return '{"status":"0","error":"'.$lang->{no_files}.'"}';
  }
  foreach my $delete_file (@files) {
   if (!$delete_file) {
    next;
   }
   if ($delete_file !~ /^[\.A-Za-z0-9_\-]{1,100}$/ || $delete_file =~ m/\.\./ || !-e config->{files_dir}.'images_catalog/'.$dir.'/'.$delete_file) {
    return '{"status":"0","reason":"'.$lang->{file_syntax_error}.'","file":"'.$delete_file.'"}';
   }
   my $res=undef;
   $res=removeFile(config->{files_dir}."images_catalog/".$dir.'/'.$delete_file);
   my $md5n=md5_hex($delete_file);
   if (-e config->{files_dir}."images_catalog/".$dir.'/.'.$md5n.'.jpg') {
    $res=removeFile(config->{files_dir}."images_catalog/".$dir.'/.'.$md5n.'.jpg');
   }  
   if (!$res) {
    return '{"status":"0","reason":"'.$lang->{delete_error}.'"}';
   }
  }
  return '{"status":"1"}';
};

post '/data/images/rename' => sub {
  if (!&taracot::admin::_auth()) { redirect '/admin?'.md5_hex(time); return true }
  _load_lang();
  content_type 'application/json';
  my $dir=param('dir');
  if ($dir !~ /^[0-9]{0,80}$/ || !int($dir) || !-d config->{files_dir}."images_catalog/".$dir) {
   return '{"status":"0","reason":"'.$lang->{dir_syntax_error}.'"}';
  }
  my $old_name=param('old_name');
  if ($old_name !~ /^[\.A-Za-z0-9_\-]{1,100}$/ || $old_name =~ m/\.\./ || !-e config->{files_dir}."images_catalog/".$dir.'/'.$old_name) {
   return '{"status":"0","reason":"'.$lang->{not_exists}.'"}';
  }
  my $new_name=param('new_name');
  if ($new_name !~ /^[\.A-Za-z0-9_\-]{1,100}$/ || $new_name =~ m/\.\./) {
   return '{"status":"0","reason":"'.$lang->{file_syntax_error}.'"}';
  }
  my $res=undef;
  $res=moveFile(config->{files_dir}."images_catalog/".$dir.'/'.$old_name, config->{files_dir}."images_catalog/".$dir.'/'.$new_name);
  my $md5n=md5_hex($old_name);
  if (-e config->{files_dir}."images_catalog/".$dir.'/.'.$md5n.'.jpg') {
   $res=moveFile(config->{files_dir}."images_catalog/".$dir.'/.'.$md5n.'.jpg', config->{files_dir}."images_catalog/".$dir.'/.'.md5_hex($new_name).'.jpg');
  }  
  if (!$res) {
    return '{"status":"0","reason":"'.$lang->{rename_error}.'"}';
  }
  return '{"status":"1"}';
};

# End

true;