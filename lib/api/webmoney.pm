$LMI_PAYEE_PURSE='R704413344646';
$LMI_PAYMENT_DESC='Re-hash.ru Services';

sub getFieldsAPI {
  my $amount=$_[0];
  my $trans_id=$_[1];
  my %response;
  $response{url} = 'https://merchant.webmoney.ru/lmi/payment.asp';
  $response{method} = 'POST';
  my @fields;
  my %hash;
  $hash{name}='LMI_PAYMENT_AMOUNT';
  $hash{value}=$amount;
  push @fields, \%hash;
  $hash{name}='LMI_PAYMENT_DESC';
  $hash{value}=$LMI_PAYMENT_DESC;
  push @fields, %hash;
  $hash{name}='LMI_PAYMENT_NO';
  $hash{value}=$trans_id;
  push @fields, %hash;
  $hash{name}='LMI_PAYEE_PURSE';
  $hash{value}=$LMI_PAYEE_PURSE;
  push @fields, %hash;
  $hash{name}='LMI_SIM_MODE';
  $hash{value}=0;
  push @fields, %hash;
  $response{fields}=\@fields;
  return \%response;
}

1;