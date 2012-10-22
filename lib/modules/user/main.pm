package modules::user::main;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use Dancer::Plugin::Email;
use HTML::Entities qw(encode_entities_numeric);
use Try::Tiny;
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
  my $_current_lang=_load_lang();
  my $page_data= &taracot::_load_settings('site_title,keywords,description', $_current_lang);  
  $taracot::taracot_render_template = template 'user_register', { lang => $lang, agreement_url => config->{agreement}, page_data => $page_data, pagetitle => $lang->{user_register}, authdata => $taracot::taracot_auth_data }, { layout => config->{layout}.'_'.$_current_lang };
  pass();
};

post '/register/process' => sub {
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
  if ($email !~ /^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/ || length($email) >80) { 
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
  my $verification=md5_hex(config->{salt}.$password.time.rand);
  database->quick_insert(config->{db_table_prefix}.'_users', { username => $username, password => $password, email => $email, phone => $phone, realname => $realname, status => 0, verification => 'act_'.$verification, lastchanged => time });
  my $db_data= &taracot::_load_settings('site_title', $_current_lang);  
  my $activation_url = request->uri_base().'/user/activate/'.$username.'/'.$verification;
  my $body = template 'user_mail_register_'.$_current_lang, { site_title => encode_entities_numeric($db_data->{site_title}), activation_url => $activation_url, site_logo_url => config->{site_logo_url} }, { layout => undef };
  try {
    email {
      to      => $email,
      subject => $lang->{user_register_email_subj}.' '.$db_data->{site_title},
      body    => $body,
      type    => 'html',
      headers => { "X-Accept-Language" => $_current_lang }
    };
  } catch {
    #$_;
  };
  return $json_xs->encode(\%res);
};

get '/authorize' => sub {
  if (&taracot::_auth()) { redirect '/' } 
  my $_current_lang=_load_lang();
  my %db_data;
  my $page_data= &taracot::_load_settings('site_title,keywords,description', $_current_lang);
  $taracot::taracot_render_template = template 'user_authorize', { lang => $lang, page_data => $page_data, pagetitle => $lang->{user_authorize}, authdata => $taracot::taracot_auth_data }, { layout => config->{layout}.'_'.$_current_lang };
  pass();
};

post '/authorize/process' => sub {
  my $_current_lang=_load_lang();
  my %res;
  $res{status}=1; 
  my @errors;
  my @fields;
  my $json_xs = JSON::XS->new();
  if (&taracot::_auth()) {
    $res{status}=0; 
    push @errors, $lang->{user_auth_already_logged_in}; 
    push @fields, 'login';
    push @fields, 'password';
    $res{errors}=\@errors;
    $res{fields}=\@fields;
    return $json_xs->encode(\%res);
  }
  # first wave validations
  my $login=param('auth_login') || '';
  my $password=param('auth_password') || '';
  my $username='';
  my $email='';
  $login=lc($login);
  if ($login =~ m/\@/) {
    if ($login !~ /^([a-z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-z0-9\-]+\.)+))([a-z]{2,4}|[0-9]{1,3})(\]?)$/ || length($login) > 80) { 
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
  if ($db_data->{status} eq 0) {
    $res{status}=0; 
    push @errors, $lang->{user_auth_user_disabled}; 
    push @fields, 'login';
    $res{errors}=\@errors;
    $res{fields}=\@fields;
    return $json_xs->encode(\%res);
  }
  session user => $db_data->{id}; 
  return $json_xs->encode(\%res);
};

get '/activate/:username/:verification' => sub {
  if (&taracot::_auth()) { redirect '/' } 
  my $msg='';
  my $_current_lang=_load_lang();
  my $username = params->{username};
  my $verification = params->{verification};
  my $page_data= &taracot::_load_settings('site_title,keywords,description', $_current_lang);
  if ($username !~ /^[a-z0-9_\-]{1,100}$/ || $verification !~ /^[a-f0-9]{32}$/) { 
    $msg = $lang->{user_activate_error_url};
    $taracot::taracot_render_template = template 'user_activate', { lang => $lang, page_data => $page_data, pagetitle => $lang->{user_activate}, msg => $msg }, { layout => config->{layout}.'_'.$_current_lang };
    pass();
    return;
  }  
  my $db_data = database->quick_select(config->{db_table_prefix}.'_users', { username => $username, verification => 'act_'.$verification, status => 0 });
  if (!$db_data->{id}) {
    $msg = $lang->{user_activate_error_wrong_code};
    $taracot::taracot_render_template = template 'user_activate', { lang => $lang, page_data => $page_data, pagetitle => $lang->{user_activate}, msg => $msg }, { layout => config->{layout}.'_'.$_current_lang };
    pass();
    return;
  }
  database->quick_update(config->{db_table_prefix}.'_users', { username => $username }, { verification => '', status => 1, lastchanged => time }); 
  $msg = $lang->{user_activate_success};
  $taracot::taracot_render_template = template 'user_activate', { lang => $lang, page_data => $page_data, pagetitle => $lang->{user_activate}, msg => $msg }, { layout => config->{layout}.'_'.$_current_lang };
  pass();
};

get '/password' => sub {
  if (&taracot::_auth()) { redirect '/' } 
  my $_current_lang=_load_lang();
  my %db_data;
  my $page_data= &taracot::_load_settings('site_title,keywords,description', $_current_lang);
  $taracot::taracot_render_template = template 'user_password', { lang => $lang, page_data => $page_data, pagetitle => $lang->{user_password} }, { layout => config->{layout}.'_'.$_current_lang };
  pass();
};

