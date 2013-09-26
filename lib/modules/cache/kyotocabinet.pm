package modules::cache::kyotocabinet;

use Dancer ':syntax';
use KyotoCabinet;

my $db;

sub new {
 my ($class)=shift;
 my $self = {
     @_,
 };
 bless $self, ref $class || $class || "modules::cache::kyotocabinet";
 $db = new KyotoCabinet::DB;
 $db->open(config->{root_dir}.'/'.config->{data_dir}.'/taracot_cache.kch', $db->OWRITER | $db->OCREATE) || die $db->error;
 return $self;
}

sub set_data {  	
  my $self = shift;
  my $par = $_[0];
  my $val = $_[1];
  $db->set($par, $val);
  return $db->error;
}

sub get_data {
  my $self = shift;
  my $par = $_[0];
  my $value = $db->get($par);
  return $value;  
}

sub flush_data {  
}

sub DESTROY {
  $db->close || die $db->error;
}

# End

1; 