package modules::search::main;
use Dancer ':syntax';
use Dancer::Plugin::Database;

# Configuration

my $defroute = '/search';

# Load search plugin

require 'modules/search/'.config->{search_plugin}.'.pm';
my $sp = 'modules::search::'.config->{search_plugin};
my $search_plugin = "$sp"->new();

# Module core settings 

my $lang;
prefix $defroute;
my $detect_lang;

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
  my $lang_adm = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/search/lang/en.lng') || {};
  my $lang_adm_cnt={};
  if ($lng ne 'en') {
   $lang_adm_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/search/lang/'.$lng.'.lng') || {};
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
  my $auth = &taracot::_auth();
  my $_current_lang=_load_lang(); 
  my $page_data = &taracot::_load_settings('site_title,keywords,description', $_current_lang);  
  return &taracot::_process_template( template ('search_index', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'search.css" rel="stylesheet" /><link href="'.config->{modules_css_url}.'wbbtheme.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{module_name}, auth_data => $auth  }, { layout => config->{layout}.'_'.$_current_lang }), $auth );
  pass();
};

any '/process' => sub {
  my $ipp = 10; # items per page
  my $_current_lang=_load_lang(); 
  my $search_query = param('search_query');
  if (!$search_query) {
    return '{"status":"0"}';
  }
  my $page = param('page') || 1;
  if ($page < 1) {
    return '{"status":"0"}'; 
  }
  $search_query =~ s/[^\wА-Яа-яёЁ\s\-]//gm;
  $search_query =~ s/ +/ /gm;
  if (length($search_query) < 3 || length($search_query) > 250) {
    return '{"status":"0"}';
  }
  $search_query = lc ($search_query);  
  my $res = $search_plugin->performSearch($search_query, $_current_lang, $page, $ipp);
  $res->{status} = '1';
  my $total = $res->{count};
  my $pc = $total / $ipp;  
  # Paginator code : begin
  my $paginator='';
  if ($pc > 1) {
    my $pitems='';
    if ($page ne 1) {
      $pitems .= template 'search_paginator_item', { page_num => '1', page_text => '&laquo;' }, { layout => undef };
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
      $pitems .= template 'search_paginator_item', { page_num => $it, page_text => $it, active => $active }, { layout => undef };
    }
    if ($page ne $pc) {
      $pitems .= template 'search_paginator_item', { page_num => $pc, page_text => '&raquo;' }, { layout => undef };
    }
    $paginator = template 'search_paginator', { items => $pitems }, { layout => undef };
  } 
  # Paginator code : end
  if ($paginator) {
    $res->{paginator_html} = $paginator;
  }
  my $json_xs = JSON::XS->new();
  return $json_xs->encode($res);
};

# End

1;