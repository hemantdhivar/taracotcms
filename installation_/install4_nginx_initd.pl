#!/usr/bin/perl
use strict;
use Cwd qw(abs_path);
use File::Basename qw(dirname);
my $root = dirname(abs_path($0));
$root =~s/\\/\//gm;
$root =~s/\/installation$//;
print "Taracot installation script\nModule installation and configuration, NGINX and init.d script\n\nNote: some CPAN modules do require C compiler (Example - debian: apt-get install build-essential)\n\n";
print "Check (and install) missing CPAN modules? [y/n] ";
my $res =  <STDIN>;
chomp($res);
if (!$res) {
print "Yes\n";
}
if ($res ne 'n') {
my @required_modules = ('Plack','Starman','Task::Plack');
foreach my $rm (@required_modules) {
print "Checking $rm...\n";
eval("use $rm");
if ($@) {
print "Module $rm is possible missing, trying to install\n";
system('cpan '.$rm);
}
}
print "\n";
}
print "\nModule installation part is complete. If any error messages are displayed, you may need to re-run this script.\n\n";
print "To generate NGINX configuration files you need to answer some questions.\n\n";
print "IP address NGINX should listen to []: ";
my $listen_ip =  <STDIN>;
chomp($listen_ip);
print "Port NGINX should listen to [80]: ";
my $listen_port =  <STDIN>;
chomp($listen_port);
if (!$listen_port) { $listen_port = '80'; print "- Using 80 as NGINX listening port\n"; }
print "Server name []: ";
my $server_name =  <STDIN>;
chomp($server_name);
print "Server aliases separated with space (if any) []: ";
my $server_alias =  <STDIN>;
chomp($server_alias);
if ($server_alias) { $server_alias = " ".$server_alias; }
print "Taracot/Dancer project root folder [$root]: ";
my $root_user = <STDIN>;
chomp($root_user);
if ($root_user) {
	$root = $root_user;
} else {
	print " - Using $root as Taracot/Dancer project root folder\n"
}
print "IP which Taracot/Dancer should listen to [127.0.0.1]: ";
my $dancer_ip =  <STDIN>;
chomp($dancer_ip);
if (!$dancer_ip) { $dancer_ip = '127.0.0.1'; print "- Using 127.0.0.1 as Taracot/Dancer listening IP\n"; }
print "Port which Taracot/Dancer should listen to [5000]: ";
my $dancer_port =  <STDIN>;
chomp($dancer_port);
if (!$dancer_port) { $dancer_port = '5000'; print "- Using 5000 as Taracot/Dancer listening port\n"; }
print "Writing configuration file...\n";
open(DATA, "nginx.config.dist");
binmode(DATA);
my $nginx = join('', <DATA>);
close(DATA);
$nginx=~s/\[listen_ip\]/$listen_ip/igm;
$nginx=~s/\[listen_port\]/$listen_port/igm;
$nginx=~s/\[server_name\]/$server_name/igm;
$nginx=~s/\[server_alias\]/$server_alias/igm;
my $public_folder_url = $root.'/public';
$nginx=~s/\[public_folder_url\]/$public_folder_url/igm;
$nginx=~s/\[dancer_ip\]/$dancer_ip/igm;
$nginx=~s/\[dancer_port\]/$dancer_port/igm;
open(DATA, ">./nginx/$server_name.conf");
binmode(DATA);
print DATA $nginx;
close(DATA);
print "\nTo generate init.d script files you need to answer some more questions.\n\n";
print "Number of workers [10]: ";
my $workers =  <STDIN>;
chomp($workers);
if (!$workers) { $workers = '10'; print "- Using 10 workers\n"; }
print "System user [taracot]: ";
my $user =  <STDIN>;
chomp($user);
if (!$user) { $user = 'taracot'; print "- Setting user: taracot\n"; }
print "System group [taracot]: ";
my $group =  <STDIN>;
chomp($group);
if (!$group) { $group = 'taracot'; print "- Setting group: taracot\n"; }
print "Writing script...\n";
open(DATA, "init.d.dist");
binmode(DATA);
my $initd = join('', <DATA>);
close(DATA);
$initd=~s/\[server_name\]/$server_name/igm;
$initd=~s/\[root\]/$root/igm;
$initd=~s/\[dancer_ip\]/$dancer_ip/igm;
$initd=~s/\[dancer_port\]/$dancer_port/igm;
$initd=~s/\[workers\]/$workers/igm;
$initd=~s/\[user\]/$user/igm;
$initd=~s/\[group\]/$group/igm;
$server_name=~s/\./\-/gm;
open(DATA, ">./init.d/taracot-$server_name");
binmode(DATA);
print DATA $initd;
close(DATA);
system("cd .. && chown $user:$user -R ./*");
print "\nConfiguration is now complete. Take a look at ./init.d and ./nginx folders.\n";