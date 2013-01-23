#!/usr/bin/perl	
# Taracot crontab script
# Check configuration variabled below

use strict;
use warnings;
use DBI;
use Dancer ':script';
use Log::Trivial;
use Cwd 'abs_path';
use HTML::Entities qw(encode_entities_numeric);

my $daemon_path = dirname(abs_path($0));
my $log_path = $daemon_path;
$log_path=~s/bin$//;
Dancer::Config::setting('appdir', $log_path);
Dancer::Config::load();
$log_path.='logs';

use constant DEBUG => 0;
use constant INFO => 1;
use constant ERROR => 2;

# Primary configuration
# Set options according to your needs

my $log_write_mode = 'a'; # set "s" for POSIX, "a" for non-POSIX OS
my $log_level = DEBUG;

# Do not edit below this line, if you're not sure what you're doing
# Configuration ends here

my $dbh;
my $log = Log::Trivial->new(log_file => $log_path.'/billing_cron.log');
$log->set_write_mode($log_write_mode);

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

$log->write("[DEBUG] Connecting to the database") if $log_level<=DEBUG;
&connect_db();

# Detele all disabled users that didn't activate for 3 days

$log->write("[INFO] Deleting new users not activated for 3 days") if $log_level<=INFO;
my $sth = $dbh->prepare("DELETE FROM `".config->{db_table_prefix}."_users` WHERE ".time."-regdate > 259200 AND verification != NULL");
if (!$sth->execute()) {
	$log->write("[ERROR] Error while delete non-active users") if $log_level<=ERROR;	
}
$sth->finish();

# Disconnect from DB
$log->write("[DEBUG] Disconnecting from the database") if $log_level<=DEBUG;
&disconnect_db();