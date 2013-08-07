#!/usr/bin/perl
if (-e '../installation/install1_modules.pl' || -e '../installation/install2_settings.pl' || -e '../installation/install3_database.pl') {
	print "Please delete installation folder first\n";
	exit;
}
use Dancer;
use taracot;
dance;