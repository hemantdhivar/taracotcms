package modules::blog::main;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use JSON::XS();
use Digest::MD5 qw(md5_hex);
use Date::Format;
use taracot::fs;
use taracot::AUBBC;

# Configuration

my $defroute = '/blog';

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
  my $lang_adm = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/blog/lang/en.lng') || {};
  my $lang_adm_cnt={};
  if ($lng ne 'en') {
   $lang_adm_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/blog/lang/'.$lng.'.lng') || {};
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
  my $_current_lang=_load_lang(); 

  $sth = database->prepare(
   'SELECT id,phub,ptitle,ptags,pdate,uid,ptext,lastmodified,is_public FROM '.config->{db_table_prefix}.'_users WHERE '.$where.$sortorder.' LIMIT '.$iDisplayStart.', '.$iDisplayLength
  );
  if ($sth->execute()) {
   while(my ($id,$phub,$ptitle,$ptags,$pdate,$uid,$ptext,$lastmodified,$is_public) = $sth -> fetchrow_array) {
    push(@ary, '');
    push(@data, \@ary);
   }
  }
  $sth->finish(); 

  my $page_data= &taracot::_load_settings('site_title,keywords,description', $_current_lang);  
  my $render_template = &taracot::_process_template( template 'blog_index', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'blog.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{module_name}  }, { layout => config->{layout}.'_'.$_current_lang } );
  if ($render_template) {
    return $render_template;
  }
  pass();
};

# End

true;