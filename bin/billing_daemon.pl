#!/usr/bin/perl

my $daemon_mode = 0;
my $sleeptime = 2;

my %error_message;
my %local_en;

$local_en{hostingregister}=qq~Error while creating new user account~;
$local_en{hostingupdate}=qq~Error while updating the hosting account~;
$local_en{domainregister}=qq~Error while registering the domain~;
$local_en{domainupdate}=qq~Error while updating the domain~;

$error_message{en} = \%local_en;

if ($daemon_mode) {
	require Daemon::Generic;
}
use strict;
use warnings;
use YAML::XS;
use File::Basename;
use Cwd 'abs_path';
use DBI;

my $daemon_path = dirname(abs_path($0));
my $config;
my $dbh;
my $terminate = 0;

my $hosting_panel_plugin = $daemon_path.'/../lib/api/ispmanager.pl';
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

if ($daemon_mode){
	newdaemon (
		progname => 'billing_daemon',
		pidfile	 => $daemon_path.'/billing_daemon.pid'
	);
}

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
		my $sth = $dbh->prepare("SELECT id, user_id, action, object, tstamp, amount, lang FROM `".$config->{db_table_prefix}."_billing_queue` WHERE 1 ORDER BY tstamp ASC LIMIT 1");
		if ($sth->execute()) {
			$db_data = $sth->fetchrow_hashref();
		}
		$sth->finish();
		my $res;
		# Register new hosting account
		if ($db_data->{action} && $db_data->{action} eq 'hostingregister') {
			$res = &register_hosting_account($db_data);
		}
		# Delete event from queue
		if ($db_data->{id}) {
			$sth = $dbh->prepare("DELETE FROM `".$config->{db_table_prefix}."_billing_queue` WHERE id =".$db_data->{id});
			$sth->execute();
			$sth->finish();
		}
		&disconnect_db();
		exit if $terminate;
		exit if !$daemon_mode;
	}
}

sub gd_quit_event {
	$terminate = 1;
}

# Hosting account register
# in: queue hash ref

sub register_hosting_account {
	my $qhr = $_[0];
	print "Hosting account register: $qhr->{object}\n";
	my $hdb;
	my $sth = $dbh->prepare("SELECT id, user_id, host_plan_id, pwd FROM `".$config->{db_table_prefix}."_billing_hosting` WHERE host_acc=".$dbh->quote($qhr->{object}));
	if ($sth->execute()) {
		$hdb = $sth->fetchrow_hashref();
	}
	$sth->finish();	
	return 0 if !$hdb->{id};
	print "Hosting account ID: $hdb->{id}\n";
	my $rr = &APIUserRegister($qhr->{object}, $hdb->{pwd}, $hdb->{host_plan_id});
	print "APIUserRegister return code: $rr\n";
	if ($rr eq 1) { # success
		$sth = $dbh->prepare("UPDATE `".$config->{db_table_prefix}."_billing_hosting` SET in_queue=0 WHERE id=".$dbh->quote($hdb->{id}));
		$sth->execute();
		$sth->finish();
	} else { # fail
		my $errmsg = $error_message{$qhr->{lang}}->{hostingregister} || $error_message{en}->{hostingregister};
		$sth = $dbh->prepare("INSERT INTO `".$config->{db_table_prefix}."_billing_funds_history`(user_id,trans_id,trans_objects,trans_amount,trans_date,lastchanged) VALUES (".$dbh->quote($hdb->{user_id}).",'fundsrefund',".$dbh->quote($errmsg.' - '.$qhr->{object}).",".$dbh->quote($qhr->{amount}).",".time.",".time.")");
		$sth->execute();
		$sth->finish();
		$sth = $dbh->prepare("UPDATE `".$config->{db_table_prefix}."_billing_funds` SET amount=amount+".$dbh->quote($qhr->{amount})." WHERE id=".$dbh->quote($hdb->{user_id}));
		$sth->execute();
		$sth->finish();		
		#$sth = $dbh->prepare("UPDATE `".$config->{db_table_prefix}."_billing_hosting` SET error_msg=".$dbh->quote($errmsg)." WHERE id=".$dbh->quote($hdb->{id}));
		#$sth->execute();
		#$sth->finish();
		$sth = $dbh->prepare("DELETE FROM `".$config->{db_table_prefix}."_billing_hosting` WHERE id=".$dbh->quote($hdb->{id}));
		$sth->execute();
		$sth->finish();
	}
}

# not a daemon mode - run just once

if (!$daemon_mode) {
	&gd_preconfig();
	&gd_run();
}
