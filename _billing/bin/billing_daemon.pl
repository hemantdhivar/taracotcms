#!/usr/bin/perl
# Taracot Billing daemon
# Can run in both daemon/one-run modes
# Check configuration variabled below

use strict;
use warnings;
use YAML::XS;
use Date::Format;
use DBI;
use Env;
use Log::Trivial;
use Fcntl qw(:flock);
use File::Basename;
use Cwd 'abs_path';
my $daemon_path = dirname(abs_path($0));
use constant DEBUG => 0;
use constant INFO => 1;
use constant ERROR => 2;

# Primary configuration
# Set options according to your needs

my $daemon_mode = 0; # uncomment the line below if daemon_mode=1
# use Daemon::Generic;
my $sleeptime = 2;
my $simulation_mode = 0;
my $log_write_mode = 'a'; # set "s" for POSIX, "a" for non-POSIX OS
my $log_level = INFO;
my $hosting_panel_plugin = $daemon_path.'/../lib/api/ispmanager.pl';
my $domain_panel_plugin = $daemon_path.'/../lib/api/regru.pl';

# Generic erorr messages
# You can edit these or add new languages

my $error_message = {
    en => {
        hostingregister => qq~Error while creating new user account~,
        hostingupdate => qq~Error while updating the hosting account~,
        domainregister => qq~Error while registering the domain~,
        domainupdate => qq~Error while updating the domain~
    },
    ru => {
        hostingregister => qq~Ошибка во время создания нового аккаунта~,
        hostingupdate => qq~Ошибка во время продления аккаунта~,
        domainregister => qq~Ошибка во время регистрации домена~,
        domainupdate => qq~Ошибка во время продления домена~
    }
};

# Do not edit below this line, if you're not sure what you're doing
# Configuration ends here

my $config;
my $dbh;
my $terminate = 0;
require $hosting_panel_plugin;
require $domain_panel_plugin;
my $log_path = $daemon_path;
$log_path=~s/bin$//;
$log_path.='logs';
my $log = Log::Trivial->new(log_file => $log_path.'/billing_daemon.log');
$log->set_write_mode($log_write_mode);

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
	$log->write("[DEBUG] Daemon is running gd_preconfig") if $log_level<=DEBUG;
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
		$log->write("[DEBUG] Checking queue action...") if $log_level<=DEBUG;
		# Register new hosting account
		if ($db_data->{action} && $db_data->{action} eq 'hostingregister') {
			$log->write("[DEBUG] Queue action: register new hosting account") if $log_level<=DEBUG;
			&register_hosting_account($db_data);
		}
		# Register new domain
		if ($db_data->{action} && $db_data->{action} eq 'domainregister') {
			$log->write("[DEBUG] Queue action: register new domain") if $log_level<=DEBUG;
			&register_domain($db_data);
		}
		# Update domain
		if ($db_data->{action} && $db_data->{action} eq 'domainupdate') {
			$log->write("[DEBUG] Queue action: update domain") if $log_level<=DEBUG;
			&update_domain($db_data);
		}
		# Update hosting account
		if ($db_data->{action} && $db_data->{action} eq 'hostingupdate') {
			$log->write("[DEBUG] Queue action: update hosting account") if $log_level<=DEBUG;
			&update_hosting_account($db_data);
		}
		# Delete event from queue
		if ($db_data->{id} && $db_data->{id} > 0) {
			$log->write("[DEBUG] Deleting event $db_data->{id} from queue") if $log_level<=DEBUG;
			$sth = $dbh->prepare("DELETE FROM `".$config->{db_table_prefix}."_billing_queue` WHERE id =".$db_data->{id});
			$sth->execute();
			$sth->finish();
		}
		&disconnect_db();
		$log->write("[DEBUG] End of checking queue action") if $log_level<=DEBUG;
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
	$log->write("[DEBUG] Register hosting account: $qhr->{object}") if $log_level<=DEBUG;
	my $hdb;
	my $sth = $dbh->prepare("SELECT id, user_id, host_plan_id, pwd FROM `".$config->{db_table_prefix}."_billing_hosting` WHERE host_acc=".$dbh->quote($qhr->{object}));
	if ($sth->execute()) {
		$hdb = $sth->fetchrow_hashref();
	}
	$sth->finish();	
	return 0 if !$hdb->{id};
	$log->write("[DEBUG] Hosting account ID: $hdb->{id}") if $log_level<=DEBUG;
	my $rr;
	if ($simulation_mode) {
		$rr = 1;
	} else {
		$rr = &APIUserRegister($qhr->{object}, $hdb->{pwd}, $hdb->{host_plan_id})
	}
	$log->write("[DEBUG] API function APIUserRegister return code: $rr") if $log_level<=DEBUG;
	if ($rr eq 1) { # success
		$sth = $dbh->prepare("UPDATE `".$config->{db_table_prefix}."_billing_hosting` SET in_queue=0, error_msg='' WHERE id=".$dbh->quote($hdb->{id}));
		my $res = $sth->execute();
		$sth->finish();
		$log->write("[INFO] Success: register hosting account ($qhr->{object}), database UPDATE = $res") if $log_level<=INFO;
	} else { # fail
		$log->write("[ERROR] Error while registering hosting account: $qhr->{object}, plan ID: $hdb->{host_plan_id}, amount: $qhr->{amount}, user ID: $qhr->{user_id}, timestamp: ".time2str('%c', $qhr->{tstamp})) if $log_level<=ERROR;
		$log->write("[INFO] API function APIUserRegister return code: $rr") if $log_level<=INFO;
		my $errmsg = $error_message->{$qhr->{lang}}->{hostingregister} || $error_message->{en}->{hostingregister};
		$sth = $dbh->prepare("INSERT INTO `".$config->{db_table_prefix}."_billing_funds_history`(user_id,trans_id,trans_objects,trans_amount,trans_date,lastchanged) VALUES (".$dbh->quote($hdb->{user_id}).",'refund',".$dbh->quote($errmsg.' - '.$qhr->{object}).",".$dbh->quote($qhr->{amount}).",".time.",".time.")");
		my $r1 = $sth->execute();
		$sth->finish();
		$log->write("[INFO] Logging error to ".$config->{db_table_prefix}."_billing_funds_history, INSERT = $r1") if $log_level<=INFO;
		$sth = $dbh->prepare("UPDATE `".$config->{db_table_prefix}."_billing_funds` SET amount=amount+".$qhr->{amount}." WHERE user_id=".$dbh->quote($hdb->{user_id}));
		my $r2 = $sth->execute();
		$sth->finish();		
		$log->write("[INFO] Money refund for user ID $hdb->{user_id}, amount = $qhr->{amount}, UPDATE = $r2") if $log_level<=INFO;
		$sth = $dbh->prepare("DELETE FROM `".$config->{db_table_prefix}."_billing_hosting` WHERE id=".$dbh->quote($hdb->{id}));
		my $r3 = $sth->execute();
		$sth->finish();
		$log->write("[INFO] Deleting user account ID $hdb->{id}, DELETE = $r3") if $log_level<=INFO;
	}	
}

