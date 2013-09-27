package modules::portfolio::main;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use taracot::fs;

# Configuration

my $defroute = '/portfolio';

# Module core settings 

my $lang;
my $detect_lang;
prefix $defroute;

# Load cache plugin

require 'modules/cache/'.config->{cache_plugin}.'.pm';
my $_cp = 'modules::cache::'.config->{cache_plugin};
my $cache_plugin = "$_cp"->new();

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
  my $lang_adm = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/portfolio/lang/en.lng') || {};
  my $lang_adm_cnt={};
  if ($lng ne 'en') {
   $lang_adm_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/portfolio/lang/'.$lng.'.lng') || {};
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
  if (!session('user')) {
    my $cache_data = $cache_plugin->get_data(request->uri_base().'/portfolio');
    if ($cache_data) {
      return $cache_data;
    }  
  }
  my $auth_data = &taracot::_auth();
  my $_current_lang=_load_lang();
  my $page_data = &taracot::_load_settings('site_title,keywords,description', $_current_lang);
  my $lf = loadFile(config->{root_dir}.'/'.config->{portfolio_path}.'/portfolio_'.$_current_lang.'.json');
  if (!$lf) {
    return &taracot::_process_template( template 'portfolio_error', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'portfolio.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{module_name}, auth_data => $auth_data, err_msg => $lang->{id_error} }, { layout => config->{layout}.'_'.$_current_lang } );;
  }
  my $pf=from_json $$lf;
  my $data_items='';  
  foreach my $item (@{ $pf->{data} }) {
    my $works = $item->{works};
    my $index_items='';
    foreach my $key (keys %{ $works }) {
      $index_items = &taracot::_process_template( template 'portfolio_index_item', { lang => $lang, id => $key, title => $works->{$key}, images_url => config->{portfolio_images_url} }, { layout => undef } ) . $index_items;
    }
    $data_items .= &taracot::_process_template( template 'portfolio_index_cat', { lang => $lang, id => $item->{id}, title => $item->{desc}, images_url => config->{portfolio_images_url}, items => $index_items, default => $item->{default} }, { layout => undef } );
  }  
  my $_out = &taracot::_process_template( template 'portfolio_index', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'portfolio.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{module_name}, auth_data => $auth_data, index_items => $data_items, desc => $pf->{desc} }, { layout => config->{layout}.'_'.$_current_lang } );
  if (!session('user')) {
    $cache_plugin->set_data(request->uri_base().'/portfolio', $_out);
  }
  return $_out;
};

get '/:id' => sub {
  my $id = param('id');
  if ($id !~ /^[0-9a-z_\-]{1,20}$/) {
    pass;
  }  
  if (!session('user')) {
    my $cache_data = $cache_plugin->get_data(request->uri_base().'/portfolio/'.$id);
    if ($cache_data) {
      return $cache_data;
    }
  }
  my $auth_data = &taracot::_auth();
  my $_current_lang=_load_lang();
  my $page_data = &taracot::_load_settings('site_title,keywords,description', $_current_lang);    
  my $lf = loadFile(config->{root_dir}.'/'.config->{portfolio_path}.'/'.$id.'_'.$_current_lang.'.json');
  if (!$lf) {
    pass;
  }
  my $pf=from_json $$lf;
  my $works = $pf->{works};  
  my $_out = &taracot::_process_template( template 'portfolio_item', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'portfolio.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $pf->{title}." | ".$lang->{module_name}, auth_data => $auth_data, pf => $pf, images_url => config->{portfolio_images_url} }, { layout => config->{layout}.'_'.$_current_lang } );
  if (!session('user')) {
    $cache_plugin->set_data(request->uri_base().'/portfolio/'.$id, $_out);
  }
  return $_out;
};

1;