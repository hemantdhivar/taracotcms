#!/usr/bin/perl
use strict;
print "Taracot installation script\nModule installation\n\nNote: some CPAN modules do require C compiler (Example - debian: apt-get install build-essential)\n\n";
print "Check (and install) missing CPAN modules? [y/n] ";
my $res =  <STDIN>;
chomp($res);
if (!$res) {
print "Yes\n";
}
if ($res ne 'n') {
my @required_modules = ('Dancer','Dancer::Plugin::Database','Dancer::Session::Storable','Time::Duration::Parse','YAML','YAML::XS','Module::Load','Digest::MD5','File::Slurp','JSON::XS','Text::Unidecode','Imager','File::Basename','Dancer::Plugin::Email','Try::Tiny','Date::Format','Date::Parse','URI::Encode','Dancer::Logger::Log4perl','Log::Log4perl::Layout::PatternLayout');
foreach my $rm (@required_modules) {
print "Checking $rm...\n";
if ($rm eq 'Log::Log4perl::Layout::PatternLayout') {
eval("use Dancer::Logger::Log4perl; use $rm;");
} else {
eval("use $rm");
}
if ($@) {
print "Module $rm is possible missing, trying to install\n";
system('cpan '.$rm);
}
}
print "\n";
}
print "\nModule installation part is complete. If any error messages are displayed, you may need to re-run this script.\n";