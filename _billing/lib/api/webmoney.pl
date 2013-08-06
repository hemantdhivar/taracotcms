use strict;

my $LMI_PAYEE_PURSE='R704413344646';
my $LMI_PAYMENT_DESC='Re-hash.ru Services';
my $LMI_SECRET_KEY='SECRET_KEY';

sub getPaymentSystemData {
  my %response;
  $response{'LMI_PAYEE_PURSE'} = $LMI_PAYEE_PURSE;
  $response{'LMI_PAYMENT_DESC'} = $LMI_PAYMENT_DESC;
  $response{'LMI_SECRET_KEY'} = $LMI_SECRET_KEY;
  return \%response;
}

sub getFieldsAPI {
  my $amount=$_[0];
  my $trans_id=$_[1];
  my %response;
  $response{url} = 'https://merchant.webmoney.ru/lmi/payment.asp';
  $response{method} = 'POST';
  my @fields;
  my %lpa;  
  $lpa{name}='LMI_PAYMENT_AMOUNT';
  $lpa{value}=$amount;
  push @fields, \%lpa;
  my %lpd;
  $lpd{name}='LMI_PAYMENT_DESC';
  $lpd{value}=$LMI_PAYMENT_DESC;
  push @fields, \%lpd;
  my %lpn;
  $lpn{name}='LMI_PAYMENT_NO';
  $lpn{value}=$trans_id;
  push @fields, \%lpn;
  my %lpp;
  $lpp{name}='LMI_PAYEE_PURSE';
  $lpp{value}=$LMI_PAYEE_PURSE;
  push @fields, \%lpp;
  my %lsm;
  $lsm{name}='LMI_SIM_MODE';
  $lsm{value}=0;
  push @fields, \%lsm;
  $response{fields}=\@fields;
  return \%response;
}

1;