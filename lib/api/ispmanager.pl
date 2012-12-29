use strict;
use JSON::XS("decode_json");

my $CPANEL="https://re-hash.ru/manager/";
my $AUTHDATA="taracot_api:12345678";
my $OWNER="rehash_customers";
# Debug
$ENV{HTTPS_PROXY} = 'http://10.233.104.141:3128';

use LWP::UserAgent;
my $agent=LWP::UserAgent->new;
$agent->timeout(10);
$agent->env_proxy;

sub APICheckLogin {
 my $login=$_[0];
 my $response = $agent->get("$CPANEL?authinfo=$AUTHDATA&out=json&func=user.edit&elid=$login");
 if (!$response->is_success) {
 	return 0;
 }
 my $data;
 eval { $data = decode_json $response->content; }; return -1 if $@;
 if ($data->{error}->{code}) {
 	return -1;
 } else {
 	return 1;
 }
}

sub APIUserRegister {
 my $login=$_[0];
 my $password=$_[1];
 my $preset=$_[2];
 my $response = $agent->get("$CPANEL?authinfo=$AUTHDATA&out=json&func=user.edit&sok=1&name=$login&passwd=$password&owner=$OWNER&preset=$preset");
 if (!$response->is_success) {
 	return 0;
 }
 my $data;
 eval { $data = decode_json $response->content; }; return -1 if $@;
 if ($data->{error}->{code}) {
 	return -1;
 } else {
 	return 1;
 }
}

1;