# Domain register
# in: queue hash ref

sub register_domain {
	my $qhr = $_[0];
	$log->write("[DEBUG] Register domain: $qhr->{object}") if $log_level<=DEBUG;
	my $hdb;
	my $sth = $dbh->prepare("SELECT id, user_id, domain_name, exp_date, ns1, ns2, ns3, ns4, ns1_ip, ns2_ip, ns3_ip, ns4_ip, remote_ip FROM `".$config->{db_table_prefix}."_billing_domains` WHERE domain_name=".$dbh->quote($qhr->{object}));
	if ($sth->execute()) {
		$hdb = $sth->fetchrow_hashref();
	}
	$sth->finish();	
	return 0 if !$hdb->{id};
	$log->write("[DEBUG] Domain name ID: $hdb->{id}") if $log_level<=DEBUG;
    my $pdb;
	$sth = $dbh->prepare("SELECT id,n1r,n1e,n2r,n2e,n3r,n3e,email,phone,fax,country,city,state,addr,postcode,passport,birth_date,addr_ru,org,org_r,code,kpp,private FROM `".$config->{db_table_prefix}."_billing_profiles` WHERE user_id=".$dbh->quote($hdb->{user_id}));
	if ($sth->execute()) {
		$pdb = $sth->fetchrow_hashref();
	}
	$sth->finish();	
	if (!$pdb->{id}) {
		$log->write("[ERROR] Empty profile for user ID: $hdb->{user_id}") if $log_level<=ERROR;
	}
	my $rr;
	if ($simulation_mode) {
		$rr = 1;
	} else {
		$rr = &APIDomainRegister($qhr->{object}, $pdb, $hdb, $qhr);
	}
	$log->write("[DEBUG] API function APIDomainRegister return code: $rr") if $log_level<=DEBUG;
	if ($rr eq 1) { # success
		$sth = $dbh->prepare("UPDATE `".$config->{db_table_prefix}."_billing_domains` SET in_queue=0, error_msg='' WHERE id=".$dbh->quote($hdb->{id}));
		my $res = $sth->execute();
		$sth->finish();
		$log->write("[INFO] Success: register domain ($qhr->{object}), database UPDATE = $res") if $log_level<=INFO;
	} else { # fail
		$log->write("[ERROR] Error while registering domain: $qhr->{object}, amount: $qhr->{amount}, user ID: $qhr->{user_id}, timestamp: ".time2str('%c', $qhr->{tstamp})) if $log_level<=ERROR;
		$log->write("[INFO] API function APIDomainRegister return code: $rr") if $log_level<=INFO;
		my $errmsg;
		if (length($rr) > 2) {
			$errmsg = $rr;
		} else {
			$errmsg = $error_message->{$qhr->{lang}}->{domainregister} || $error_message->{en}->{domainregister}
		}
		$sth = $dbh->prepare("INSERT INTO `".$config->{db_table_prefix}."_billing_funds_history`(user_id,trans_id,trans_objects,trans_amount,trans_date,lastchanged) VALUES (".$dbh->quote($hdb->{user_id}).",'refund',".$dbh->quote($errmsg.' - '.$qhr->{object}).",".$dbh->quote($qhr->{amount}).",".time.",".time.")");
		my $r1 = $sth->execute();
		$sth->finish();
		$log->write("[INFO] Logging error to ".$config->{db_table_prefix}."_billing_funds_history, INSERT = $r1") if $log_level<=INFO;
		$sth = $dbh->prepare("UPDATE `".$config->{db_table_prefix}."_billing_funds` SET amount=amount+".$qhr->{amount}." WHERE user_id=".$dbh->quote($hdb->{user_id}));
		my $r2 = $sth->execute();
		$sth->finish();	
		$log->write("[INFO] Money refund for user ID $hdb->{user_id}, amount = $qhr->{amount}, UPDATE = $r2") if $log_level<=INFO;
		$sth = $dbh->prepare("DELETE FROM `".$config->{db_table_prefix}."_billing_domains` WHERE id=".$dbh->quote($hdb->{id}));
		my $r3 = $sth->execute();
		$sth->finish();
		$log->write("[INFO] Deleting domain ID $hdb->{id}, DELETE = $r3") if $log_level<=INFO;
	}	
}

