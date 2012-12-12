$mrh_login = "xtremespb";
$mrh_pass1 = "";
$mrh_pass2 = "";
$inv_desc = "Re-hash.ru Services";
$shp_item = 2;
$in_curr = "WMR";

use Digest::MD5 qw(md5_hex);

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
  my %hash;
  $hash{name}='MrchLogin';
  $hash{value}=$mrh_login;
  push @fields, %hash;
  $hash{name}='OutSum';
  $hash{value}=$amount;
  push @fields, %hash;
  $hash{name}='InvId';
  $hash{value}=$trans_id;
  push @fields, %hash;
  $hash{name}='Desc';
  $hash{value}=$inv_desc;
  push @fields, %hash;
  $hash{name}='SignatureValue';
  $hash{value}=$crc;
  push @fields, %hash;
  $hash{name}='Shp_item';
  $hash{value}=$shp_item;
  push @fields, %hash;
  $hash{name}='IncCurrLabel';
  $hash{value}=$in_curr;
  push @fields, %hash;
  $response{fields}=\@fields;
  return \%response;
}

1;