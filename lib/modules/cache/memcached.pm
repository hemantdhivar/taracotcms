package modules::cache::memcached;
use Time::HiRes qw ( time );
use Dancer ':syntax';
use Cache::Memcached::Fast;

my $memd;

sub new {
 my ($class)=shift;
 my $self = {
     @_,
 };
 bless $self, ref $class || $class || "modules::cache::memcached";
 $memd = new Cache::Memcached::Fast({
      servers => [ { address => 'localhost:11211', weight => 1 } ],
      namespace => config->{cache_prefix}.':',
      connect_timeout => 0.2,
      io_timeout => 0.5,
      close_on_error => 1,
      compress_threshold => 100_000,
      compress_ratio => 0.9,
      compress_methods => [ \&IO::Compress::Gzip::gzip,
                            \&IO::Uncompress::Gunzip::gunzip ],
      max_failures => 3,
      failure_timeout => 2,
      ketama_points => 150,
      nowait => 1,
      hash_namespace => 1,
      serialize_methods => [ \&Storable::freeze, \&Storable::thaw ],
      utf8 => ($^V ge v5.8.1 ? 1 : 0),
      max_size => 512 * 1024,
 }); 
 return $self;
}

sub set_data {  	
  my $self = shift;
  my $par = $_[0];
  my $val = $_[1];
  $memd->add($par, $val, config->{cache_timeout});
}

sub get_data {
  my $self = shift;
  my $par = $_[0];
  return $memd->get($par);
}

sub flush_data {
  $memd->flush_all;
}

# End

1; 