#!/usr/bin/perl

open(RES, '>taracot.min.js');

print "Processing jquery.min.js...\n";

open(DATA, 'jquery.min.js');
my $jq=join('', <DATA>);
close(DATA);
print RES $jq;

open(DATA, 'bootstrap3.min.js');
my $jq=join('', <DATA>);
close(DATA);
print RES $jq;

my @files = <jquery.*.js>;
foreach my $file (@files) {
	if ($file ne 'jquery.min.js') {
		print "Processing $file...\n";
		open(DATA, $file);
		my $fd=join('', <DATA>);
		close(DATA);
		print RES $fd;
	}
}

my @files = <bootstrap.*.js>;
foreach my $file (@files) {
	if ($file ne 'bootstrap3.min.js' && $file ne 'bootstrap.min.js') {
		print "Processing $file...\n";
		open(DATA, $file);
		my $fd=join('', <DATA>);
		close(DATA);
		print RES $fd;
	}
}


close(RES);