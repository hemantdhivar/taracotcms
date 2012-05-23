#!C:\Perl\perl\bin\perl.exe
use Dancer ':syntax';
use FindBin '$RealBin';
use Plack::Runner;

set apphandler => 'PSGI';
set environment => 'production';

my $psgi = path($RealBin, '..', 'bin', 'app.pl');
die "Unable to read startup script: $psgi" unless -r $psgi;

Plack::Runner->run($psgi);
