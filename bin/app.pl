#!/usr/bin/perl
if (-e '../installation/install_part1.pl' || -e '../installation/install_part2.pl') {
	print "Please delete installation folder first\n";
	exit;
}
use Dancer;
use taracot;
dance;