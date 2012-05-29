package modules::imgbrowser::main;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use JSON::XS();
use Digest::MD5 qw(md5_hex);
#use taracot::loadpm;
use JSON::XS();
use Text::Unidecode;
use Imager;
use taracot::fs;
use Digest::MD5 qw(md5_hex);
use File::Basename qw(fileparse);

# Configuration

my $defroute = '/admin/imgbrowser';

# Module core settings 

my $authdata;
my $lang;

sub _defroute() {
  return $defroute;
}
sub _load_lang {
  my $lng = &taracot::_detect_lang() || config->{lang_default};
  my $lang_adm = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/imgbrowser/lang/en.lng') || {};
  my $lang_adm_cnt={};
  if ($lng ne 'en') {
   $lang_adm_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/imgbrowser/lang/'.$lng.'.lng') || {};
  }
  my $lang_mod = YAML::XS::LoadFile(config->{root_dir}.'lib/taracot/lang/en.lng') || {};
  my $lang_mod_cnt={};
  if ($lng ne 'en') {
   $lang_mod_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/taracot/lang/'.$lng.'.lng') || {};
  }
  $lang = { %$lang_adm, %$lang_mod, %$lang_adm_cnt, %$lang_mod_cnt };
  return $lng;
}

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

# Frontend Routes

prefix $defroute;

get '/' => sub {             
  if (!&taracot::admin::_auth()) { redirect '/admin?'.md5_hex(time); return true }
  my $_current_lang=_load_lang();
  return template 'imgbrowser_index', { lang => $lang, pagetitle => $lang->{pagetitle}, files_url => config->{files_url} }, { layout => 'browser_'.$_current_lang };
};

