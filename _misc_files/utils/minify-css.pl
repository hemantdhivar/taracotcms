#!/usr/bin/perl
use utf8;
use strict;
use warnings;

get_files('../public');

sub get_files {
 chdir $_[0];
 my @files = <*>;
 foreach my $file (@files) {
 	if (-d $file) {
 		&get_files($file);
 		chdir('..');
 	}
 	if ($file=~m/\.css/i) {
 		print "File found: $file\n";
 		system ('uglifycss '.$file.' > '.$file.'.min');
 		system ('rm '.$file);
 		system ('mv '.$file.'.min '.$file);
 	}
 } 
}