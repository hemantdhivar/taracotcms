package modules::catalog::main;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use JSON::XS("decode_json");
use Digest::MD5 qw(md5_hex);
use taracot::loadpm;
use Text::Unidecode;
use taracot::typo;
use Encode;
use Fcntl qw(:flock SEEK_END); # import LOCK_* and SEEK_END constants
use taracot::fs;
use Data::Walk;

# Configuration

my $defroute = '/admin/catalog';
my @columns = ('id','pagetitle','filename','category','lang','layout','status');
my @columns_mobile = ('id','pagetitle','lang','status');
my @columns_ft = ('pagetitle','filename');

# Load search plugin

require 'modules/search/'.config->{search_plugin}.'.pm';
my $sp = 'modules::search::'.config->{search_plugin};
my $search_plugin = "$sp"->new();

# Load cache plugin

require 'modules/cache/'.config->{cache_plugin}.'.pm';
my $_cp = 'modules::cache::'.config->{cache_plugin};
my $cache_plugin = "$_cp"->new(); 

# Module core settings 

my $lang;
my $detect_lang;
my $typo = taracot::typo->new();

sub _name() {
  _load_lang();
  return $lang->{module_name};
}           
sub _defroute() {
  return $defroute;
}

sub _load_lang {
  $detect_lang = &taracot::_detect_lang();
  my $lng = $detect_lang->{lng} || config->{lang_default};
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

# Frontend Routes

prefix '/';

get qr{(.*)} => sub {
  my $_current_lang=_load_lang();    
  my ($url) = splat;
  # remove dupe chars
  $url=~s/(\/)\1+/$1/gi;
  # remove slash at the end
  $url = $1 if ($url=~/(.*)\/$/);
  # remove slash at the beginning
  # $url = $1 if ($url=~/^\/(.*)/);
  if (!$url) { 
   $url='/'; 
  }
  if ($url !~ /^[A-Za-z0-9_\-\/]{0,254}$/) {
   pass();
  }
  my $page = int(param('page')) || 1;
  my $ipp = 10;
  my $limx = $page*$ipp-$ipp;
  if ($page < 1) {
    $page = 1;
  }
  my @urlarr = split(/\//, $url);
  my $filename = pop(@urlarr);
  my $path = join('/', @urlarr);

  my $json_xs = JSON::XS->new();
  my $hwd;
  my $hcd;
  my %uids;
  my %urls;
  my %ttls;

  my $jdata=loadFile(config->{root_dir}.'/'.config->{data_dir}.'/catalog_tree_clean.json');    
  if (defined $jdata) { 
   $Data::Walk::lang = $_current_lang;
   my $json = decode_json($$jdata);   
   walk \&processLang, $json;
   $hwd = &hash_walk($json);
   foreach my $item(@$hwd) {
    $uids{$item->{url}} = $item->{uid};
    $urls{$item->{uid}} = $item->{url};
    $ttls{$item->{uid}} = $item->{title};
   }
   $hcd = &hash_children($uids{$url}, $json);
  }
  
  my $auth_data = &taracot::_auth();  
  my $page_data = &taracot::_load_settings('site_title,site_keywords,site_description', $_current_lang);

  my $db_data  = database->quick_select(config->{db_table_prefix}.'_catalog', { filename => '/'.$filename, category => $uids{$path}, lang => $_current_lang });

  if (!$db_data && $uids{$url}) {
    my $total=0;
    my $sth = database->prepare('SELECT COUNT(*) AS cnt FROM '.config->{db_table_prefix}.'_catalog WHERE lang = '.database->quote($_current_lang).' AND status=1 AND category='.$uids{$url});
    if ($sth->execute()) {
     ($total) = $sth -> fetchrow_array;
    }
    $sth->finish();
    my $pc = int($total / $ipp);
    if ($total % $ipp) {
      $pc++;
    } 
    my $html_paginator='';
    # Paginator code : begin
    if ($pc > 1) {
      my $url = request->path().'?page=';      
      my $pitems='';
      if ($page ne 1) {
        $pitems .= template 'catalog_paginator_item', { page_url => $url.'1', page_text => '&laquo;' }, { layout => undef };
      }    
      my $lof = 4-$page;
      if ($lof > 3 || $lof < 0) {
        $lof=0;
      }
      my $rof = -($page-$pc);
      if ($rof > 3) {
        $rof=0;
      } else {
        $rof=3-$rof;
      }
      for (my $it=1; $it<=$pc; $it++) {    
        if ($pc>7) {
          if ($it < $page-3-$rof || $it > $page+3+$lof) {
            next;
          }
        }
        my $active;
        if ($it eq $page) {
          $active = 1;
        }
        $pitems .= template 'catalog_paginator_item', { page_url => $url.$it, page_text => $it,active => $active }, { layout => undef };
      }
      if ($page ne $pc) {
        $pitems .= template 'catalog_paginator_item', { page_url => $url.$pc, page_text => '&raquo;' }, { layout => undef };
      }
      $html_paginator = template 'catalog_paginator', { items => $pitems }, { layout => undef };
    } 
    # Paginator code : end
    my $_in = 0;
    foreach my $item (@$hwd) {       
      if ($uids{$url} eq $item->{uid}) {
        last;
      }
      $_in++; 
    }
    my @parent_ids;
    push @parent_ids, @$hwd[$_in]->{uid};
    my $_lv = @$hwd[$_in]->{level};
    if ($_in >= 0) {
      for (my $i = $_in; $i>=0; $i--) {
        if (@$hwd[$i]->{level} < $_lv) {
          push @parent_ids, @$hwd[$i]->{uid};
          $_lv = @$hwd[$i]->{level};
        }        
      }
    }
    @parent_ids = reverse @parent_ids;   
    my $html_parents = '';
    if (@parent_ids) {
      $html_parents .= &taracot::_process_template( template ('catalog_parents', { parents => \@parent_ids, children => $hcd, urls => \%urls, ttls => \%ttls, lang => $lang }, { layout => undef }), $auth_data );
    }
    my $output_layout = '';
    if ($total > 0) {
      my $sth = database->prepare('SELECT id, pagetitle, status, filename, category, layout, cat_text FROM '.config->{db_table_prefix}.'_catalog WHERE (lang = '.database->quote($_current_lang).' AND status=1 AND category='.$uids{$url}.') LIMIT '.$limx.', '.$ipp);
      my $output = '';      
      if ($sth->execute()) {        
        while (my ($id, $pagetitle, $status, $filename, $category, $layout, $cat_text) = $sth->fetchrow_array) {
          $output_layout = $layout if (!$output_layout);
          my $cat_pic = config->{files_url}.'/catalog_index/default.png';
          if (-e config->{files_dir}.'/catalog_index/id_'.$id.'.jpg') {
            $cat_pic = config->{files_url}.'/catalog_index/id_'.$id.'.jpg';
          } 
          $output .= template 'catalog_item', { title => $pagetitle, cat_text => $cat_text, cat_pic => $cat_pic, url => $urls{$category}.$filename, lang => $lang }, { layout => undef }; 
        }
      }
      $sth->finish();
      my $html_items = '';
      $html_items .= &taracot::_process_template( template ('catalog_items', { items => $output, lang => $lang }, { layout => undef }), $auth_data );
      return &taracot::_process_template( template ('catalog_list', { head_html => '<link href="'.config->{modules_css_url}.'catalog.css" rel="stylesheet" />', cat => $ttls{$uids{$url}}, html_parents => $html_parents, html_items => $html_items, html_paginator => $html_paginator, pagetitle => $ttls{$uids{$url}}.' | '.$lang->{module_name}, page_data => $page_data, db_data => $db_data, detect_lang => $detect_lang, lang => $lang, auth_data => $auth_data }, { layout => $output_layout.'_'.$_current_lang }), $auth_data );
    } else {
      return &taracot::_process_template( template ('catalog_list', { head_html => '<link href="'.config->{modules_css_url}.'catalog.css" rel="stylesheet" />', cat => $ttls{$uids{$url}}, html_parents => $html_parents, html_items => '', html_paginator => $html_paginator, pagetitle => $ttls{$uids{$url}}.' | '.$lang->{module_name}, page_data => $page_data, db_data => $db_data, detect_lang => $detect_lang, lang => $lang, auth_data => $auth_data }, { layout => config->{layout}.'_'.$_current_lang }), $auth_data );
    }
  }
  if (!session('user')) {
    my $cache_data = $cache_plugin->get_data(request->uri_base().$url);
    if ($cache_data) {
      return $cache_data;
    }
  }  
  $db_data->{keywords} = $db_data->{keywords} || '';
  $db_data->{description} = $db_data->{description} || '';
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
    $render_template = &taracot::_process_template( template ('catalog_view', { detect_lang => $detect_lang, lang => $lang, auth_data => $auth_data, pagetitle => $db_data->{pagetitle}, page_data => $page_data, db_data => $db_data }, { layout => $db_data->{layout}.'_'.$db_data->{lang} }), $auth_data );
    if (!session('user')) {
      $cache_plugin->set_data(request->uri_base().$url, $render_template);
    }
   }
   if ($db_data->{status} eq 0) {
    $render_template = &taracot::_process_template( template ('catalog_status', { detect_lang => $detect_lang, lang => $lang, auth_data => $auth_data, pagetitle => $db_data->{pagetitle}, page_data => $page_data, db_data => $db_data, status_icon => "disabled_32.png", status_header => $lang->{disabled_header}, status_text => $lang->{disabled_text} }, { layout => $db_data->{layout}.'_'.$db_data->{lang} }), $auth_data );
   }
   if ($db_data->{status} eq 2) {
    $render_template = &taracot::_process_template( template ('catalog_status', { detect_lang => $detect_lang, lang => $lang, auth_data => $auth_data, pagetitle => $db_data->{pagetitle}, page_data => $page_data, db_data => $db_data, status_icon => "under_construction_32.png", status_header => $lang->{construction_header}, status_text => $lang->{construction_text} }, { layout => $db_data->{layout}.'_'.$db_data->{lang} }), $auth_data );
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
  return template 'admin_catalog_index', { default_cat_pic => config->{files_url}.'/catalog_index/default.png', current_lang => $_current_lang, default_lang => config->{lang_default}, lang => $lang, navdata => $navdata, authdata => $auth, list_layouts => $list_layouts, list_langs => $list_langs, hash_langs => $hash_langs }, { layout => 'admin' };
  
};

get '/data/list' => sub {
  if (!&taracot::admin::_auth()) { redirect '/admin?'.md5_hex(time); return true }
  my $_current_lang = _load_lang();
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
  my $columns;
  if (param('mobile')) {
    $columns=join(',',@columns_mobile);
  } else {
    $columns=join(',',@columns);
  }
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
  my $hwd;

  my $jdata=loadFile(config->{root_dir}.'/'.config->{data_dir}.'/catalog_tree_clean.json');    
  if (defined $jdata) { 
   $Data::Walk::lang = $_current_lang;
   my $json = decode_json($$jdata);   
   walk \&processLang, $json;
   $hwd = &hash_walk($json);
  }

  my %res;
  $res{sEcho} = $sEcho;
  $res{iTotalRecords} = $total;
  $res{iTotalDisplayRecords} = $total_filtered;
  $res{aaData} = \@data;
  $res{hwd} = $hwd;

  return $json_xs->encode(\%res);

};

post '/data/save' => sub {
  if (!&taracot::admin::_auth()) { redirect '/admin?'.md5_hex(time); return true }
  _load_lang();
  content_type 'application/json';
  my $pagetitle=param('pagetitle') || '';
  my $filename=param('filename') || '';
  my $category=param('category') || '0';
  my $keywords=param('keywords') || '';
  my $description=param('description') || '';
  my $content=param('content') || '';
  my $status=param('status') || 0;
  my $plang=param('lang') || '';
  my $cat_text=param('cat_text') || '';
  my $layout=param('layout') || '';
  $status=int($status);
  $category = int($category);
  if ($category < 0) {
    $category = '0';
  }
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
  if (length($cat_text) > 102400) {
   return qq~{"result":"0","field":"cat_text","error":"~.$lang->{form_error_invalid_cat_text}.qq~"}~;
  }
  if ($filename ne '/') {
   # remove dupe chars
   $filename=~s/(\/)\1+/$1/gi;
   # remove slash at the end
   $filename = $1 if ($filename=~/(.*)\/$/);
   # remove slash at the beginning
   # $filename = $1 if ($filename=~/^\/(.*)/);
  }
  if ($filename !~ /^[A-Za-z0-9_\.\-\/]{1,254}$/) {
   return qq~{"result":"0","field":"filename","error":"~.$lang->{form_error_invalid_filename}.qq~"}~;
  }
  if ($filename !~ /^\//) {
    $filename = '/'.$filename;
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
  $content = $typo->process($content);
  if (-e config->{files_dir}."/catalog_index/id_".$id.'.tmp.jpg') {
    removeFile(config->{files_dir}."/catalog_index/id_".$id.'.jpg');
    moveFile(config->{files_dir}."/catalog_index/id_".$id.'.tmp.jpg', config->{files_dir}."/catalog_index/id_".$id.'.jpg');
  }
  if ($id > 0) {
   database->quick_update(config->{db_table_prefix}.'_catalog', { id => $id }, { pagetitle => $pagetitle, filename => $filename, keywords => $keywords, description => $description, status => $status, content => $content, lang => $plang, category => $category, layout => $layout, cat_text => $cat_text, lastchanged => time });   
   if ($status eq 1) {
    $search_plugin->updateSearchIndex($plang, $pagetitle, $content, "$filename", $id, 'catalog');
   }
  } else {   
   database->quick_insert(config->{db_table_prefix}.'_catalog', { pagetitle => $pagetitle, filename => $filename, keywords => $keywords, description => $description, status => $status, content => $content, lang => $plang, layout => $layout, cat_text => $cat_text, category => $category, lastchanged => time });
   my $id = database->{q{mysql_insertid}}; 
   if ($status eq 1) {
    $search_plugin->updateSearchIndex($plang, $pagetitle, $content, "$filename", $id, 'catalog');
   }
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
  
  if ($field_name ne 'pagetitle' && $field_name ne 'filename' && $field_name ne 'lang' && $field_name ne 'layout' && $field_name ne 'status' && $field_name ne 'category') {
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
    my $rec = database->quick_select(config->{db_table_prefix}.'_catalog', { id => $field_id });
    if ($rec) {
      if ($rec->{status} eq 1) {
        $search_plugin->updateSearchIndex($rec->{lang}, $rec->{pagetitle}, $rec->{content}, $rec->{filename}, $rec->{id}, 'catalog');
      }
    }
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

  # Check category
  
  if ($field_name eq 'category') {
   my $cat = int($field_value);
   if (!$cat || $cat < 0) {
    $cat = '0';
   }   
   database->quick_update(config->{db_table_prefix}.'_catalog', { id => $field_id }, { category => $cat, lastchanged => time });
   return '{"result":"1"}';
  }
  
  # Check pagetitle
  
  if ($field_name eq 'pagetitle') {
   my $pagetitle=$field_value;
   if ($pagetitle !~ /^.{1,254}$/) {
    return qq~{"result":"0","error":"~.$lang->{form_error_invalid_pagetitle}.qq~"}~;
   }
   database->quick_update(config->{db_table_prefix}.'_catalog', { id => $field_id }, { pagetitle => $pagetitle, lastchanged => time });
   my $rec = database->quick_select(config->{db_table_prefix}.'_catalog', { id => $field_id });
   if ($rec) {
    if ($rec->{status} eq 1) {
      $search_plugin->updateSearchIndex($rec->{lang}, $rec->{pagetitle}, $rec->{content}, $rec->{filename}, $rec->{id}, 'catalog');
    }
   }
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
    # $filename = $1 if ($filename=~/^\/(.*)/);
   }
   if ($filename !~ /^[A-Za-z0-9_\.\-\/]{1,254}$/) {
    return qq~{"result":"0","field":"filename","error":"~.$lang->{form_error_invalid_filename}.qq~"}~;
   }
   if ($filename !~ /^\//) {
    $filename = '/'.$filename;
   }
   my $page_data  = database->quick_select(config->{db_table_prefix}.'_catalog', { id => $field_id });
   
   my $sth = database->prepare(
    'SELECT id FROM '.config->{db_table_prefix}.'_catalog WHERE filename='.database->quote($filename).' AND id != '.$field_id.' AND lang='.database->quote($page_data->{lang})
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
   my $rec = database->quick_select(config->{db_table_prefix}.'_catalog', { id => $field_id });
   if ($rec) {
    if ($rec->{status} eq 1) {
      $search_plugin->updateSearchIndex($rec->{lang}, $rec->{pagetitle}, $rec->{content}, $rec->{filename}, $rec->{id}, 'catalog');
    }
   }
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

  if (-e config->{files_dir}."/catalog_index/id_".$id.'.tmp.jpg') {
    removeFile(config->{files_dir}."/catalog_index/id_".$id.'.tmp.jpg');
  }
  my $catpic = config->{files_url}.'/catalog_index/default.png';
  if (-e config->{files_dir}.'/catalog_index/id_'.$id.'.jpg') {
    $catpic = config->{files_url}.'/catalog_index/id_'.$id.'.jpg';
  } 
  
  my $db_data  = database->quick_select(config->{db_table_prefix}.'_catalog', { id => $id });
  
  if ($db_data->{id}) {
   $db_data->{result} = 1;
   $db_data->{cat_pic} = $catpic;
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

post '/data/save_index_pic' => sub {
  content_type 'application/json';
  my $auth = &taracot::_auth();
  if (!$auth) { 
    return '{"error":"1"}'; 
  } 
  my $id = param('id');
  $id = int($id);
  if (!$id || $id < 1) {
   return '{"error":"1"}';
  }
  my $file = upload('file');
  if (!defined $file) {
   return '{"error":"1"}';
  }
  my $maxsize=config->{upload_limit_bytes} || 3145728; # 3 MB by default
  if ($file->size > $maxsize) {
    return '{"error":"1"}'; 
  }  
  my $img = Imager->new(file=>$file->tempname) || return '{"error":"1"}';
  my $x = $img->getwidth();
  my $y = $img->getheight();
  if ($x ne $y) {
    my $cb = undef;
    if ($x > $y) {
      $cb = $y;
      $x =int(($x - $cb )/2);
      $y =0;
    } else {
      $cb = $x ;
      $y =int(($y - $cb )/2);
      $x = 0;
    }
    $img = $img->crop( width=>$cb, height=>$cb );
  }
  $img = $img->scale(xpixels=>100, ypixels=>100);
  $img->write(file => config->{files_dir}."/catalog_index/id_".$id.'.tmp.jpg');
  return '{"error":"0"}'; 
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

# Tree Map

get '/tree' => sub {
  my $auth = &taracot::admin::_auth();
  if (!$auth) { redirect '/admin?'.md5_hex(time); return true }
  my $_current_lang = _load_lang();
  my $langs=config->{lang_available};   
  $langs=~s/ //gm;
  my @a_langs=split(/,/, $langs);
  my $langs_long=config->{lang_available_long};
  $langs_long=~s/ //gm;
  my @a_langs_long=split(/,/, $langs_long); 
  my %langs_hash;
  my $cnt;
  foreach my $item (@a_langs) {
    $langs_hash{$a_langs[$cnt]} = $a_langs_long[$cnt];
    $cnt++;
  }
  return template 'admin_catalog_map', { lang => $lang, authdata => $auth, langs => \@a_langs, langs_hash => \%langs_hash, current_lang => $_current_lang }, { layout => 'browser' }; 
};

sub processLang {
  my $node = $Data::Walk::container;
  my $lng = $Data::Walk::lang;
  my $data = $_ || '';
  if ($data eq "title") {
    if ($Data::Walk::type eq "HASH") {
      if ($node->{title} && $node->{uid}) {       
         if ($node->{'lang_'.$lng}) {
           $node->{title} = $node->{'lang_'.$lng};
         }         
      }
    }
  }
}

sub processFilter {
  my $node = $Data::Walk::container;
  my $data = $_ || '';
  if (ref($node) && ref($node) eq 'HASH') {
    if ($data ne "title" && $data ne "uid" && $data ne "url" && $data !~ m/^lang_/ && $data ne "children") {
      delete ($node->{$data});
    }      
  }
}

sub hash_walk {
    my ($data, $level, $items, $path) = @_;
    $level = 0 if !$level;
    $items = [] if !$items;
    $path = {} if !$path;
    if (ref($data) eq 'HASH') {
      if ($data->{uid}) {
        my $_level = int($level/2);
        if ($_level < 0) {
          $_level = 0;
        }
        my %item;
        $item{uid} = $data->{uid};
        $item{title} = $data->{title};   
        $item{level} = $_level;   
        $path->{$_level} = $data->{url};
        my $url = '';
        for (my $i=0; $i <= $_level; $i++) {
          $url .= "/".$path->{$i};
        }
        $url =~ s/\/+/\//gm;
        $url =~ s/\/$//;
        $item{url} = $url;
        push @$items, \%item;        
      }
    }
    if (ref($data) eq 'ARRAY') {
     foreach my $item (@$data) {
        if (ref($item) eq 'HASH') {
          $level++;
          $items = &hash_walk(\%{$item}, $level, $items, $path);
          $level--;
        }
        if (ref($item) eq 'ARRAY') {
          $level++;
          $items = &hash_walk(\@$item, $level, $items, $path);
          $level--;
        }
      }
    }
    if (ref($data) eq 'HASH') {
      while (my ($k, $v) = each %$data) {               
          if (ref($v) eq 'ARRAY') {
              $level++;
              $items = &hash_walk(\@$v, $level, $items, $path);
              $level--;
          }
      }
    }  
    return $items;
}

sub hash_children {
    my ($suid, $data, $level, $items, $path, $uf) = @_;
    $level = 0 if !$level;
    $items = [] if !$items;
    $path = {} if !$path;
    if (ref($data) eq 'HASH') {
      if ($data->{uid} && $data->{uid} eq $suid) {
        my $_level = int($level/2);
        if ($_level < 0) {
          $_level = 0;
        }
        $uf = $_level;
        $path->{$_level} = $data->{url};
      } else {
        my $_level = 0;
        if ($data->{uid}) {
          $_level = int($level/2);
          if ($_level < 0) {
            $_level = 0;
          }
          $path->{$_level} = $data->{url};
        }  
        if ($uf) {          
          if ($level <= $uf) {
            die $items;
            return $items;
          }
          if ($data->{uid}) {
            if ($_level eq $uf+1) {
              my %item;
              $item{uid} = $data->{uid};
              $item{title} = $data->{title};   
              $item{level} = $_level;                 
              my $url = '';
              for (my $i=0; $i <= $_level; $i++) {
                $url .= "/".$path->{$i};
              }
              $url =~ s/\/+/\//gm;
              $url =~ s/\/$//;
              $item{url} = $url;
              push @$items, \%item;
            }                  
          }
        }
      }
    }
    if (ref($data) eq 'ARRAY') {
     foreach my $item (@$data) {
        if (ref($item) eq 'HASH') {
          $level++;
          $items = &hash_children($suid, \%{$item}, $level, $items, $path, $uf);
          $level--;
        }
        if (ref($item) eq 'ARRAY') {
          $level++;
          $items = &hash_children($suid, \@$item, $level, $items, $path, $uf);
          $level--;
        }
      }
    }
    if (ref($data) eq 'HASH') {
      while (my ($k, $v) = each %$data) {               
          if (ref($v) eq 'ARRAY') {
              $level++;
              $items = &hash_children($suid, \@$v, $level, $items, $path, $uf);
              $level--;
          }
      }
    }
    return $items;
}

get '/data/tree' => sub {
  if (!&taracot::admin::_auth()) { redirect '/admin?'.md5_hex(time); return true }
  my $_current_lang = _load_lang();
  content_type 'application/json'; 
  my $data=loadFile(config->{root_dir}.'/'.config->{data_dir}.'/catalog_tree.json');    
  if (defined $data) { 
   $Data::Walk::lang = $_current_lang;
   my $json = decode_json($$data);   
   walk \&processLang, $json;
   #my $hw = &hash_walk($json);
   $data = JSON::XS->new->ascii(1)->pretty(0)->encode($json);
  }  
  if ($data) {
   return $data
  } else {
   return qq~[ { "title": "/", "isFolder": "true", "sm_root": "true" } ]~;
  }   
};

post '/data/tree/save' => sub {
  if (!&taracot::admin::_auth()) { redirect '/admin?'.md5_hex(time); return true }
  content_type 'application/json';  
  my $data=param('data');
  my $json=JSON::XS->new->utf8(0)->decode($data);
  $json=$json->{children};
  my $jsoncnv=JSON::XS->new->ascii(1)->pretty(0)->encode($json);
  #$jsoncnv=~s/[\n\r\0]//gm;
  my $res_err=qq~{ "result": "0" }~;
  open(DATA, '>'.config->{root_dir}.'/'.config->{data_dir}.'/catalog_tree.json') || return $res_err;
  flock(DATA, LOCK_EX) || return $res_err;
  binmode DATA;
  print DATA $jsoncnv || return $res_err;
  close(DATA) || return $res_err;
  $json=JSON::XS->new->utf8(0)->decode($data);
  $json=$json->{children};
  walk \&processFilter, $json;
  my $jsoncnv_clean=JSON::XS->new->ascii(1)->pretty(0)->encode($json);
  open(DATA, '>'.config->{root_dir}.'/'.config->{data_dir}.'/catalog_tree_clean.json') || return $res_err;
  flock(DATA, LOCK_EX) || return $res_err;
  binmode DATA;
  print DATA $jsoncnv_clean || return $res_err;
  close(DATA) || return $res_err;
  return qq~{ "result": "1" }~;
};


# End

true;