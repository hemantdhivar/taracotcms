package modules::share_image::main;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use Time::HiRes qw ( time );
use taracot::fs;
use JSON::XS();
use Text::Unidecode;
use Imager;
use Digest::MD5 qw(md5_hex);
use File::Basename qw(fileparse); 

# Configuration

my $defroute = '/share/image';

# Module core settings 

my $lang;
my $detect_lang;
prefix $defroute;

sub _load_lang {
  $detect_lang = &taracot::_detect_lang();
  my $lng = $detect_lang->{lng} || config->{lang_default};
  my $lang_adm = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/share_image/lang/en.lng') || {};
  my $lang_adm_cnt={};
  if ($lng ne 'en') {
   $lang_adm_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/share_image/lang/'.$lng.'.lng') || {};
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
  my $auth_data = &taracot::_auth();
  if (!$auth_data) {
    return redirect '/user/authorize?comeback=/share/image'
  }
  my $_current_lang=_load_lang();
  my $page_data = &taracot::_load_settings('site_title,keywords,description', $_current_lang);
  if (config->{share_image_mode} ne 'everyone' && !$auth_data->{groups_hash}->{'share_image'} && $auth_data->{status} < 2) {
    return &taracot::_process_template( template ('share_error', { detect_lang => $detect_lang, lang => $lang, page_data => $page_data, pagetitle => $lang->{share_unauthorized_title}.' | '.$lang->{module_name}, auth_data => $auth_data  }, { layout => config->{layout}.'_'.$_current_lang }), $auth_data );
  }
  return &taracot::_process_template( template ('share_image', { detect_lang => $detect_lang, lang => $lang, page_data => $page_data, pagetitle => $lang->{module_name}, auth_data => $auth_data  }, { layout => config->{layout}.'_'.$_current_lang }), $auth_data );  
};

post '/upload' => sub {
  my $auth_data = &taracot::_auth();
  if (!$auth_data) {
    return redirect '/user/authorize?comeback=/share/image'
  }
  my $_current_lang=_load_lang();
  my $page_data = &taracot::_load_settings('site_title,keywords,description', $_current_lang);
  if (config->{share_image_mode} ne 'everyone' && !$auth_data->{groups_hash}->{'share_image'} && $auth_data->{status} < 2) {
    return &taracot::_process_template( template ('share_error', { detect_lang => $detect_lang, lang => $lang, page_data => $page_data, pagetitle => $lang->{share_unauthorized_title}.' | '.$lang->{module_name}, auth_data => $auth_data  }, { layout => config->{layout}.'_'.$_current_lang }), $auth_data );
  }
  content_type 'application/json';
  my $file=upload('file');
  my $maxsize=config->{upload_limit_bytes} || 20971520; # 20 MB by default
  if (defined $file && $file->size > $maxsize) {
    return '{"error":"1","reason":"bad_upload"}'; 
  }
  if (!-d config->{files_dir}."share/images") {
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
  my $fp=config->{files_dir}."share/images/".$auth_data->{id}.'_'.time.'_'.$fn;
  $fp=~s/\/\//\//gm;
  $file->copy_to($fp);
  open(DATA, $fp);
  my $_fh5 = Digest::MD5->new;
  $_fh5->addfile(*DATA);
  my $_image_md5 = $_fh5->hexdigest;
  close(DATA);
  if (-e $fp) {
   my $img = Imager->new(file=>$fp) || die Imager->errstr();
   my $x = $img->getwidth();
   my $y = $img->getheight();
   my $ratio;
   if ($x > $y) {
    $ratio = $y / $x;
   } else {
    $ratio = $x / $y;
   }
   if ($img->getwidth() > 1000) {
    $img = $img->scale(xpixels => 1000);
   }
   if ($img->getheight() > 1000) {
    $img = $img->scale(ypixels => 1000);
   }   
   $img->write(file => config->{files_dir}."share/images/".$_image_md5.'.jpg');
   if ($x > $y) {
    $img = $img->scale(xpixels=>100);
   } else {
    $img = $img->scale(ypixels=>100);
   }   
   $img = $img->crop( width=>100, height=>100 );
   $img->write(file => config->{files_dir}."share/images/.".$_image_md5.'.jpg');
   removeFile($fp);
  }
  return '{"tn":"'.config->{files_url}."/share/images/.".$_image_md5.'.jpg'.'","fn":"'.config->{files_url}."/share/images/".$_image_md5.'.jpg'.'"}';
}; 

1;