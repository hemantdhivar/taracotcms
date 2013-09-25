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

sub add {
}

sub get {
}

# End

1; 