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

  my $flow='';
  my $aubbc = taracot::AUBBC->new();

  my $sth = database->prepare(
   'SELECT id,pusername,phub,ptitle,ptags,pdate,uid,ptext,lastmodified,pviews,is_public FROM '.config->{db_table_prefix}.'_blog_posts WHERE 1 ORDER BY pdate DESC'
  );
  if ($sth->execute()) {
   while(my ($id,$pusername,$phub,$ptitle,$ptags,$pdate,$uid,$ptext,$lastmodified,$pviews,$is_public) = $sth -> fetchrow_array) {
    my $phub_url;
    if ($phub) {
      $phub_url = '/blog/hub/'.$phub;
    }
    if (!$pviews) {
      $pviews='&nbsp;0';
    }
    $ptext = $aubbc->do_all_ubbc($ptext);
    my $item_template = template 'blog_feed', { post_title => $ptitle, blog_hub => $phub, blog_hub_url => $phub_url, blog_text_cut => $ptext, blog_user => $pusername, blog_views => $pviews, blog_tags => $ptags, blog_read_more => 1 }, { layout => undef };
    $flow .= $item_template;    
   }
  }
  $sth->finish(); 

  my $page_data= &taracot::_load_settings('site_title,keywords,description', $_current_lang);  
  my $render_template = &taracot::_process_template( template 'blog_index', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'blog.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{module_name}, news_feed => $flow  }, { layout => config->{layout}.'_'.$_current_lang } );
  if ($render_template) {
    return $render_template;
  }
  pass();
};

# End

true;