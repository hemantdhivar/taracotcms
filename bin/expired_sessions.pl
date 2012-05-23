#! /usr/bin/perl
# 
# Dancer session expiration script.
#
# Copyright (C) 2011 Stefan Hornburg (Racke) <racke@linuxia.de>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public
# License along with this program; if not, write to the Free
# Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston,
# MA  02110-1301  USA.
#

use strict;
use warnings;

use Dancer ':script';

use File::stat;
use Time::Duration::Parse;

my ($now, $expires, $duration, $session_dir, $file, $file_st);

$expires = config->{session_expires};
$session_dir = config->{session_dir};

# converting to seconds
if (defined $expires) {
    if ($expires =~ /^\d+$/) {
	# already got seconds
	$duration = $expires;
    }
    else {
	$duration = parse_duration($expires);
    }
}

unless ($duration) {
    die "$0: Session expiration not set.\n";
}

# get current time
$now = time();

# go through session directory looking for expired sessions
opendir(SESSIONS, $session_dir)
    || die "$0: Failed to open directory: $session_dir: $!.\n";

while ($file = readdir(SESSIONS)) {
    # skip directories etc
    next unless -f "$session_dir/$file";

    # sanity check on file names for sessions
    if ($file !~ /\d{18,}/) {
	warn "$0: Skipping suspicious file in session directory: $file.\n";
	next;
    }

    $file_st = stat("$session_dir/$file");

    unless ($file_st) {
	die "$0: Failed to get file information from $file: $!.\n";
    }

    if ($file_st->mtime < $now - $duration) {
	unless (unlink("$session_dir/$file")) {
	    die "$0: Failed to remove expired session $file: $!.\n";
	}
    }
}

closedir(SESSIONS);