post '/password/process' => sub {
  my $_current_lang=_load_lang();
  my %res;
  $res{status}=1; 
  my @errors;
  my @fields;
  my $json_xs = JSON::XS->new();
  if (&taracot::_auth()) {
    $res{status}=0; 
    push @errors, $lang->{user_auth_already_logged_in}; 
    push @fields, 'login';
    push @fields, 'password';
    $res{errors}=\@errors;
    $res{fields}=\@fields;
    return $json_xs->encode(\%res);
  }
  my $captcha=int(param('pwd_captcha')) || 0;
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
  my $username=lc param('pwd_username') || '';
  my $email=lc param('pwd_email') || '';
  if ($username !~ /^[A-Za-z0-9_\-]{1,100}$/) { 
    $res{status}=0; 
    push @errors, $lang->{user_register_error_username};
    push @fields, 'username';  
  }
  if ($email !~ /^([a-z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-z0-9\-]+\.)+))([a-z]{2,4}|[0-9]{1,3})(\]?)$/ || length($email) > 80) { 
    $res{status}=0; 
    push @errors, $lang->{user_register_error_email};
    push @fields, 'login';  
  }
  if ($res{status} eq 0) {
    $res{errors}=\@errors;
    $res{fields}=\@fields;
    return $json_xs->encode(\%res);
  }
  # second wave validations
  my $db_data;
  $db_data = database->quick_select(config->{db_table_prefix}.'_users', { username => $username, email => $email, status => 1 });
  if (!$db_data->{id}) {
    $res{status}=0; 
    push @errors, $lang->{user_register_error_user_not_exists}; 
    push @fields, 'username';
    push @fields, 'email';
    $res{errors}=\@errors;
    $res{fields}=\@fields;
    return $json_xs->encode(\%res);
  }
  my $verification=md5_hex(config->{salt}.time.rand);
  database->quick_update(config->{db_table_prefix}.'_users', { username => $username }, { verification => 'pwd_'.$verification, lastchanged => time });
  $db_data= &taracot::_load_settings('site_title', $_current_lang);  
  my $activation_url = request->uri_base().'/user/password/reset/'.$username.'/'.$verification;
  my $body = template 'user_mail_password_'.$_current_lang, { site_title => encode_entities_numeric($db_data->{site_title}), activation_url => $activation_url, site_logo_url => config->{site_logo_url} }, { layout => undef };
  try {
    email {
      to      => $email,
      subject => $lang->{user_register_email_subj}.' '.$db_data->{site_title},
      body    => $body,
      type    => 'html',
      headers => { "X-Accept-Language" => $_current_lang }
    };
  } catch {
    #$_;
  };
  return $json_xs->encode(\%res);
};

get '/password/reset/:username/:verification' => sub {
  if (&taracot::_auth()) { redirect '/' } 
  my $_current_lang=_load_lang();
  my $username = params->{username};
  my $verification = params->{verification};
  my $page_data= &taracot::_load_settings('site_title,keywords,description', $_current_lang);
  if ($username !~ /^[a-z0-9_\-]{1,100}$/ || $verification !~ /^[a-f0-9]{32}$/) { 
    $taracot::taracot_render_template = template 'user_password_reset', { lang => $lang, page_data => $page_data, pagetitle => $lang->{user_password_reset} }, { layout => config->{layout}.'_'.$_current_lang };
    pass();
    return;
  }  
  my $db_data = database->quick_select(config->{db_table_prefix}.'_users', { username => $username, verification => 'pwd_'.$verification, status => 1 });
  if (!$db_data->{id}) {
    $taracot::taracot_render_template = template 'user_password_reset', { lang => $lang, page_data => $page_data, pagetitle => $lang->{user_password_reset} }, { layout => config->{layout}.'_'.$_current_lang };
    pass();
    return;
  }
  $taracot::taracot_render_template = template 'user_password_reset', { lang => $lang, page_data => $page_data, pagetitle => $lang->{user_password_reset}, username => $username, verification => $verification }, { layout => config->{layout}.'_'.$_current_lang };
  pass();
};

post '/password/reset/process' => sub {
  my $_current_lang=_load_lang();
  my %res;
  $res{status}=1; 
  my @errors;
  my @fields;
  my $json_xs = JSON::XS->new();
  if (&taracot::_auth()) {
    $res{status}=0; 
    push @errors, $lang->{user_auth_already_logged_in}; 
    $res{errors}=\@errors;
    return $json_xs->encode(\%res);
  }
  # first wave validations
  my $username=param('pwd_username') || '';
  my $password=param('pwd_password') || '';
  my $verification=param('verification') || '';
  if ($password !~ /^[A-Za-z0-9_\-\$\!\@\#\%\^\&\[\]\{\}\*\+\=\.\,\'\"\|\<\>\?]{6,100}$/) { 
    $res{status}=0; 
    push @errors, $lang->{user_register_error_password};
    push @fields, 'password';  
  }
  if ($verification !~ /^[a-f0-9]{32}$/ || $username !~ /^[A-Za-z0-9_\-]{1,100}$/) {
    $res{status}=0; 
    push @errors, $lang->{user_password_reset_inavlid_data};
  }
  if ($res{status} eq 0) {
    $res{errors}=\@errors;
    $res{fields}=\@fields;
    return $json_xs->encode(\%res);
  }
  # second wave validations
  my $db_data;
  $db_data = database->quick_select(config->{db_table_prefix}.'_users', { username => $username, verification => 'pwd_'.$verification, status => 1 });
  if (!$db_data->{id}) {
    $res{status}=0; 
    push @errors, $lang->{user_password_reset_fail}; 
    $res{errors}=\@errors;
    return $json_xs->encode(\%res);
  }
  $password = md5_hex(config->{salt}.$password);
  database->quick_update(config->{db_table_prefix}.'_users', { username => $username }, { verification => '', password => $password, lastchanged => time }); 
  return $json_xs->encode(\%res);
};

# End

true;