# Domain update
# in: queue hash ref

sub update_domain {
	my $qhr = $_[0];
	$log->write("[DEBUG] Update domain: $qhr->{object}") if $log_level<=DEBUG;
	my $hdb;
	my $sth = $dbh->prepare("SELECT id, user_id, domain_name, exp_date, ns1, ns2, ns3, ns4, ns1_ip, ns2_ip, ns3_ip, ns4_ip, remote_ip FROM `".$config->{db_table_prefix}."_billing_domains` WHERE domain_name=".$dbh->quote($qhr->{object}));
	if ($sth->execute()) {
		$hdb = $sth->fetchrow_hashref();
	}
	$sth->finish();	
	return 0 if !$hdb->{id};
	$log->write("[DEBUG] Domain name ID: $hdb->{id}") if $log_level<=DEBUG;
	my $rr;
	if ($simulation_mode) {
		$rr = 1;
	} else {
		$rr = &APIDomainUpdate($qhr->{object}, $qhr->{lang});
	}
	$log->write("[DEBUG] API function APIDomainUpdate return code: $rr") if $log_level<=DEBUG;
	if ($rr eq 1) { # success
		$sth = $dbh->prepare("UPDATE `".$config->{db_table_prefix}."_billing_domains` SET in_queue=0, error_msg='' WHERE id=".$dbh->quote($hdb->{id}));
		my $res = $sth->execute();
		$sth->finish();
		$log->write("[INFO] Success: update domain ($qhr->{object}), database UPDATE = $res") if $log_level<=INFO;
	} else { # fail
		$log->write("[ERROR] Error while updating domain: $qhr->{object}, amount: $qhr->{amount}, user ID: $qhr->{user_id}, timestamp: ".time2str('%c', $qhr->{tstamp})) if $log_level<=ERROR;
		$log->write("[INFO] API function APIDomainUpdate return code: $rr") if $log_level<=INFO;
		my $errmsg;
		if (length($rr) > 2) {
			$errmsg = $rr;
		} else {
			$errmsg = $error_message->{$qhr->{lang}}->{domainregister} || $error_message->{en}->{domainregister}
		}
		$sth = $dbh->prepare("INSERT INTO `".$config->{db_table_prefix}."_billing_funds_history`(user_id,trans_id,trans_objects,trans_amount,trans_date,lastchanged) VALUES (".$dbh->quote($hdb->{user_id}).",'refund',".$dbh->quote($errmsg.' - '.$qhr->{object}).",".$dbh->quote($qhr->{amount}).",".time.",".time.")");
		my $r1 = $sth->execute();
		$sth->finish();
		$log->write("[INFO] Logging error to ".$config->{db_table_prefix}."_billing_funds_history, INSERT = $r1") if $log_level<=INFO;
		$sth = $dbh->prepare("UPDATE `".$config->{db_table_prefix}."_billing_funds` SET amount=amount+".$qhr->{amount}." WHERE user_id=".$dbh->quote($hdb->{user_id}));
		my $r2 = $sth->execute();
		$sth->finish();
		$log->write("[INFO] Money refund for user ID $hdb->{user_id}, amount = $qhr->{amount}, UPDATE = $r2") if $log_level<=INFO;
		$sth = $dbh->prepare("UPDATE `".$config->{db_table_prefix}."_billing_domains` SET exp_date = exp_date-31557600, error_msg=".$dbh->quote($errmsg).", in_queue=0 WHERE id=".$dbh->quote($hdb->{id}));
		my $r3 = $sth->execute();
		$sth->finish();
		$log->write("[INFO] Set exp_date=exp_date-1 year, error_msg='".$dbh->quote($errmsg)."' for domain $qhr->{object} (ID $hdb->{id}), UPDATE = $r3") if $log_level<=INFO;
	}	
}

