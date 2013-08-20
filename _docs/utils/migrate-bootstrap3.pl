#!/usr/bin/perl
use utf8;

get_files('../../views');

sub get_files {
 chdir $_[0];
 my @files = <*>;
 foreach my $file (@files) {
 	if (-d $file) {
 		&get_files($file);
 		chdir('..');
 	}
 	if ($file=~m/\.tt/i) {
 		print "File found: $file\n";
 		open(DATA, $file);
 		binmode(DATA);
 		my $tmp = join('', <DATA>);
 		close(DATA);
 		$tmp=~s/container\-fluid/container/gm;
 		$tmp=~s/span(\d)+/col-md-$1/gm;
 		$tmp=~s/offset(\d)+/col-md-offset-$1/gm;
 		$tmp=~s/brand/navbar-brand/gm;
 		$tmp=~s/navbar nav/nav navbar-nav/gm;
 		$tmp=~s/hero\-unit/jumbotron/gm;
 		$tmp=~s/icon\-(*.)+(/col-md-$1/gm;
 	}
 } 
}