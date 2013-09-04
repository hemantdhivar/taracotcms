#!/usr/bin/perl
use strict;
print "Taracot installation script\nModule installation\n\nNote: some CPAN modules do require C compiler (Example - debian: apt-get install build-essential)\nNote: Imager requires the following libs: libgif-dev libjpeg8-dev libtiff4-dev libpng12-dev libfreetype6-dev\n";
print "\nRun command to apt-get the required debian packages? [Y/n] ";
my $res =  <STDIN>;
chomp($res);
if (!$res) {
 print "Yes\n";
}
if ($res ne 'n') {
	system ('apt-get install build-essential libgif-dev libjpeg8-dev libtiff4-dev libpng12-dev libfreetype6-dev mysql-client mysql-server')
}
print "\nCheck (and install) missing CPAN modules? [Y/n] ";
$res =  <STDIN>;
chomp($res);
if (!$res) {
print "Yes\n";
}
if ($res ne 'n') {
my @required_modules = ('Dancer','Dancer::Plugin::Database','Dancer::Session::Storable','Time::Duration::Parse','YAML','YAML::XS','Module::Load','Digest::MD5','File::Slurp','JSON::XS','Text::Unidecode','Imager','Imager::File::GIF','Imager::File::JPEG','Imager::File::PNG','File::Basename','Dancer::Plugin::Email','Try::Tiny','Date::Format','Date::Parse','URI::Encode','Dancer::Logger::Log4perl','Log::Log4perl::Layout::PatternLayout','Lingua::Identify','URL::Encode','Tenjin',"Log::Log4perl::Appender::File");
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