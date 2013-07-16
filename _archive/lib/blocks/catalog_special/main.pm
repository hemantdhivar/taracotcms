package blocks::catalog_special::main;
use Dancer ':syntax';
use Digest::MD5 qw(md5_hex);
use taracot::fs;
use Fcntl qw(:flock SEEK_END); # import LOCK_* and SEEK_END constants 

sub new {
 my ($class)=shift;
 my $self = {
     @_,
 };
 bless $self, ref $class || $class || "blocks::catalog_special::main";
 return $self;
}

my $lang;

sub _load_lang {
  my $lng=shift;
  my $lang_adm = YAML::XS::LoadFile(config->{root_dir}.'lib/blocks/catalog_special/lang/en.lng') || {};
  my $lang_adm_cnt={};
  if ($lng ne 'en') {
   my $lang_adm_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/blocks/catalog_special/lang/'.$lng.'.lng') || {};
  }
  $lang = { %$lang_adm, %$lang_adm_cnt };
}

sub data() {
 my $self=shift;
 my $dl = &taracot::_detect_lang();
 my $current_lang = $dl->{lng} || config->{lang_default};
 &_load_lang($current_lang);
 my %reply = (
  block_content => ''  
 );
 open(DATA, config->{root_dir}.'/'.config->{data_dir}.'/special_'.$current_lang.'.html') || return \%reply;
 flock(DATA, LOCK_EX) || return \%reply;
 binmode DATA, ':utf8';
 my $data=join('', <DATA>);
 close(DATA) || return \%reply; 
 if ($data) {
  $reply{block_content}=$data;
 }
 return \%reply;
}

true;