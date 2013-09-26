package modules::cache::dummy;

use Dancer ':syntax';

sub new {
 my ($class)=shift;
 my $self = {
     @_,
 };
 bless $self, ref $class || $class || "modules::cache::dummy";
 return $self;
}

sub set_data {
}

sub get_data {
	return undef;
}

sub flush_data {  
}

# End

1; 