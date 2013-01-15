#!/usr/bin/perl
# Taracot crontab script
# Check configuration variabled below

use strict;
use warnings;
use DBI;
use Dancer ':script';
use Dancer::Plugin::Email;
use YAML::XS;
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
my $hosting_panel_plugin = $daemon_path.'/../lib/api/ispmanager.pl';
my $lang = 'en';
my $site_url = 'http://127.0.0.1:2999';

# Generic erorr messages
# You can edit these or add new languages

my $lang_data = {
    en => {
        useroff => qq~Error while switching off user account~,
        mail_subj => "Notification from website",
        hosting => "Hosting accounts",
        domains => "Domains",
        services => "Services"
    },
    ru => {
        useroff => qq~Ошибка во время отключения пользовательского аккаунта~,
        mail_subj => "Сообщение с сайта",
        hosting => "Хостинговые аккаунты",
        domains => "Домены",
        services => "Сервисы"
    }
};

# Do not edit below this line, if you're not sure what you're doing
# Configuration ends here

my $dbh;
require $hosting_panel_plugin;
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
# Decrease hosting days
$log->write("[INFO] Decreasing days: ".config->{db_table_prefix}."_billing_hosting") if $log_level<=INFO;
my $sth = $dbh->prepare("UPDATE `".config->{db_table_prefix}."_billing_hosting` SET host_days_remain=host_days_remain-1 WHERE host_days_remain>0");
my $r1 = $sth->execute();
$sth->finish();
if (!$r1) {
	$log->write("[ERROR] Error while decreasing days on ".config->{db_table_prefix}."_billing_hosting") if $log_level<=ERROR;
}
# Decrease service days
$log->write("[INFO] Decreasing days: ".config->{db_table_prefix}."_billing_services") if $log_level<=INFO;
$sth = $dbh->prepare("UPDATE `".config->{db_table_prefix}."_billing_services` SET service_days_remaining=service_days_remaining-1 WHERE service_days_remaining>0");
my $r2 = $sth->execute();
$sth->finish();
if (!$r2) {
	$log->write("[ERROR] Error while decreasing days on ".config->{db_table_prefix}."_billing_services") if $log_level<=ERROR;
}
# Get outdated hosting accounts list
my @outdated_hosting_accounts;
$sth = $dbh->prepare("SELECT user_id, host_acc FROM `".config->{db_table_prefix}."_billing_hosting` WHERE host_days_remain<8");
if ($sth->execute()) {
	while (my $od = $sth->fetchrow_hashref()) {
		push @outdated_hosting_accounts, $od;
	}
} else {
	$log->write("[ERROR] Error while getting outdated hosting accounts from ".config->{db_table_prefix}."_billing_hosting") if $log_level<=ERROR;	
}
$sth->finish();
# Get outdated services list
my @outdated_services;
$sth = $dbh->prepare("SELECT user_id, service_id FROM `".config->{db_table_prefix}."_billing_services` WHERE service_days_remaining<8");
if ($sth->execute()) {
	while (my $od = $sth->fetchrow_hashref()) {
		push @outdated_services, $od;
	}
} else {
	$log->write("[ERROR] Error while getting outdated services from ".config->{db_table_prefix}."_billing_services") if $log_level<=ERROR;	
}
$sth->finish();
# Get outdated domains list
my @outdated_domains;
my $exp=604800;
$sth = $dbh->prepare("SELECT user_id, domain_name FROM `".config->{db_table_prefix}."_billing_domains` WHERE exp_date-".time."<".$exp." AND exp_date>".time);
if ($sth->execute()) {
	while (my $od = $sth->fetchrow_hashref()) {
		push @outdated_domains, $od;
	}
} else {
	$log->write("[ERROR] Error while getting outdated domains from ".config->{db_table_prefix}."_billing_services") if $log_level<=ERROR;	
}
$sth->finish();
# Order accounts/domains/services by user
my $user_data = {};
foreach my $item(@outdated_hosting_accounts) {
	if (!$user_data->{$item->{user_id}}->{hosting}) {
		$user_data->{$item->{user_id}}->{hosting} = [];
	}
	push @{$user_data->{$item->{user_id}}->{hosting}}, $item->{host_acc};
}
foreach my $item(@outdated_domains) {
	if (!$user_data->{$item->{user_id}}->{domains}) {
		$user_data->{$item->{user_id}}->{domains} = [];
	}
	push @{$user_data->{$item->{user_id}}->{domains}}, $item->{domain_name};
}
foreach my $item(@outdated_services) {
	if (!$user_data->{$item->{user_id}}->{services}) {
		$user_data->{$item->{user_id}->{services}} = [];
	}
	push @{$user_data->{$item->{user_id}}->{services}}, $item->{service_id};
}
# Get user data for each user ID
my $users = {};
while(my ($key) = each %$user_data) {
	$sth = $dbh->prepare("SELECT username, realname, email, last_lang FROM `".config->{db_table_prefix}."_users` WHERE id=".$key);
	if ($sth->execute()) {
		my $ud = $sth->fetchrow_hashref();
		$users->{$key}->{username} = $ud->{username};
		$users->{$key}->{realname} = $ud->{realname};
		$users->{$key}->{email} = $ud->{email};
		$users->{$key}->{lang} = $ud->{last_lang};
	}
	$sth->finish();
};

