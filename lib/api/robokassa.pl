use strict;

my $mrh_login = "xtremespb";
my $mrh_pass1 = "";
my $mrh_pass2 = "";
my $inv_desc = "Re-hash.ru Services";
my $shp_item = 2;
my $in_curr = "WMR";

use Digest::MD5 qw(md5_hex);

sub getPaymentSystemData {  
  my %response;
  $response{'mrh_login'} = $mrh_login;
  $response{'inv_desc'} = $inv_desc;
  $response{'shp_item'} = $shp_item;
  $response{'in_curr'} = $in_curr;
  $response{'mrh_pass1'} = $mrh_pass1;
  $response{'mrh_pass2'} = $mrh_pass2;
  return \%response;
}

sub getFieldsAPI {
  my $amount=$_[0];
  my $trans_id=$_[1];
  my $salt=Digest::MD5->new;
  my $hash = $salt->add(time().$$*rand);
  my $rnd=$hash->hexdigest; 
  my $crc = md5_hex("$mrh_login:$amount:$trans_id:$mrh_pass1:Shp_item=$shp_item");
  my %response;
  $response{url} = 'http://merchant.roboxchange.com/Index.aspx';
  $response{method} = 'POST';
  my @fields;
  my %mrchlgn;
  $mrchlgn{name}='MrchLogin';
  $mrchlgn{value}=$mrh_login;
  push @fields, \%mrchlgn;
  my %otsm;
  $otsm{name}='OutSum';
  $otsm{value}=$amount;  
  push @fields, \%otsm;
  my %invid;
  $invid{name}='InvId';
  $invid{value}=$trans_id;
  push @fields, \%invid;
  my %dsc;
  $dsc{name}='Desc';
  $dsc{value}=$inv_desc;
  push @fields, \%dsc;
  my %svl;
  $svl{name}='SignatureValue';
  $svl{value}=$crc;
  push @fields, \%svl;
  my %shpitm;
  $shpitm{name}='Shp_item';
  $shpitm{value}=$shp_item;
  push @fields, \%shpitm;
  my %icl;
  $icl{name}='IncCurrLabel';
  $icl{value}=$in_curr;
  push @fields, \%icl;
  $response{fields}=\@fields;
  return \%response;
}

1;