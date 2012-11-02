package modules::sitemap::main;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use JSON::XS qw();
use taracot::fs;
use Fcntl qw(:flock SEEK_END); # import LOCK_* and SEEK_END constants
use Encode qw(encode decode);
use Digest::MD5 qw(md5_hex);

# Configuration

my $defroute = '/admin/sitemap';

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
  my $lang_adm = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/sitemap/lang/en.lng') || {};
  my $lang_adm_cnt={};
  if ($lng ne 'en') {
   $lang_adm_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/sitemap/lang/'.$lng.'.lng') || {};
  }
  my $lang_mod = YAML::XS::LoadFile(config->{root_dir}.'lib/taracot/lang/en.lng') || {};
  my $lang_mod_cnt={};
  if ($lng ne 'en') {
   $lang_mod_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/taracot/lang/'.$lng.'.lng') || {};
  }
  $lang = { %$lang_adm, %$lang_mod, %$lang_adm_cnt, %$lang_mod_cnt };
  return $lng;
}

# Backend Routes

prefix $defroute;

get '/' => sub {
  if (!&taracot::admin::_auth()) { redirect '/admin?'.md5_hex(time); return true }
  _load_lang();
  my $navdata=&taracot::admin::_navdata();
  my $langs=config->{lang_available};
  $langs=~s/ //gm;
  my @a_langs=split(/,/, $langs);
  my $langs_long=config->{lang_available_long};
  $langs_long=~s/ //gm;
  my @a_langs_long=split(/,/, $langs_long);
  my $list_langs;
  my $_cnt;
  foreach my $item (@a_langs) {
   $list_langs.=qq~<option value="$item">$a_langs_long[$_cnt]</option>~;
   $_cnt++;
  } 
  return template 'admin_sitemap_index', { lang => $lang, navdata => $navdata, list_langs => $list_langs, authdata => $taracot::taracot_auth_data }, { layout => 'admin' }; 
};

get '/data/tree' => sub {
  if (!&taracot::admin::_auth()) { redirect '/admin?'.md5_hex(time); return true }
  _load_lang();
  content_type 'application/json'; 
  my $lang=param('lang');
  my $langs=config->{lang_available};
  $langs=~s/ //gm;
  my @a_langs=split(/,/, $langs);
  my $flag=0;
  foreach my $lng (@a_langs) {
   if ($lng eq $lang) {
    $flag=1;
   }
  }
  if (!$flag) {
   $lang='en';
  }
  #&_delay(2);
  my $data=loadFile(config->{root_dir}.'/'.config->{data_dir}.'/sitemap_'.$lang.'.json');
  if ($data) {
   return $$data
  } else {
   return qq~[ { "title": "/", "isFolder": "true", "sm_root": "true" } ]~;
  }   
};

post '/data/tree/save' => sub {
  if (!&taracot::admin::_auth()) { redirect '/admin?'.md5_hex(time); return true }
  _load_lang();
  content_type 'application/json'; 
  my $lang=param('lang');
  my $langs=config->{lang_available};
  $langs=~s/ //gm;
  my @a_langs=split(/,/, $langs);
  my $flag=0;
  foreach my $lng (@a_langs) {
   if ($lng eq $lang) {
    $flag=1;
   }
  }
  if (!$flag) {
   $lang='en';
  }
  my $data=param('data');
  my $json=JSON::XS->new->utf8(0)->decode($data);
  $json=$json->{children};
  my $jsoncnv=JSON::XS->new->ascii(1)->pretty(0)->encode($json);
  #$jsoncnv=~s/[\n\r\0]//gm;
  my $res_err=qq~{ "result": "0" }~;
  removeFile(config->{root_dir}.'/'.config->{data_dir}.'/sitemap_'.$lang.'.html');
  open(DATA, '>'.config->{root_dir}.'/'.config->{data_dir}.'/sitemap_'.$lang.'.json') || return $res_err;
  flock(DATA, LOCK_EX) || return $res_err;
  binmode DATA;
  print DATA $jsoncnv || return $res_err;
  close(DATA) || return $res_err;
  #&_delay(2);
  return qq~{ "result": "1" }~;
};

sub _delay() {
 use Time::HiRes;
 Time::HiRes::sleep($_[0]);
}

# End

true;