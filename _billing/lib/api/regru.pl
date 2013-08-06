use strict;
use JSON::XS("decode_json");
use utf8;
use URL::Encode qw(url_encode);
use Net::Whois::Parser;

my $username='test';
my $password='test';
my $folder_name='re-hash.ru';
my $api_create='https://api.reg.ru/api/regru2/domain/create';
my $api_renew='https://api.reg.ru/api/regru2/service/renew';

# Debug
#$ENV{HTTPS_PROXY} = 'http://10.233.104.141:3128';

use LWP::UserAgent;
my $agent=LWP::UserAgent->new;
$agent->timeout(5);
$agent->env_proxy;

sub APIDomainRegister {
	my $domain_name=$_[0];
	my $pdb=$_[1];
	my $hdb=$_[2];
	my $qhr=$_[3];
	my $zone=$domain_name;
    $zone=~s/^[^\.]*\.//;
    my %input_data;
    my %contacts;
    if ($zone eq 'ru' || $zone eq 'su') {
    	$contacts{p_addr} = $pdb->{addr_ru};
    	$contacts{phone} = $pdb->{phone};
    	$contacts{fax} = $pdb->{fax} if $pdb->{fax};
    	$contacts{e_mail} = $pdb->{email};
    	if ($pdb->{org}) {
    		$contacts{org} = $pdb->{org};
    		$contacts{org_r} = $pdb->{org_r};
    		$contacts{code} = $pdb->{code};
    		$contacts{kpp} = $pdb->{kpp};    
    		$contacts{address_r} = $pdb->{addr_ru};
    		$contacts{country} = $pdb->{country};
    	} else {
	    	$contacts{country} = $pdb->{country};
	    	$contacts{person} = $pdb->{n2e}.' '.$pdb->{n3e}.' '.$pdb->{n1e};
	    	$contacts{person_r} = $pdb->{n1r}.' '.$pdb->{n2r}.' '.$pdb->{n3r};
	    	$contacts{private_person_flag} = 1 if $pdb->{private};
	    	$contacts{passport} = $pdb->{passport};
	    	$contacts{birth_date} = $pdb->{birth_date};
	    	$contacts{country} = $pdb->{country};
	    	$contacts{code} = $pdb->{code};
    	}
    } else {
    	my $phone = $pdb->{phone};
    	$phone =~ s/ /\./;
    	$phone =~ s/ //gm;
    	my $fax = $pdb->{fax};
    	$fax =~ s/ /\./;
    	$fax =~ s/ //gm;
    	$contacts{o_company} = $pdb->{org} || "Private person";
    	$contacts{o_first_name} = $pdb->{n2e};
    	$contacts{o_last_name} = $pdb->{n1e};
    	$contacts{o_email} = $pdb->{email};
    	$contacts{o_phone} = $phone;
    	$contacts{o_fax} = $fax if $pdb->{fax};
    	$contacts{o_addr} = $pdb->{addr};
    	$contacts{o_city} = $pdb->{city};
    	$contacts{o_state} = $pdb->{state};
    	$contacts{o_postcode} = $pdb->{postcode};
    	$contacts{o_country_code} = $pdb->{country};
    	$contacts{a_company} = $pdb->{org} || "Private person";
    	$contacts{a_first_name} = $pdb->{n2e};
    	$contacts{a_last_name} = $pdb->{n1e};
    	$contacts{a_email} = $pdb->{email};
    	$contacts{a_phone} = $phone;
    	$contacts{a_fax} = $fax || '';
    	$contacts{a_addr} = $pdb->{addr};
    	$contacts{a_city} = $pdb->{city};
    	$contacts{a_state} = $pdb->{state};
    	$contacts{a_postcode} = $pdb->{postcode};
    	$contacts{a_country_code} = $pdb->{country};
    	$contacts{t_company} = $pdb->{org} || "Private person";
    	$contacts{t_first_name} = $pdb->{n2e};
    	$contacts{t_last_name} = $pdb->{n1e};
    	$contacts{t_email} = $pdb->{email};
    	$contacts{t_phone} = $phone;
    	$contacts{t_fax} = $fax || '';
    	$contacts{t_addr} = $pdb->{addr};
    	$contacts{t_city} = $pdb->{city};
    	$contacts{t_state} = $pdb->{state};
    	$contacts{t_postcode} = $pdb->{postcode};
    	$contacts{t_country_code} = $pdb->{country};
    	$contacts{b_company} = $pdb->{org} || "Private person";
    	$contacts{b_first_name} = $pdb->{n2e};
    	$contacts{b_last_name} = $pdb->{n1e};
    	$contacts{b_email} = $pdb->{email};
    	$contacts{b_phone} = $phone;
    	$contacts{b_fax} = $fax || '';
    	$contacts{b_addr} = $pdb->{addr};
    	$contacts{b_city} = $pdb->{city};
    	$contacts{b_state} = $pdb->{state};
    	$contacts{b_postcode} = $pdb->{postcode};
    	$contacts{b_country_code} = $pdb->{country};
    	if ($zone eq "com" || $zone eq "net" || $zone eq "org" || $zone eq "biz" || $zone eq "name" || $zone eq "info" || $zone eq "mobi" || $zone eq "uk" || $zone eq "cc" || $zone eq "tv" || $zone eq "ws" || $zone eq "bz" || $zone eq "me") {
    		$contacts{private_person_flag} = 1 if $pdb->{private};	
    	}
    	if ($zone eq "us") {
    		if ($pdb->{org}) {
    			$contacts{RselnexusAppPurpose} = 'P1';
    		} else {
    			$contacts{RselnexusAppPurpose} = 'P3';
    		}
    		$contacts{RselnexusCategory} = 'C31';
    	}
    }
    $input_data{contacts} = \%contacts;
    my %ns_hash;
    $ns_hash{ns0} = $hdb->{ns1};
    $ns_hash{ns1} = $hdb->{ns2};
    $ns_hash{ns2} = $hdb->{ns3} if $hdb->{ns3};
    $ns_hash{ns3} = $hdb->{ns4} if $hdb->{ns4};
    $ns_hash{ns0ip} = $hdb->{ns1_ip} if $hdb->{ns1_ip};
    $ns_hash{ns1ip} = $hdb->{ns2_ip} if $hdb->{ns2_ip};
    $ns_hash{ns2ip} = $hdb->{ns3_ip} if $hdb->{ns3_ip};
    $ns_hash{ns3ip} = $hdb->{ns4_ip} if $hdb->{ns4_ip};
    $input_data{nss} = \%ns_hash;
    $input_data{domain_name} = $domain_name;
    $input_data{enduser_ip} = $hdb->{remote_ip};
    $input_data{period} = 1;
    my $json_xs = JSON::XS->new();  
  	my $json = $json_xs->encode(\%input_data);
  	my $response = $agent->post($api_create, 
  								Content => 'username='.$username.'&password='.$password.'&lang='.$qhr->{lang}.'&input_format=json&output_format=json&input_data='.url_encode($json)	  					
							);  	
 	if (!$response->is_success) {
 		return 0;
 	}
 	my $data;
 	eval { $data = decode_json $response->content; }; return 0 if $@;
 	if ($data->{result} ne "success" && !$data->{answer}->{pay_notes}) {
 		if ($data->{error_text}) {
 			return $data->{error_text}
 		} else {
 			return -1;
 		}
 	} else {
 		return 1;
 	}
	return 1;
}

sub APIDomainUpdate {
	my $domain_name=$_[0];
	my $lang=$_[1];
  	my $response = $agent->post($api_renew, 
  								Content => 'username='.$username.'&password='.$password.'&lang='.$lang.'&output_format=json&servtype=domain&domain_name='.$domain_name.'&period=1'
							);  	
 	if (!$response->is_success) {
 		return 0;
 	}
 	my $data;
 	eval { $data = decode_json $response->content; }; return 0 if $@;
 	if ($data->{result} ne "success" && !$data->{answer}->{pay_notes}) {
 		if ($data->{error_text}) {
 			return $data->{error_text}
 		} else {
 			return -1;
 		}
 	} else {
 		return 1;
 	}
	return 1;
}

sub APICheckDomainAvailability {
    my $domain = $_[0];
    return 0 if !$domain;
    my $info = parse_whois( domain => $domain );
    if (!$info) {
        return 1;
    } else {
        return 0;
    }

}

1;