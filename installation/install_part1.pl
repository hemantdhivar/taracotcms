
 #!/usr/bin/perl
use strict;
use Path::Class qw(file);
print "Taracot installation script\nSystem configuration\n\n";
my $root = file($0)->absolute->dir;
$root =~s/\\/\//gm;
$root =~s/\/installation$//;
print "\nDetected root directory: $root\n";
print "If correct, press Enter, otherwise type the path (no trailing slash): ";
my $root_user = <STDIN>;
chomp ($root_user);
if ($root_user) { 
 $root = $root_user;
}
print "\nUsing root directory: $root\n";
open(DATA, './config.yml.dist');
my $config_dist = join('', <DATA>);
close(DATA);
print "Processing configuration file...\n\n";
$config_dist =~s/\[root\]/$root\//gm;
$config_dist =~s/\[files\]/$root\/public\/files\//gm;
$config_dist =~s/\[sessions\]/$root\/tmp\/sessions\//gm;
my @chars = ("A".."Z", "a".."z", 0..9);
my $salt;
$salt .= $chars[rand @chars] for 1..64;
$config_dist =~s/\[salt\]/$salt/gm;

print "Dancer port [5000]: ";
my $dport = <STDIN>;
chomp($dport);
if (!$dport) { $dport = '5000'; print "Using 5000 as Dancer server port\n"; }
$config_dist =~s/\[port\]/$dport/gm;

print "\nMySQL host [localhost]: ";
my $host = <STDIN>;
chomp($host);
if (!$host) { $host = 'localhost'; print "Using localhost as MySQL host\n"; }
$config_dist =~s/\[host\]/$host/gm;
print "MySQL port [3306]: ";
my $port = <STDIN>;
chomp($port);
if (!$port) { $port = '3306'; print "Using 3306 as MySQL port\n"; }
$config_dist =~s/\[sqlport\]/$port/gm;
print "MySQL database [taracot]: ";
my $database = <STDIN>;
chomp($database);
if (!$database) { $database = 'taracot'; print "Using taracot as MySQL database\n"; }
$config_dist =~s/\[database\]/$database/gm;
print "MySQL username [taracot]: ";
my $username = <STDIN>;
chomp($username);
if (!$username) { $username = 'taracot'; print "Using taracot as MySQL username\n"; }
$config_dist =~s/\[username\]/$username/gm;
print "MySQL password (Enter to leave blank and set later): ";
my $password = <STDIN>;
chomp($password);
if (!$password) { $password = ''; print "Using empty MySQL password\n"; }
$config_dist =~s/\[password\]/$password/gm;
print "\nMailout address [Taracot CMS <noreply\@taracot.org>]: ";
my $mailfrom = <STDIN>;
chomp($mailfrom);
if (!$mailfrom) { $mailfrom = 'Taracot CMS <noreply@taracot.org>'; print "Using: Taracot CMS <noreply\@taracot.org>\n"; }
$config_dist =~s/\[mailfrom\]/$mailfrom/gm;
print "Sendmail [/usr/sbin/sendmail]: ";
my $sendmail = <STDIN>;
chomp($sendmail);
if (!$sendmail) { $sendmail = '/usr/sbin/sendmail'; print "Using /usr/sbin/sendmail\n"; }
$config_dist =~s/\[sendmail\]/$sendmail/gm;
print "\nSession domain [.taracot.org]: ";
my $sd = <STDIN>;
chomp($sd);
if (!$sd) { $sd = '.taracot.org'; print "Using .taracot.org\n"; }
$config_dist =~s/\[sessiondomain\]/$sd/gm;
print "\nWriting new configuration file: config.yml...\n";
open(DATA, ">../config.yml");
binmode(DATA);
print DATA $config_dist;
close(DATA);
print "Writing new configuration file: production.yml...\n";
open(DATA, './production.yml.dist');
my $production_dist = join('', <DATA>);
close(DATA);
$production_dist =~s/\[root\]/$root\//gm;
open(DATA, ">../environments/production.yml");
binmode(DATA);
print DATA $production_dist;
close(DATA);
print "Writing new configuration file: log4perl.conf...\n";
open(DATA, './log4perl.conf.dist');
my $log4perl = join('', <DATA>);
close(DATA);
$log4perl =~s/\[root\]/$root\//gm;
open(DATA, ">../environments/log4perl.conf");
binmode(DATA);
print DATA $log4perl;
close(DATA);
if (!$password) {
	print "\nWarning: MySQL password is not set. Please set it manually (config.yml)\n"
}
print "\nConfiguration is complete. If any error messages are displayed, you may need to re-run this script.\n";