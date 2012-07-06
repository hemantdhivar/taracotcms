package blocks::blocks::main;
use Dancer ':syntax';
use Digest::MD5 qw(md5_hex);
use taracot::fs;
use Fcntl qw(:flock SEEK_END); # import LOCK_* and SEEK_END constants 

sub new {
 my ($class)=shift;
 my $self = {
     @_,
 };
 bless $self, ref $class || $class || "blocks::blocks::main";
 return $self;
}

my $lang;

sub _load_lang {
  my $lng=shift;
  my $lang_adm = YAML::XS::LoadFile(config->{root_dir}.'lib/blocks/blocks/lang/en.lng') || {};
  my $lang_adm_cnt={};
  if ($lng ne 'en') {
   my $lang_adm_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/blocks/blocks/lang/'.$lng.'.lng') || {};
  }
  $lang = { %$lang_adm, %$lang_adm_cnt };
}

sub data() {
 my $self=shift;
 my $block=shift;
 my $current_lang = &taracot::_detect_lang() || config->{lang_default};
 &_load_lang($current_lang);
 my %reply = (
  block_content => ''  
 );
 if (-e config->{root_dir}.'/'.config->{data_dir}.'/settings_'.$block.'_'.$current_lang.'.html') {
   open(DATA, config->{root_dir}.'/'.config->{data_dir}.'/settings_'.$block.'_'.$current_lang.'.html') || return \%reply;
   flock(DATA, LOCK_EX) || return \%reply;
   binmode DATA, ':utf8';
   my $data=join('', <DATA>);   
   close(DATA) || return \%reply; 
   if ($data) {
    $reply{block_content}=$data;
   }
 } 
 return \%reply;
}

true;