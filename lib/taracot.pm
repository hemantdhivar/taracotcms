package taracot;

use Dancer ':syntax';
use taracot::admin;
use Module::Load;
use taracot::loadpm;
use Imager;
use Imager::Fill;
use Imager::Matrix2d;

prefix undef;

our $taracot_render_template=undef;
our $taracot_auth_data;
our $taracot_current_version='0.20528';

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

prefix "/";

my $lang;

sub _detect_lang() {
 my $lng;
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
 return $lng; 
}

sub _load_lang {          
  my $lng = _detect_lang() || config->{lang_default};
  my $lang_mod = YAML::XS::LoadFile(config->{root_dir}.'lib/taracot/lang/en.lng') || {};
  my $lang_mod_cnt={};
  if ($lng ne 'en') {
   $lang_mod_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/taracot/lang/'.$lng.'.lng') || {};
  }
  $lang = { %$lang_mod, %$lang_mod_cnt };
  return $lng;
} 

get '/captcha_img' => sub {
  content_type 'image/png';
  my $code=int(rand(10000));
  while (length($code)<4) {
    $code='0'.$code;
  }
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

any qr{.*} => sub {
 my $_current_lang=_load_lang();
 if ($taracot_render_template) {
   my %blocks;
   my $load_blocks = config->{load_blocks_frontend};
   $load_blocks=~s/ //gm;
   my @blocks = split(/,/, $load_blocks);
   foreach my $block (@blocks) {
      my $taracot_block_load="blocks::".lc($block)."::main";
      loadpm $taracot_block_load; 
      my $md=$taracot_block_load->new(authdata => $taracot_auth_data, lang => $lang, current_lang => $_current_lang);
      my $data=$md->data();
      $blocks{$block}=$data->{block_content};
      undef($md);
   }
   while (my ($name, $value) = each(%blocks)){
    $taracot_render_template =~ s/\[\% ?$name ?\%\]/$value/igm; 
   }
   my $render = $taracot_render_template;
   $taracot_render_template=undef;
   $taracot_auth_data=undef;
   return $render;
 }
 status 'not_found';
 my $render_404 = template 'error_404', { lang => $lang }, { layout => undef };
 return $render_404;
};

true;