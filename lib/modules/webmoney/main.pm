package modules::webmoney::main;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use Digest::MD5 qw(md5_hex); 

prefix '/payment/data'; 

get '/webmoney' => sub { 

  eval { require "api/webmoney.pl"; };
  if ($@) {   
   return "Error while loading plugin";
  }

  my $ps_data = &getPaymentSystemData();
  my $LMI_PAYEE_PURSE = $ps_data->{LMI_PAYEE_PURSE};
  my $LMI_PAYMENT_DESC = $ps_data->{LMI_PAYMENT_DESC};
  my $LMI_SECRET_KEY = $ps_data->{LMI_SECRET_KEY};
  my $LMI_PAYMENT_AMOUNT=param('LMI_PAYMENT_AMOUNT') || 0; 
  $LMI_PAYMENT_AMOUNT=sprintf("%01.2f", $LMI_PAYMENT_AMOUNT);

  # Pre-request

  if (param('LMI_PAYEE_PURSE') ne $LMI_PAYEE_PURSE) { return "Invalid LMI_PAYEE_PURSE";}
  my $LMI_PAYMENT_NO = param('LMI_PAYMENT_NO') || 0;
  $LMI_PAYMENT_NO = int($LMI_PAYMENT_NO);
  if (!param('LMI_PAYMENT_NO')) { return "Invalid LMI_PAYMENT_NO" }

  if (param('LMI_PREREQUEST') eq 1) {    
    my $amount;
    my $sth = database->prepare(
     'SELECT amount FROM '.config->{db_table_prefix}.'_billing_bills WHERE id='.database->quote($LMI_PAYMENT_NO)
    );
    if ($sth->execute()) {
     ($amount) = $sth->fetchrow_array;
    }
    $sth->finish();
    if ($amount) {
      $amount=sprintf("%01.2f", $amount);      
      if ($amount eq $LMI_PAYMENT_AMOUNT) {
          return "YES";
      } else {
          return "Invalid LMI_PAYMENT_AMOUNT";
      }
    } else {
        return "Invalid LMI_PAYMENT_AMOUNT";
    }  
  }

  # Request
  
  if (param('LMI_SECRET_KEY') ne $LMI_SECRET_KEY) { return "Invalid LMI_SECRET_KEY"; }

  my ($user_id, $amount);
  my $sth = database->prepare(
   'SELECT user_id, amount FROM '.config->{db_table_prefix}.'_billing_bills WHERE id='.database->quote($LMI_PAYMENT_NO)
  );
  if ($sth->execute()) {
    ($user_id, $amount) = $sth->fetchrow_array;
  }
  $sth->finish();

  if (!$user_id) { return "Invalid USER_ID"; }
  if ($amount) {
    $amount=sprintf("%01.2f", $amount);      
    if ($amount ne $LMI_PAYMENT_AMOUNT) {
      return "Invalid LMI_PAYMENT_AMOUNT";
    }
  } else {
    return "Invalid LMI_PAYMENT_AMOUNT";
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
   'DELETE FROM '.config->{db_table_prefix}.'_billing_bills WHERE id='.database->quote($LMI_PAYMENT_NO)
  );
  $sth->execute();
  $sth->finish();

  $sth = database->prepare(
   'INSERT INTO '.config->{db_table_prefix}.'_billing_funds_history(user_id,trans_id,trans_objects,trans_amount,trans_date,lastchanged) VALUES('.database->quote($user_id).','.database->quote('addfunds').','.database->quote('Webmoney').','.database->quote($amount).','.time.','.time.')'
  );
  $sth->execute();
  $sth->finish();

  return "YES";
 
};

# End

true;