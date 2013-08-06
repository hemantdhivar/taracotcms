package modules::robokassa::main;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use Digest::MD5 qw(md5_hex); 

prefix '/payment/data'; 

get '/robokassa' => sub { 

  eval { require "api/robokassa.pl"; };
  if ($@) {   
   return "Error while loading plugin";
  }

  my $ps_data = &getPaymentSystemData();
  my $mrh_login = $ps_data->{mrh_login};
  my $inv_desc = $ps_data->{inv_desc};
  my $shp_item = $ps_data->{shp_item};
  my $in_curr = $ps_data->{in_curr}; 
  my $mrh_pass1 = $ps_data->{mrh_pass1};
  my $mrh_pass2 = $ps_data->{mrh_pass2};

  my $nOutSum=param('OutSum');
  if (!$nOutSum) {
    return "Invalid nOutSum";
  }
  my $nInvId=param('InvId') || 0;
  $nInvId = int($nInvId);
  if (!$nInvId) {
    return "Invalid nInvId";
  }  
  my $sSignatureValue=param('SignatureValue');
  if (!$sSignatureValue) {
    return "Invalid sSignatureValue";
  }
  
  my $crc = md5_hex("$nOutSum:$nInvId:$mrh_pass2:Shp_item=".param('Shp_item')); 
  $crc =~ s/([a-z])/uc "$1"/eg; # force uppercase
  if ($crc ne $sSignatureValue) { 
    return "Invalid signature CRC";
  }

  my ($user_id, $amount);
  my $sth = database->prepare(
   'SELECT user_id, amount FROM '.config->{db_table_prefix}.'_billing_bills WHERE id='.database->quote($nInvId)
  );
  if ($sth->execute()) {
    ($user_id, $amount) = $sth->fetchrow_array;
  }
  $sth->finish(); 

  if (!$user_id) {
    return "Invalid USER_ID";
  }
  
  $amount=sprintf("%01.2f", $amount); 
  $nOutSum=sprintf("%01.2f", $nOutSum); 
  if ($amount ne $nOutSum) {
    return "Invalid amount";
  }

  my $res=0;
  $sth = database->prepare(
   'INSERT INTO '.config->{db_table_prefix}.'_billing_funds (user_id,amount,lastchanged) VALUES ('.database->quote($user_id).','.database->quote($amount).','.time.') ON DUPLICATE KEY UPDATE amount=amount+'.database->quote($amount).',lastchanged='.time
  );
  if ($sth->execute()) {
    $res=1;
  }
  $sth->finish();  

  if (!$res) {
    return "Database error";
  }

  $sth = database->prepare(
   'DELETE FROM '.config->{db_table_prefix}.'_billing_bills WHERE id='.database->quote($nInvId)
  );
  $sth->execute();
  $sth->finish();

  $sth = database->prepare(
   'INSERT INTO '.config->{db_table_prefix}.'_billing_funds_history(user_id,trans_id,trans_objects,trans_amount,trans_date,lastchanged) VALUES('.database->quote($user_id).','.database->quote('addfunds').','.database->quote('Robokassa').','.database->quote($amount).','.time.','.time.')'
  );
  $sth->execute();
  $sth->finish();

  return "OK$nInvId";
 
};

# End

true;