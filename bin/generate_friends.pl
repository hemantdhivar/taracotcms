#!/usr/bin/perl
# Search module crawler

# Check configuration variabled below

use strict;
use warnings;
use DBI;
use Dancer ':script';
use Dancer::Plugin::Database;
use Cwd 'abs_path';
use Data::Random::Contact;
use Data::Dumper;

my $crawler_path = dirname(abs_path($0)) || '';
$crawler_path =~ s/bin$//;
Dancer::Config::setting('appdir', $crawler_path);
Dancer::Config::load();

# Do not edit below this line, if you're not sure what you're doing
# Configuration ends here

my $dbh;
my $sth;

sub connect_db {
	my $DSN = 'DBI:mysql:'.config->{plugins}->{Database}->{database}.':'.config->{plugins}->{Database}->{host};
	$dbh = DBI->connect($DSN, config->{plugins}->{Database}->{username}, config->{plugins}->{Database}->{password});
	my $sth = $dbh->prepare("SET NAMES 'utf8'");
 	$sth->execute();
 	$sth->finish();
	$sth = $dbh->prepare("SET CHARACTER SET 'utf8'");
	$sth->execute();
	$sth->finish();
}

sub disconnect_db {
	$dbh->disconnect();
	$dbh = undef;
}

# Connect to DB
&connect_db();

# Insert fake names

my $rn = Data::Random::Contact->new();


# print Dumper $rn->person();

for (my $i=2; $i<100; $i++) {
	$sth = database->prepare('INSERT INTO '.config->{db_table_prefix}.'_social_friends SET user1=1, user2='.$i.', status=1');
	$sth->execute();
	$sth->finish(); 
}

# Disconnect from DB
&disconnect_db();