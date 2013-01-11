package modules::files::main;
use Dancer ':syntax';
use JSON::XS qw();
use taracot::fs;
use Text::Unidecode;
use Digest::MD5 qw(md5_hex);

# Configuration

my $defroute = '/admin/files';
my @known_types = ('avi','bmp','css','doc','docx','gif','html','jpg','js','mov','mp3','mp4','mpg','pdf','php','png','ppt','pptx','rar','txt','xls','xlsx','xml','zip');

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
  my $dl = &taracot::_detect_lang();
  my $lng = $dl->{lng} || config->{lang_default};
  my $lang_adm = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/files/lang/en.lng') || {};
  my $lang_adm_cnt={};
  if ($lng ne 'en') {
   $lang_adm_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/files/lang/'.$lng.'.lng') || {};
  }
  my $lang_mod = YAML::XS::LoadFile(config->{root_dir}.'lib/taracot/lang/en.lng') || {};
  my $lang_mod_cnt={};
  if ($lng ne 'en') {
   $lang_mod_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/taracot/lang/'.$lng.'.lng') || {};
  }
  $lang = { %$lang_adm, %$lang_mod, %$lang_adm_cnt, %$lang_mod_cnt };
  return $lng;
}

sub getFileSizeStr {
  my $file = shift;
  my $size = (stat($file))[7] || die "stat($file): $!\n";
  if ($size > 1099511627776) { return sprintf("%.2f ".$lang->{size_tb}, $size / 1099511627776); }
   elsif ($size > 1073741824) { return sprintf("%.2f ".$lang->{size_gb}, $size / 1073741824); }
    elsif ($size > 1048576) { return sprintf("%.2f ".$lang->{size_mb}, $size / 1048576); }
     elsif ($size > 1024) { return sprintf("%.2f ".$lang->{size_kb}, $size / 1024); } 
      else { return sprintf("%.2f ".$lang->{size_b}, $size); }
}

# Backend Routes

prefix $defroute;

get '/' => sub {
  my $auth = &taracot::admin::_auth();
  if (!$auth) { redirect '/admin?'.md5_hex(time); return true }
  _load_lang();
  my $navdata=&taracot::admin::_navdata();
  return template 'admin_files_index', { lang => $lang, navdata => $navdata, authdata => $auth }, { layout => 'admin' }; 
};

post '/storage/list' => sub {
  my $auth = &taracot::admin::_auth();
  if (!$auth) { redirect '/admin?'.md5_hex(time); return true }
  _load_lang();
  my $dir=config->{files_dir}.'/storage/';
  opendir(IMD, $dir) || die($lang->{dir_error});
  my @files=();
  while (my $file = readdir(IMD)) {
   next if ($file =~ m/^\./);
   my $ext=($file =~ m/([^.]+)$/)[0];
   my $type;
   foreach my $ft (@known_types) {
    if (lc $ext eq $ft) {
     $type=$ft;
    }
   }
   if (!$type) {
    $type='unknown';
   }
   my $size=getFileSizeStr(config->{files_dir}.'/storage/'.$file);
   my %frec = ( 
    name => $file,
    type => $type,
    size => $size  
   ); 
   push (@files, \%frec);
  }
  closedir(IMD);
  content_type 'application/json';
  my $json_xs = JSON::XS->new();
  my $json = $json_xs->encode( \@files );
  return $json;
};

sub _delay() {
 use Time::HiRes;
 Time::HiRes::sleep($_[0]);
}

post '/storage/upload' => sub {
  if (!&taracot::admin::_auth()) { redirect '/admin?'.md5_hex(time); return true }
  _load_lang();
  content_type 'application/json';
  my $file=upload('file');
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
  my $fp=config->{files_dir}."/storage/".$fn;
  $fp=~s/\/\//\//gm;
  $file->copy_to($fp);
  return '{"filename":"'.$fn.'","dir":"'.param('dir').'"}';
}; 

post '/storage/delete' => sub {
  if (!&taracot::admin::_auth()) { redirect '/admin?'.md5_hex(time); return true }
  _load_lang();
  content_type 'application/json';
  my $file=param('filename');
  if (!defined $file) {
   return '{"error":"1","reason":"bad_upload"}';
  } 
  if ($file =~ m/\.\./) {
   return '{"error":"1","reason":"filename_syntax"}';
  }
  my $fp=config->{files_dir}."/storage/".$file;
  $fp=~s/\/\//\//gm;
  if (!-e $fp) {
   return '{"result":"0"}';
  }
  my $res=removeFile($fp);
  if ($res) {
   return '{"result":"1"}';
  } else {
   return '{"result":"0"}';
  }  
}; 

# End

true;