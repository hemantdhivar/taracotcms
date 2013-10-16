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
 	if ($file=~m/\.js/i) {
 		print 'uglifyjs ' . $file . ' -c > ' . $file . '.min' ."\n";
 		system ('uglifyjs '.$file.' -c > '.$file.'.min');
 		system ('rm '.$file);
 		system ('mv '.$file.'.min '.$file);
 	}
 } 
}