my $site_title = '';
$sth = $dbh->prepare("SELECT s_value FROM `".config->{db_table_prefix}."_settings` WHERE s_name='site_title'");
if ($sth->execute()) {
	($site_title) = $sth->fetchrow_array()
}
$sth->finish();
$log->write("[DEBUG] Site title: ".$site_title) if $log_level<=DEBUG;

# Send mails to each users
while(my ($key) = each %$user_data) {	
	my $items = '';
	my @items_log;
	my $lang = $users->{$key}->{lang} || $lang;
	if ($user_data->{$key}->{hosting}) {
		my $ref = $user_data->{$key}->{hosting};
		my $hacc = join(', ', @$ref);
		push @items_log, "hosting accounts: $hacc";
		$items = '<b>'.$lang_data->{$lang}->{hosting}.'</b>: '.$hacc;
	}
	if ($user_data->{$key}->{domains}) {
		my $ref = $user_data->{$key}->{domains};
		my $dacc = join(', ', @$ref);
		push @items_log, "domains: $dacc";
		if ($items) {
			$items .= '<br />'
		}
		$items .= '<b>'.$lang_data->{$lang}->{domains}.'</b>: '.$dacc;
	}
	if ($user_data->{$key}->{services}) {
		my $ref = $user_data->{$key}->{services};
		my $sacc = join(', ', @$ref);
		push @items_log, "services: $sacc";
		if ($items) {
			$items .= '<br />'
		}
		$items .= '<b>'.$lang_data->{$lang}->{services}.'</b>: '.$sacc;
	}
	my $ilog = join('; ', @items_log);
	$log->write("[INFO] Sending mail to: ".$users->{$key}->{email}." ($ilog)") if $log_level<=INFO;
	my $body = template 'billing_mail_notify_'.$lang, { site_title => encode_entities_numeric($site_title), site_logo_url => $site_url.config->{site_logo_url}, items => $items }, { layout => undef };
	email {
	    to      => $users->{$key}->{email},
	    subject => $lang_data->{$lang}->{mail_subj}.': '.$site_title,
	    body    => $body,
	    type    => 'html',
	    headers => { "X-Accept-Language" => $lang }
	};
}

# Disable outdated hosting accounts

my @zero_days;

$log->write("[INFO] Disabling accounts with host_days_remain = 0") if $log_level<=INFO;
$sth = $dbh->prepare("SELECT host_acc FROM `".config->{db_table_prefix}."_billing_hosting` WHERE host_days_remain=0");
if ($sth->execute()) {
	while (my ($acc) = $sth->fetchrow_array()) {
		push @zero_days, $acc;
	}
} else {
	$log->write("[ERROR] Error while getting accounts with host_days_remain = 0 from ".config->{db_table_prefix}."_billing_hosting") if $log_level<=ERROR;	
}
$sth->finish();

# Disconnect from DB
$log->write("[DEBUG] Disconnecting from the database") if $log_level<=DEBUG;
&disconnect_db();