# Hosting account update
# in: queue hash ref

sub update_hosting_account {
	my $qhr = $_[0];
	$log->write("[DEBUG] Update hosting account: $qhr->{object}") if $log_level<=DEBUG;
	my $hdb;
	my $sth = $dbh->prepare("SELECT id, user_id, host_plan_id, pwd FROM `".$config->{db_table_prefix}."_billing_hosting` WHERE host_acc=".$dbh->quote($qhr->{object}));
	if ($sth->execute()) {
		$hdb = $sth->fetchrow_hashref();
	}
	$sth->finish();	
	return 0 if !$hdb->{id};
	$log->write("[DEBUG] Hosting account ID: $hdb->{id}") if $log_level<=DEBUG;
	my $rr;
	if ($simulation_mode) {
		$rr = 1;
	} else {
		$rr = &APIUserTurnOn($qhr->{object}, $qhr->{lang});
	}
	$log->write("[DEBUG] API function APIUserTurnOn return code: $rr") if $log_level<=DEBUG;
	if ($rr eq 1) { # success
		$sth = $dbh->prepare("UPDATE `".$config->{db_table_prefix}."_billing_hosting` SET in_queue=0, error_msg='' WHERE id=".$dbh->quote($hdb->{id}));
		my $res = $sth->execute();
		$sth->finish();
		$log->write("[INFO] Success: update hosting account ($qhr->{object}), database UPDATE = $res") if $log_level<=INFO;
	} else { # fail
		$log->write("[ERROR] Error while updating hosting account: $qhr->{object}, plan ID: $hdb->{host_plan_id}, amount: $qhr->{amount}, user ID: $qhr->{user_id}, timestamp: ".time2str('%c', $qhr->{tstamp})) if $log_level<=ERROR;
		$log->write("[INFO] API function APIUserTurnOn return code: $rr") if $log_level<=INFO;
		my $errmsg;
		if (length($rr) > 2) {
			$errmsg = $rr;
		} else {
			$errmsg = $error_message->{$qhr->{lang}}->{hostingupdate} || $error_message->{en}->{hostingupdate}
		}
		$sth = $dbh->prepare("INSERT INTO `".$config->{db_table_prefix}."_billing_funds_history`(user_id,trans_id,trans_objects,trans_amount,trans_date,lastchanged) VALUES (".$dbh->quote($hdb->{user_id}).",'refund',".$dbh->quote($errmsg.' - '.$qhr->{object}).",".$dbh->quote($qhr->{amount}).",".time.",".time.")");
		my $r1 = $sth->execute();
		$sth->finish();
		$log->write("[INFO] Logging error to ".$config->{db_table_prefix}."_billing_funds_history, INSERT = $r1") if $log_level<=INFO;
		$sth = $dbh->prepare("UPDATE `".$config->{db_table_prefix}."_billing_funds` SET amount=amount+".$qhr->{amount}." WHERE user_id=".$dbh->quote($hdb->{user_id}));
		my $r2 = $sth->execute();
		$sth->finish();		
		$log->write("[INFO] Money refund for user ID $hdb->{user_id}, amount = $qhr->{amount}, UPDATE = $r2") if $log_level<=INFO;
		$sth = $dbh->prepare("UPDATE `".$config->{db_table_prefix}."_billing_hosting` SET host_days_remain = host_days_remain-host_days_last, host_days_last=0, error_msg=".$dbh->quote($errmsg).", in_queue=0 WHERE id=".$dbh->quote($hdb->{id}));
		my $r3 = $sth->execute();
		$sth->finish();
		$log->write("[INFO] Set host_days_remain=host_days_remain-host_days_last, error_msg='".$dbh->quote($errmsg)."' for hosting account $qhr->{object} (ID $hdb->{id}), UPDATE = $r3") if $log_level<=INFO;
	}	
}

# not a daemon mode - run just once

if (!$daemon_mode) {
	&gd_preconfig();
	&gd_run();
}
