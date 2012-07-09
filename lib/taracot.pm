package taracot;

use Dancer ':syntax';
use taracot::admin;
use Module::Load;
use taracot::loadpm;

prefix undef;

our $taracot_render_template=undef;
our $taracot_auth_data;
our $taracot_current_version='0.20527';

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