package modules::cache::kyototycoon;

use Dancer ':syntax';
use Cache::KyotoTycoon;

my $kt;

sub new {
 my ($class)=shift;
 my $self = {
     @_,
 };
 bless $self, ref $class || $class || "modules::cache::kyototycoon";
 $kt = Cache::KyotoTycoon->new(host => '127.0.0.1', port => 1978);
 return $self;
}

sub set_data {  	
  my $self = shift;
  my $par = $_[0];
  my $val = $_[1];
  $kt->set($par => $val);
}

sub get_data {
  my $self = shift;
  my $par = $_[0];
  return $kt->get($par);
}

sub flush_data { 
}

# End

1; 