package modules::sitemap::main;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use JSON::XS qw();
use taracot::fs;
use Fcntl qw(:flock SEEK_END); # import LOCK_* and SEEK_END constants
use Encode qw(encode decode);

# Configuration

my $defroute = '/admin/sitemap';

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
  my $lang_adm = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/sitemap/lang/en.lng') || {};
  my $lang_adm_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/sitemap/lang/'.$lng.'.lng') || {};
  my $lang_mod = YAML::XS::LoadFile(config->{root_dir}.'lib/taracot/lang/en.lng') || {};
  my $lang_mod_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/taracot/lang/'.$lng.'.lng') || {};
  $lang = { %$lang_adm, %$lang_mod, %$lang_adm_cnt, %$lang_mod_cnt };
  return $lng;
}

# Backend Routes

prefix $defroute;

get '/' => sub {
  # Important! Access control
  if (!_auth()) { return true; }
  # End: Important! Access control
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
  return template 'sitemap_index', { lang => $lang, navdata => $navdata, authdata => $authdata, list_langs => $list_langs }, { layout => 'admin' }; 
};

get '/data/tree' => sub {
  # Important! Access control
  if (!_auth()) { return true; }
  # End: Important! Access control
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
  # Important! Access control
  if (!_auth()) { return true; }
  # End: Important! Access control
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