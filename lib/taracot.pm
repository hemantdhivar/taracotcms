package taracot;

use Dancer ':syntax';
use Dancer::Plugin::Database;
use taracot::admin;
use Module::Load;
use taracot::loadpm;
use Imager;
use Imager::Fill;
use Imager::Matrix2d;
use JSON::XS();

prefix undef;

our $taracot_current_version='0.20528';

# Don't show any warnings to console in production mode
if (config->{environment} eq 'production') {
  $SIG{__WARN__} = sub {};
}

my $load_modules = config->{load_modules_frontend};
$load_modules=~s/ //gm;
my @modules = split(/,/, $load_modules);
foreach my $module (@modules) {
  my $taracot_module_load="modules::".lc($module)."::main";
  load $taracot_module_load;
}

my $load_blocks = config->{load_blocks_frontend};
$load_blocks=~s/ //gm;
my @blocks = split(/,/, $load_blocks);
foreach my $block (@blocks) {
  my $taracot_block_load="blocks::".lc($block)."::main";
  loadpm $taracot_block_load;   
}

hook before => sub {
  # Firewall-related routines
  if (config->{firewall_mode} eq 'blacklist' || config->{firewall_mode} eq 'whitelist') {
    my $remote_ip = $ENV{'HTTP_X_REAL_IP'};
    if (!$remote_ip) {
      $remote_ip = $ENV{REMOTE_ADDR} || $ENV{REMOTE_HOST} || 'unknown';
    }
    my $remote_ip_p1 = $remote_ip;
    $remote_ip_p1 =~s/\.[\d]+$//;
    my $remote_ip_p2 = $remote_ip_p1;
    $remote_ip_p2 =~s/\.[\d]+$//;    
    my $id;
    my $status;
    my $sth = database->prepare(
     'SELECT id, status FROM '.config->{db_table_prefix}.'_firewall WHERE ipaddr='.database->quote($remote_ip).' OR ipaddr='.database->quote($remote_ip_p1).' OR ipaddr='.database->quote($remote_ip_p2)
    );
    if ($sth->execute()) {
      ($id, $status) = $sth -> fetchrow_array;
    }
    $sth->finish();
    if (config->{firewall_mode} eq 'blacklist') {
      if ($id && $status eq 0) {
        request->path_info('/403');
        return;
      }
    }
    if (config->{firewall_mode} eq 'whitelist') {
      if ($status ne 1) {
        request->path_info('/403');
        return;
      }
    }
  }  
};

sub _auth() {
  my $authdata;
  if (session('user')) { 
   my $id = session('user');
   $authdata  = database->quick_select(config->{db_table_prefix}.'_users', { id => $id });
   my %grpdata;
   if ($authdata->{groups}) {
      my @groups=split(/,/, $authdata->{groups});   
      my @groups_arr;  
      foreach my $item(@groups) {
        $item =~ s/^\s+//;
        $item =~ s/\s+$//;
        $item =~ tr/ //s;
        $item = lc($item);
        $grpdata{$item} = 1;
        push @groups_arr, $item;
      }
      $authdata->{groups_hash} = \%grpdata;
      $authdata->{groups_arr} = \@groups_arr;
   }
  } else {
   $authdata->{id} = 0;
   $authdata->{status} = 0;
   $authdata->{username} = '';
   $authdata->{password} = '';   
  }
  if ($authdata->{status}) {
   if ($authdata->{status} > 0) {
    return $authdata;
   } 
  }
  return undef;
};

sub _load_settings() {
  my $pars = $_[0];
  my $lang = $_[1];
  $pars=~s/ //gm;
  my @par=split(/,/, $pars);
  my $sql='';
  my %data;
  foreach my $item (@par) {
    $sql.=qq~ OR `s_name`=~.database->quote($item);
  }
  $sql=~s/ OR //;  
  my $sth; 
  $sth = database->prepare(
   'SELECT s_name, s_value FROM '.config->{db_table_prefix}.'_settings WHERE ('.$sql.') AND lang='.database->quote($lang).' OR lang=NULL OR lang=\'\''
  );
  if ($sth->execute()) {
   while(my ($s_name, $s_value) = $sth -> fetchrow_array) {
    $data{$s_name}=$s_value;
   } # while     
  } 
  $sth->finish();  
  return \%data;
} 

prefix "/";

my $lang;

