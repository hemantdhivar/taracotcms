package modules::user::main;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use JSON::XS();
use Digest::MD5 qw(md5_hex);

# Configuration

my $defroute = '/user';

# Module core settings 

my $lang;
prefix $defroute;

sub _name() {
 &_load_lang();
  return $lang->{module_name};
}           
sub _defroute() {
  return $defroute;
}
sub _load_lang {
  my $lng = &taracot::_detect_lang() || config->{lang_default};
  my $lang_adm = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/user/lang/en.lng') || {};
  my $lang_adm_cnt={};
  if ($lng ne 'en') {
   $lang_adm_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/user/lang/'.$lng.'.lng') || {};
  } 
  my $lang_mod = YAML::XS::LoadFile(config->{root_dir}.'lib/taracot/lang/en.lng') || {};
  my $lang_mod_cnt={};
  if ($lng ne 'en') {
   $lang_mod_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/taracot/lang/'.$lng.'.lng') || {};
  }
  $lang = { %$lang_adm, %$lang_mod, %$lang_adm_cnt, %$lang_mod_cnt };
  return $lng;
}
# Routes

get '/register' => sub {
  if (&taracot::_auth()) { redirect '/' } 
  my $clang=_load_lang();
  $taracot::taracot_render_template = template 'user_register', { lang => $lang, agreement_url => config->{agreement}, site_title => $lang->{user_register}, authdata => $taracot::taracot_auth_data }, { layout => config->{layout}.'_'.$clang };
  pass();
};

any '/register/process' => sub {
  my $_current_lang=_load_lang();
  my %res;
  $res{status}=1; 
  my @errors;
  my @fields;
  my $json_xs = JSON::XS->new();
  if (&taracot::_auth()) { $res{status}=0; return $json_xs->encode(\%res); } 
  my $captcha=int(param('reg_captcha')) || 0;
  my $session_captcha=session('captcha');
  session captcha => rand; 
  if ($session_captcha ne $captcha) {    
    push @errors, $lang->{user_register_error_captcha};
    push @fields, 'captcha';
    $res{errors}=\@errors;
    $res{fields}=\@fields;
    $res{status}=0; 
    return $json_xs->encode(\%res); 
  }
  # first wave validations
  my $username=param('reg_username') || '';
  my $password=param('reg_password') || '';
  my $email=param('reg_email') || '';
  my $phone=param('reg_phone') || '';
  my $realname=param('reg_realname') || '';   
  if ($username !~ /^[A-Za-z0-9_\-]{1,100}$/) { 
    $res{status}=0; 
    push @errors, $lang->{user_register_error_username};
    push @fields, 'username';  
  }
  $username=lc($username);
  if ($password !~ /^[A-Za-z0-9_\-\$\!\@\#\%\^\&\[\]\{\}\*\+\=\.\,\'\"\|\<\>\?]{6,100}$/) { 
    $res{status}=0; 
    push @errors, $lang->{user_register_error_password};
    push @fields, 'password';  
  }
  if ($email !~ /^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/) { 
    $res{status}=0; 
    push @errors, $lang->{user_register_error_email};
    push @fields, 'email';  
  }
  $email=lc($email);
  $realname=~s/[\<\>\"\'\n\r\\\/]//gm; 
  if ($realname !~ /^.{0,80}$/) { 
    $res{status}=0; 
    push @errors, $lang->{user_register_error_realname};
    push @fields, 'realname';  
  }
  $phone=~s/[^0-9]//gm;
  if (length($phone) > 40) {
    $res{status}=0; 
    push @errors, $lang->{user_register_error_phone};
    push @fields, 'phone';
  }
  if ($res{status} eq 0) {
    $res{errors}=\@errors;
    $res{fields}=\@fields;
    return $json_xs->encode(\%res);
  }
  # second wave validations
  my $db_data_1  = database->quick_select(config->{db_table_prefix}.'_users', { username => $username });
  my $db_data_2  = database->quick_select(config->{db_table_prefix}.'_users', { email => $email });
  if ($db_data_1->{id}) { 
    $res{status}=0; 
    push @errors, $lang->{user_register_error_username_taken};
    push @fields, 'username';
  }
  if ($db_data_2->{id}) { 
    $res{status}=0; 
    push @errors, $lang->{user_register_error_email_taken};
    push @fields, 'email';
  }
  if ($res{status} eq 0) {
    $res{errors}=\@errors;
    $res{fields}=\@fields;
    return $json_xs->encode(\%res);
  }
  # perform the registration
  $password = md5_hex(config->{salt}.$password);
  database->quick_insert(config->{db_table_prefix}.'_users', { username => $username, password => $password, email => $email, phone => $phone, realname => $realname, status => 0, lastchanged => time }); 
  return $json_xs->encode(\%res);
};

get '/authorize' => sub {
  if (&taracot::_auth()) { redirect '/' } 
  my $clang=_load_lang();
  $taracot::taracot_render_template = template 'user_authorize', { lang => $lang, site_title => $lang->{user_authorize}, authdata => $taracot::taracot_auth_data }, { layout => config->{layout}.'_'.$clang };
  pass();
};

any '/authorize/process' => sub {
  my $_current_lang=_load_lang();
  my %res;
  $res{status}=1; 
  my @errors;
  my @fields;
  my $json_xs = JSON::XS->new();
  if (&taracot::_auth()) { $res{status}=0; return $json_xs->encode(\%res); } 
  # first wave validations
  my $login=param('auth_login') || '';
  my $password=param('auth_password') || '';
  my $username='';
  my $email='';
  $login=lc($login);
  if ($login =~ m/\@/) {
    if ($login !~ /^([a-z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-z0-9\-]+\.)+))([a-z]{2,4}|[0-9]{1,3})(\]?)$/) { 
      $res{status}=0; 
      push @errors, $lang->{user_register_error_email};
      push @fields, 'login';  
    } else {
      $email=$login;
    }
  } else {
    if ($login !~ /^[a-z0-9_\-]{1,100}$/) { 
      $res{status}=0; 
      push @errors, $lang->{user_register_error_username};
      push @fields, 'login';  
    } else {
      $username=$login;  
    }
  }  
  if ($password !~ /^[A-Za-z0-9_\-\$\!\@\#\%\^\&\[\]\{\}\*\+\=\.\,\'\"\|\<\>\?]{1,100}$/) { 
    $res{status}=0; 
    push @errors, $lang->{user_register_error_password_single};
    push @fields, 'password';  
  }
  if ($res{status} eq 0) {
    $res{errors}=\@errors;
    $res{fields}=\@fields;
    return $json_xs->encode(\%res);
  }
  # second wave validations
  my $db_data;
  $password = md5_hex(config->{salt}.$password);
  if ($username) {
    $db_data  = database->quick_select(config->{db_table_prefix}.'_users', { username => $username, password => $password });
  }
  if ($email) {
    $db_data  = database->quick_select(config->{db_table_prefix}.'_users', { email => $email, password => $password });
  }
  if (!$db_data->{id}) {
    $res{status}=0; 
    push @errors, $lang->{user_auth_invalid}; 
    push @fields, 'login';
    push @fields, 'password';
    $res{errors}=\@errors;
    $res{fields}=\@fields;
    return $json_xs->encode(\%res);
  }
  session user => $db_data->{id}; 
  return $json_xs->encode(\%res);
};

# End

true;