#!/usr/bin/perl
use Daemon::Generic;
use strict;
use warnings;
use YAML::XS;
use File::Basename;
use Cwd 'abs_path';
use DBI;

my $sleeptime = 2;
my $daemon_path = dirname(abs_path($0));
my $config;
my $dbh;
my $terminate = 0;
my $hosting_panel_plugin = $daemon_path.'../lib/api/ispmanager.pl';

require $hosting_panel_plugin;

sub connect_db {
	my $DSN = 'DBI:mysql:'.$config->{plugins}->{Database}->{database}.':'.$config->{plugins}->{Database}->{host};
	$dbh = DBI->connect($DSN, $config->{plugins}->{Database}->{username}, $config->{plugins}->{Database}->{password});
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

newdaemon (
	progname        => 'billing_daemon',
	pidfile         => $daemon_path.'/billing_daemon.pid'
);

sub gd_preconfig {
	print "Preconfig...\n";
	$config = YAML::XS::LoadFile($daemon_path.'/../config.yml');
}

sub gd_run {
	while(1) {
                sleep($sleeptime);
		exit if $terminate;
		&connect_db();
		my $db_data = undef;
		my $sth = $dbh->prepare("SELECT id, user_id, action, object, pwd, tstamp, amount FROM `".$config->{db_table_prefix}."_billing_queue` WHERE 1 ORDER BY tstamp ASC LIMIT 1");
	        if ($sth->execute()) {
			$db_data = $sth->fetchrow_hashref();
		}
        	$sth->finish();
		# Register new hosting account
		if ($db_data->{action} && $db_data->{action} eq 'hostingregister') {
			print "Hosting account register: $db_data->{object}\n";
			
		}
		# Delete event from queue
		if ($db_data->{id}) {
			$sth = $dbh->prepare("DELETE FROM `".$config->{db_table_prefix}."_billing_queue` WHERE id =".$db_data->{id});
			$sth->execute();
			$sth->finish();
		}
		&disconnect_db();
		exit if $terminate;
        }
}

sub gd_quit_event {
	$terminate = 1;
}