sub _detect_lang() {
 my $resp = {}; 
 my $lng;
 my @lst;
 if (defined request) {
    my $_uribase = $_[0] || request->uri_base();
    $_uribase=~s/http(s)?\:\/\///im;
    my ($lang)=split(/\./, $_uribase);
    my $lang_avail=lc config->{lang_available};
    $lang_avail=~s/ //gm;
    my $lang_avail_long=config->{lang_available_long};
    $lang_avail_long=~s/ //gm;
    my (@langs)=split(/,/, $lang_avail);
    my (@langs_long)=split(/,/, $lang_avail_long);
    my $cnt=0;
    foreach my $item(@langs) {
      my $ln = {};
      if (config->{lang_default} eq $item) {
        $ln->{default} = '1';
      }
      $ln->{short} = $item;
      $ln->{long} = $langs_long[$cnt];
      push @lst, $ln;
      $cnt++;
    }    
    if (exists {map { $_ => 1 } @langs}->{$lang}) {
     $lng=$lang;
    }                 
 }
 my $json_xs = JSON::XS->new();
 $resp->{lng} = $lng || 'en';
 $resp->{list} = $json_xs->encode(\@lst); 
 return $resp;
}

sub _load_lang {          
  my $dl = _detect_lang();
  my $lng = $dl->{lng} || config->{lang_default};
  my $lang_mod = YAML::XS::LoadFile(config->{root_dir}.'lib/taracot/lang/en.lng') || {};
  my $lang_mod_cnt={};
  if ($lng ne 'en') {
   $lang_mod_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/taracot/lang/'.$lng.'.lng') || {};
  }
  $lang = { %$lang_mod, %$lang_mod_cnt };
  return $lng;
} 

sub _process_template {
 my $taracot_render_template=$_[0];
 my $_current_lang=_load_lang();
 if ($taracot_render_template) {
   my %blocks;
   my $load_blocks = config->{load_blocks_frontend};
   $load_blocks=~s/ //gm;
   my @blocks = split(/,/, $load_blocks);
   foreach my $block (@blocks) {
      my $taracot_block_load="blocks::".lc($block)."::main";
      loadpm $taracot_block_load; 
      my $md=$taracot_block_load->new(lang => $lang, current_lang => $_current_lang);
      my $data=$md->data();
      $blocks{$block}=$data->{block_content};
      undef($md);
   }
   while (my ($name, $value) = each(%blocks)){
    $taracot_render_template =~ s/\[\% ?$name ?\%\]/$value/igm;
   }
   $taracot_render_template =~ s/\[\% current_lang ?\%\]/$_current_lang/gm;   
   return $taracot_render_template;
 }
 return undef;
}

get '/captcha_img' => sub {
  content_type 'image/png';
  my $code=int(rand(10000));  
  while (length($code)<4) {
    $code='0'.$code;
  }
  session captcha => $code; 
  my @fills=('vline1', 'vline2', 'vline4', 'hline1', 
             'hline2', 'hline4', 'slash1', 'slash2', 'slosh1', 'slosh2', 'grid1', 'grid2', 
             'grid4', 'cross2', 'vlozenge', 'hlozenge', 'scalesdown', 'scalesup', 'scalesleft', 
             'scalesright', 'tile_L');
  my $image = Imager->new(xsize => 110, ysize => 50, channels => 4);
  my $color1 = Imager::Color->new( int(rand(100))+150, int(rand(100))+150, int(rand(100))+150 );
  my $color2 = Imager::Color->new( int(rand(50)), int(rand(50)), int(rand(50)) );
  my $fill = Imager::Fill->new(hatch=>@fills[int(rand(@fills))], fg=>$color1, bg=>$color2, dx=>int(rand(30)), dy=>int(rand(30)) );
  my $font = Imager::Font->new(file => config->{root_dir}.'/fonts/'.config->{captcha_font} );
  $image->box(fill=>$fill);  
  my $offset=10+int(rand(8));
  foreach my $char (split(//, $code)) {
   my $deg = int(rand(30));
   if ($deg > 15) {
    $deg=-$deg;
   }
   my $matrix = Imager::Matrix2d->rotate(degrees => $deg); 
   $font->transform(matrix => $matrix);  
   $image->string(string => $char, x => $offset, y => 30+int(rand(10)), color => $color1, font => $font, size  => 20+int(rand(10)), aa => int(rand(2)));
   $offset=$offset+15+int(rand(8));
  } 
  $image->filter(type=>"conv", coef=>[-0.5, 2, -0.5 ]);
  $image->filter(type=>"gaussian", stddev=>0.5);
  $image = $image->convert(preset=>'grey');
  #$image->filter(type=>"conv", coef=>[ 1, 2, 1 ]);
  my $data;  
  $image->write(data => \$data, type => 'png') or die $image->errstr;
  return $data;
};

get '/403' => sub { 
 &_load_lang;
 status 'forbidden';
 my $render_403 = template 'error_403', { lang => $lang }, { layout => undef };
 return $render_403;
};

any qr{.*} => sub { 
 &_load_lang;
 status 'not_found';
 my $render_404 = template 'error_404', { lang => $lang }, { layout => undef };
 return $render_404;
};

true;