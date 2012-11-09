#!/usr/bin/perl
use utf8;

get_files('../../public/css');

sub get_files {
 chdir $_[0];
 my @files = <*>;
 foreach my $file (@files) {
 	if (-d $file) {
 		&get_files($file);
 	}
 	if ($file=~m/\.css/i) {
 		print "File found: $file\n";
 		system ('uglifycss '.$file.' > '.$file.'.min');
 		system ('del '.$file);
 		system ('rename '.$file.'.min '.$file);
 	}
 }
}