get '/dirdata' => sub {
  if (!&taracot::admin::_auth()) { redirect '/admin?'.md5_hex(time); return true }
  _load_lang();
  my $dir=param('dir');
  if ($dir !~ /^[\.A-Za-z0-9_\-\/]{0,200}$/ || $dir eq '/' || $dir =~ m/\.\./) {
   $dir='';
  } 
  if ($dir) {
   if (!-d config->{files_dir}.'/images/'.$dir) {
    $dir='';
   }
  }
  my $up_dir=$dir;
  my @pathary = split(/\//,$up_dir);
  $up_dir = join('/',@pathary[0..$#pathary-1]);
  my %resp = ( 
   current_dir => $dir,
   up_dir => $up_dir,
   files => getDir(config->{files_dir}.'/images/'.$dir, $dir)  
  );  
  my $json_xs = JSON::XS->new();
  my $json = $json_xs->encode(\%resp);
  content_type 'application/json'; 
  return $json;
};

post '/upload' => sub {
  if (!&taracot::admin::_auth()) { redirect '/admin?'.md5_hex(time); return true }
  _load_lang();
  content_type 'application/json';
  my $file=upload('file');
  my $dir=param('dir');
  if ($dir !~ /^[\.A-Za-z0-9_\-\/]{0,200}$/ || $dir eq '/' || $dir =~ m/\.\./) {
   return '{"error":"1","reason":"dir_syntax"}';
  }
  if (!-d config->{files_dir}."images/".$dir) {
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
  my $fp=config->{files_dir}."images/".$dir.'/'.$fn;
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
   $img = $img->scale(xpixels=>100, ypixels=>100);
   $img->write(file => config->{files_dir}."images/".$dir.'/.'.md5_hex($fn).'.jpg');
  }
  return '{"filename":"'.$fn.'","dir":"'.param('dir').'"}';
};

post '/paste' => sub {
  if (!&taracot::admin::_auth()) { redirect '/admin?'.md5_hex(time); return true }
  _load_lang();
  content_type 'application/json';
  my $dir_from=param('dir_from');
  my $dir_to=param('dir_to');
  my $mode=param('mode');
  my $data=param('data[]');
  my @files=[];
  if(ref($data) eq 'ARRAY'){
   @files=@$data;
  } else {
   push(@files, '');
   $files[0]=$data;
  }
  if ($mode ne 'copy' && $mode ne 'cut') {
   return '{"status":"0","error":"'.$lang->{bad_mode}.'"}';
  }
  my $cnt=@files;
  if ($cnt eq 0) {
   return '{"status":"0","error":"'.$lang->{no_files}.'"}';
  }
  if ($dir_from !~ /^[\.A-Za-z0-9_\-\/]{0,200}$/ || $dir_from eq '/' || $dir_from =~ m/\.\./ || !-d config->{files_dir}."images/".$dir_from) {
   return '{"status":"0","reason":"'.$lang->{dir_syntax_error}.'"}';
  }
  foreach my $item (@files) {
   $item =~ s/\.\.//gm;
   my ($srcname)=fileparse($item);
   if (!$srcname) {
    $srcname=$item;
   }
   my $src=config->{files_dir}."images/".$dir_from.'/';
   $src=~s/\/\//\//gm;
   my $dst=config->{files_dir}."images/".$dir_to.'/';
   $dst=~s/\/\//\//gm;
   if (!$srcname || !-e $src.$srcname) {
    next;
   }
   my $type;
   my $res=undef;
   if (-d $src.'/'.$srcname) {
    $type='d';
    if (index($dst, $src.$srcname) eq 0) {
     return '{"status":"0","reason":"'.$lang->{dir_syntax_error}.'"}';
    }
    if ($mode eq 'cut') {
     $res=moveDir($src.$srcname, $dst.$srcname);
    } else {
     $res=copyDir($src.$srcname, $dst.$srcname);
    }
   }
   if (-e $src.'/'.$srcname && !-d $src.'/'.$srcname) {
    $type='f';
    if ($mode eq 'cut') {
     $res=moveFile($src.$srcname, $dst.$srcname);
     my $md5n=md5_hex($srcname);
     if (-e $src.'.'.$md5n.'.jpg') {
      $res=moveFile($src.'.'.$md5n.'.jpg', $dst);
     }
    } else {
     $res=copyFile($src.$srcname, $dst.$srcname);
     my $md5n=md5_hex($srcname);
     if (-e $src.'.'.$md5n.'.jpg') {
      $res=copyFile($src.'.'.$md5n.'.jpg', $dst);
     }
    }
   }
   if (!$type) {
    return '{"status":"0","reason":"'.$lang->{not_exists}.'","file":"'.$item.'"}';
   }
   if (!$res && $item) {
    return '{"status":"0","reason":"'.$lang->{file_error}.'","file":"'.$item.'"}';
   }
  }
  return '{"status":"1"}';
};

post '/newdir' => sub {
  if (!&taracot::admin::_auth()) { redirect '/admin?'.md5_hex(time); return true }
  _load_lang();
  content_type 'application/json';
  my $new_dir=param('new_dir');
  if ($new_dir !~ /^[\.A-Za-z0-9_\-]{0,100}$/ || $new_dir =~ m/\.\./) {
   return '{"status":"0","reason":"'.$lang->{dir_syntax_error}.'"}';
  }
  my $dir=param('dir');
  if ($dir !~ /^[\.A-Za-z0-9_\-\/]{0,200}$/ || $dir eq '/' || $dir =~ m/\.\./ || !-d config->{files_dir}."images/".$dir) {
   return '{"status":"0","reason":"'.$lang->{dir_syntax_error}.'"}';
  }
  my $res=makeDir(config->{files_dir}."images/".$dir.'/'.$new_dir);
  if (!$res) {
    return '{"status":"0","reason":"'.$lang->{newdir_error}.'"}';
  }
  return '{"status":"1"}';
};

post '/rename' => sub {
  if (!&taracot::admin::_auth()) { redirect '/admin?'.md5_hex(time); return true }
  _load_lang();
  content_type 'application/json';
  my $dir=param('dir');
  if ($dir !~ /^[\.A-Za-z0-9_\-\/]{0,200}$/ || $dir eq '/' || $dir =~ m/\.\./ || !-d config->{files_dir}."images/".$dir) {
   return '{"status":"0","reason":"'.$lang->{dir_syntax_error}.'"}';
  }
  my $old_name=param('old_name');
  if ($old_name !~ /^[\.A-Za-z0-9_\-]{1,100}$/ || $old_name =~ m/\.\./ || !-e config->{files_dir}."images/".$dir.'/'.$old_name) {
   return '{"status":"0","reason":"'.$lang->{not_exists}.'"}';
  }
  my $new_name=param('new_name');
  if ($new_name !~ /^[\.A-Za-z0-9_\-]{1,100}$/ || $new_name =~ m/\.\./) {
   return '{"status":"0","reason":"'.$lang->{file_syntax_error}.'"}';
  }
  my $res=undef;
  if (-d config->{files_dir}."images/".$dir.'/'.$old_name) {
   $res=moveDir(config->{files_dir}."images/".$dir.'/'.$old_name, config->{files_dir}."images/".$dir.'/'.$new_name);
  } else {
   $res=moveFile(config->{files_dir}."images/".$dir.'/'.$old_name, config->{files_dir}."images/".$dir.'/'.$new_name);
   my $md5n=md5_hex($old_name);
   if (-e config->{files_dir}."images/".$dir.'/.'.$md5n.'.jpg') {
    $res=moveFile(config->{files_dir}."images/".$dir.'/.'.$md5n.'.jpg', config->{files_dir}."images/".$dir.'/.'.md5_hex($new_name).'.jpg');
    }
  }
  if (!$res) {
    return '{"status":"0","reason":"'.$lang->{rename_error}.'"}';
  }
  return '{"status":"1"}';
};

post '/delete' => sub {
  if (!&taracot::admin::_auth()) { redirect '/admin?'.md5_hex(time); return true }
  _load_lang();
  content_type 'application/json';
  my $dir=param('dir');
  if ($dir !~ /^[\.A-Za-z0-9_\-\/]{0,200}$/ || $dir eq '/' || $dir =~ m/\.\./ || !-d config->{files_dir}."images/".$dir) {
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
   if ($delete_file !~ /^[\.A-Za-z0-9_\-]{1,100}$/ || $delete_file =~ m/\.\./ || !-e config->{files_dir}.'images/'.$dir.'/'.$delete_file) {
    return '{"status":"0","reason":"'.$lang->{file_syntax_error}.'","file":"'.$delete_file.'"}';
   }
   my $res=undef;
   if (-d config->{files_dir}."images/".$dir.'/'.$delete_file) {
    $res=removeDir(config->{files_dir}."images/".$dir.'/'.$delete_file);
   } else {
    $res=removeFile(config->{files_dir}."images/".$dir.'/'.$delete_file);
   }
   if (!$res) {
    return '{"status":"0","reason":"'.$lang->{delete_error}.'"}';
   }
  }
  return '{"status":"1"}';
};

# End

true;