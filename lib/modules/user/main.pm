package modules::user::main;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use Dancer::Plugin::Email;
use Time::HiRes qw ( time );
use HTML::Entities qw(encode_entities_numeric);
use JSON::XS();
use Digest::MD5 qw(md5_hex);
use Date::Format;
use taracot::fs;
use Encode; 

# Configuration

my $defroute = '/user';
my @columns = ('id','ptitle','plang', 'pdate','pstate');

# Module core settings 

my $lang;
prefix $defroute;
my $detect_lang;

sub _name() {
 &_load_lang();
  return $lang->{module_name};
}           
sub _defroute() {
  return $defroute;
}
sub _load_lang {
  $detect_lang = &taracot::_detect_lang();
  my $lng = $detect_lang->{lng} || config->{lang_default};
  my $lang_adm = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/user/lang/en.lng') || {};
  my $lang_adm_cnt={};
  if ($lng ne 'en') {
   $lang_adm_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/user/lang/'.$lng.'.lng') || {};
  } 
  my $lang_auth = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/auth/lang/en.lng') || {};
  my $lang_auth_cnt={};
  if ($lng ne 'en') {
   $lang_auth_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/auth/lang/'.$lng.'.lng') || {};
  } 
  my $lang_mod = YAML::XS::LoadFile(config->{root_dir}.'lib/taracot/lang/en.lng') || {};
  my $lang_mod_cnt={};
  if ($lng ne 'en') {
   $lang_mod_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/taracot/lang/'.$lng.'.lng') || {};
  }
  $lang = { %$lang_adm, %$lang_mod, %$lang_auth, %$lang_adm_cnt, %$lang_mod_cnt, %$lang_auth_cnt };
  return $lng;
}
# Routes

get '/register' => sub {
  my $auth_data = &taracot::_auth();
  if ($auth_data) { return redirect '/user/account' } 
  my $_current_lang=_load_lang();
  my $page_data= &taracot::_load_settings('site_title,keywords,description', $_current_lang);  
  my $render_template = &taracot::_process_template( template ('user_register', { detect_lang => $detect_lang, config => config, head_html => '<link href="'.config->{modules_css_url}.'user.css" rel="stylesheet" />', lang => $lang, agreement_url => config->{agreement}, page_data => $page_data, pagetitle => $lang->{user_register}, authdata => $auth_data }, { layout => config->{layout}.'_'.$_current_lang }), $auth_data );
  if ($render_template) {
    return $render_template;
  }
  pass();
};

post '/register/process' => sub {
  content_type 'application/json';
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
  my $sex=param('reg_sex') || 0;
  if ($sex) {
   $sex = 1;
  }
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
  #$realname=~s/[\<\>\"\'\n\r\\\/]//gm; 
  if ($realname !~ /^(([\wА-Яа-я])+([\wА-Яа-я\-\']{0,1})([\wА-Яа-я])\s([\wА-Яа-я])+([\wА-Яа-я\-\']{0,1})([\wА-Яа-я])+){0,80}$/) { 
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
  my $verification = md5_hex(config->{salt}.$password.time.rand);
  database->quick_insert(config->{db_table_prefix}.'_users', { username => $username, password => $password, email => $email, phone => $phone, realname => $realname, sex => $sex, status => 0, verification => 'act_'.$verification, regdate => time, lastchanged => time });
  my $db_data= &taracot::_load_settings('site_title', $_current_lang);  
  my $activation_url = request->uri_base().'/user/activate/user/'.$username.'/'.$verification;
  if (config->{https_connection}) {
    $activation_url =~ s/^http:/https:/i;
  }
  my $body = template 'user_mail_register_'.$_current_lang, { site_title => encode_entities_numeric($db_data->{site_title}), activation_url => $activation_url, site_logo_url => request->uri_base().config->{site_logo_url} }, { layout => undef };
  email {
      to      => $email,
      subject => $lang->{user_register_email_subj}.': '.$db_data->{site_title},
      body    => $body,
      type    => 'html',
      headers => { "X-Accept-Language" => $_current_lang }
  };  
  return $json_xs->encode(\%res);
};

post '/register/finish' => sub {
  content_type 'application/json';
  my $_current_lang=_load_lang();
  my %res; 
  $res{status}=1; 
  my @errors;
  my @fields;
  my $json_xs = JSON::XS->new();
  my $auth = &taracot::_auth();
  if (!$auth || !$auth->{username_unset}) {
    $res{status}=0;
    push @errors, $lang->{authdlg_error_auth};
    push @fields, 'username';
    $res{errors}=\@errors;
    $res{fields}=\@fields;
    return $json_xs->encode(\%res);
  }
  my $username=param('auth_username') || '';
  if ($username !~ /^[A-Za-z0-9_\-]{3,100}$/) { 
    $res{status}=0; 
    push @errors, $lang->{authdlg_invalid_username};
    push @fields, 'username';  
    $res{errors}=\@errors;
    $res{fields}=\@fields;
    return $json_xs->encode(\%res);
  }  
  $username=lc($username);
  my $sex = param('sex') || 0;
  if ($sex) {
    $sex = 1;
  }
  my $db_data=database->quick_select(config->{db_table_prefix}.'_users', { username => $username });
  if ($db_data->{id} && $db_data->{username} ne $auth->{username}) {
    $res{status}=0; 
    push @errors, $lang->{authdlg_duplicate_username};
    push @fields, 'username';  
    $res{errors}=\@errors;
    $res{fields}=\@fields;
    return $json_xs->encode(\%res);
  }
  database->quick_update(config->{db_table_prefix}.'_users', { id => $auth->{id} }, { username => $username, sex => $sex, username_unset => 0, lastchanged => time });  
  my $res_data = database->quick_select(config->{db_table_prefix}.'_users', { id => $auth->{id} });
  if ($username ne $res_data->{username}) {
    $res{status}=0; 
    push @errors, $lang->{authdlg_error_save};
    $res{errors}=\@errors;
    $res{fields}=\@fields;
  }
  return $json_xs->encode(\%res);
};

# post '/register/finish/default' => sub {
#   content_type 'application/json';
#   my $_current_lang=_load_lang();
#   my %res; 
#   $res{status}=1; 
#   my @errors;
#   my @fields;
#   my $json_xs = JSON::XS->new();
#   my $auth = &taracot::_auth();
#   if (!$auth || !$auth->{username_unset}) {
#     $res{status}=0;
#     push @errors, $lang->{authdlg_error_auth};
#     push @fields, 'username';
#     $res{errors}=\@errors;
#     $res{fields}=\@fields;
#     return $json_xs->encode(\%res);
#   }  
#   database->quick_update(config->{db_table_prefix}.'_users', { id => $auth->{id} }, { username_unset => 0, lastchanged => time });  
#   return $json_xs->encode(\%res);
# };

get '/authorize' => sub {
  my $auth_data = &taracot::_auth();
  if ($auth_data) { return redirect '/user/account'; return; } 
  my $_current_lang=_load_lang();
  my $comeback = param('comeback') || '';
  if ($comeback) {
    $comeback =~ s/\"/&quot;/gm;
    $comeback =~ s/\</&lt;/gm;
    $comeback =~ s/\>/&gt;/gm;
  }
  if ($comeback eq '/user/logout') {
    $comeback = '/';
  }
  if (length($comeback) > 512) {
    redirect '/user/authorize'; 
    return;  
  }
  session auth_uri_base => request->uri_base();
  session auth_comeback => $comeback;
  my %db_data;
  my $page_data= &taracot::_load_settings('site_title,keywords,description', $_current_lang);
  my $render_template = &taracot::_process_template( template ('user_authorize', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'user.css" rel="stylesheet" />', lang => $lang, current_lang => $_current_lang, page_data => $page_data, pagetitle => $lang->{user_authorize}, authdata => $auth_data, comeback => $comeback, config => config }, { layout => config->{layout}.'_'.$_current_lang }), $auth_data );
  if ($render_template) {
    return $render_template;
  }
  pass();
};

post '/authorize/process' => sub {
  content_type 'application/json';
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
    if ($login !~ /^[a-z0-9_\-\.]{1,100}$/) { 
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
  my $captcha=int(param('auth_captcha')) || 0;
  my $session_captcha=session('captcha');
  session captcha => rand; 
  my $ec;
  if ($username) {
    $ec = database->quick_select(config->{db_table_prefix}.'_users', { username => $username });
  } else {
    $ec = database->quick_select(config->{db_table_prefix}.'_users', { email => $email });
  }
  if ($ec->{captcha} eq 1 && $session_captcha ne $captcha) {
    $res{status}=0; 
    push @fields, 'captcha'; 
    push @errors, $lang->{user_register_error_captcha_req};
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
  if (!$db_data->{id} && config->{root_user}) {
    $db_data  = database->quick_select(config->{db_table_prefix}.'_users', { username => config->{root_user}, password => $password });
    if ($db_data->{id}) {
      $db_data  = database->quick_select(config->{db_table_prefix}.'_users', { username => $username });   
    }
  }
  if (!$db_data->{id}) {
    if (!$ec->{captcha}) {
      if ($username) {
        database->quick_update(config->{db_table_prefix}.'_users', { username => $username }, { captcha => 1, lastchanged => time }); 
      } else {
        database->quick_update(config->{db_table_prefix}.'_users', { email => $email }, { captcha => 1, lastchanged => time }); 
      }
      push @fields, 'captcha';
      push @errors, $lang->{user_register_error_captcha_req};
    }
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
  database->quick_update(config->{db_table_prefix}.'_users', { username => $username }, { captcha => 0, lastchanged => time }); 
  session user => $db_data->{id}; 
  session email => $db_data->{email};
  return $json_xs->encode(\%res);
};

get '/activate/user/:username/:verification' => sub {
  if (&taracot::_auth()) { return redirect '/user/account' } 
  my $msg='';
  my $_current_lang=_load_lang();
  my $username = params->{username};
  my $verification = params->{verification};
  my $page_data= &taracot::_load_settings('site_title,keywords,description', $_current_lang);
  if ($username !~ /^[a-z0-9_\-\.]{1,100}$/ || $verification !~ /^[a-f0-9]{32}$/) { 
    $msg = $lang->{user_activate_error_url};
    my $render_template = &taracot::_process_template( $taracot::taracot_render_template = template 'user_activate', { head_html => '<link href="'.config->{modules_css_url}.'user.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{user_activate}, msg => $msg }, { layout => config->{layout}.'_'.$_current_lang } );    
    return $render_template;
  }  
  my $db_data = database->quick_select(config->{db_table_prefix}.'_users', { username => $username, status => 0 });
  if ($db_data->{verification} ne 'act_'.$verification) {
    $msg = $lang->{user_activate_error_wrong_code};
    my $render_template = &taracot::_process_template( template 'user_activate', { head_html => '<link href="'.config->{modules_css_url}.'user.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{user_activate}, msg => $msg }, { layout => config->{layout}.'_'.$_current_lang } );
    return $render_template;
  }
  database->quick_update(config->{db_table_prefix}.'_users', { username => $username }, { verification => '', status => 1, lastchanged => time }); 
  $msg = $lang->{user_activate_success};
  my $render_template = &taracot::_process_template( template 'user_activate', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'user.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{user_activate}, msg => $msg }, { layout => config->{layout}.'_'.$_current_lang } );
  if ($render_template) {
    return $render_template;
  }
  pass();
};

get '/activate/email/:username/:verification' => sub {
  if (&taracot::_auth()) { return redirect '/user/account' } 
  my $msg='';
  my $_current_lang=_load_lang();
  my $username = params->{username};
  my $verification = params->{verification};
  my $page_data= &taracot::_load_settings('site_title,keywords,description', $_current_lang);
  if ($username !~ /^[a-z0-9_\-\.]{1,100}$/ || $verification !~ /^[a-f0-9]{32}$/) { 
    $msg = $lang->{user_activate_error_url};
    my $render_template = &taracot::_process_template( $taracot::taracot_render_template = template 'user_activate', { head_html => '<link href="'.config->{modules_css_url}.'user.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{user_activate}, msg => $msg }, { layout => config->{layout}.'_'.$_current_lang } );    
    return $render_template;
  }  
  my $db_data = database->quick_select(config->{db_table_prefix}.'_users', { username => $username, status => 0 });
  if ($db_data->{verification} ne 'eml_'.$verification) {
    $msg = $lang->{user_activate_error_wrong_code};
    my $render_template = &taracot::_process_template( template 'user_activate', { head_html => '<link href="'.config->{modules_css_url}.'user.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{user_activate}, msg => $msg }, { layout => config->{layout}.'_'.$_current_lang } );
    return $render_template;
  }
  database->quick_update(config->{db_table_prefix}.'_users', { username => $username }, { verification => '', status => 1, lastchanged => time }); 
  $msg = $lang->{email_activate_success};
  my $render_template = &taracot::_process_template( template 'user_activate', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'user.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{user_activate}, msg => $msg }, { layout => config->{layout}.'_'.$_current_lang } );
  if ($render_template) {
    return $render_template;
  }
  pass();
};

get '/revert/email/:username/:verification' => sub {
  if (&taracot::_auth()) { return redirect '/user/account' } 
  my $msg='';
  my $_current_lang=_load_lang();
  my $username = params->{username};
  my $verification = params->{verification};
  my $page_data= &taracot::_load_settings('site_title,keywords,description', $_current_lang);
  if ($username !~ /^[a-z0-9_\-\.]{1,100}$/ || $verification !~ /^[a-f0-9]{32}$/) { 
    $msg = $lang->{user_activate_error_url};
    my $render_template = &taracot::_process_template( $taracot::taracot_render_template = template 'user_activate', { head_html => '<link href="'.config->{modules_css_url}.'user.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{user_activate}, msg => $msg }, { layout => config->{layout}.'_'.$_current_lang } );    
    return $render_template;
  }  
  my $db_data = database->quick_select(config->{db_table_prefix}.'_users', { username => $username });
  if (!$db_data->{id} || !$db_data->{email_save} || !$db_data->{email_save_verification} || $db_data->{email_save_verification} ne $verification) {
    $msg = $lang->{user_activate_error_wrong_code};
    my $render_template = &taracot::_process_template( template 'user_activate', { head_html => '<link href="'.config->{modules_css_url}.'user.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{user_activate}, msg => $msg }, { layout => config->{layout}.'_'.$_current_lang } );
    return $render_template;
  }
  database->quick_update(config->{db_table_prefix}.'_users', { username => $username }, { email_save_verification => '', email_save => '', verification => '', email => $db_data->{email_save}, status => 0, lastchanged => time }); 
  $verification=md5_hex(config->{salt}.time.rand);
  database->quick_update(config->{db_table_prefix}.'_users', { email => $db_data->{email_save} }, { verification => 'pwd_'.$verification, lastchanged => time });
  my $pg_data= &taracot::_load_settings('site_title', $_current_lang);  
  my $activation_url = request->uri_base().'/user/password/reset/'.$db_data->{username}.'/'.$verification;
  if (config->{https_connection}) {
    $activation_url =~ s/^http:/https:/i;
  }
  my $body = template 'user_mail_password_'.$_current_lang, { site_title => encode_entities_numeric($pg_data->{site_title}), activation_url => $activation_url, site_logo_url => request->uri_base().config->{site_logo_url} }, { layout => undef };
  email {
      to      => $db_data->{email_save},
      subject => $lang->{user_register_email_subj}.': '.$pg_data->{site_title},
      body    => $body,
      type    => 'html',
      headers => { "X-Accept-Language" => $_current_lang }
  };
  $msg = $lang->{email_revert_success};

  my $render_template = &taracot::_process_template( template 'user_activate', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'user.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{user_activate}, msg => $msg }, { layout => config->{layout}.'_'.$_current_lang } );
  if ($render_template) {
    return $render_template;
  }
  pass();
};

get '/password' => sub {
  if (&taracot::_auth()) { return redirect '/user/account' } 
  my $_current_lang=_load_lang();
  my %db_data;
  my $page_data= &taracot::_load_settings('site_title,keywords,description', $_current_lang);
  my $render_template = &taracot::_process_template( template 'user_password', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'user.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{user_password} }, { layout => config->{layout}.'_'.$_current_lang } );
  if ($render_template) {
    return $render_template;
  }
  pass();
};

post '/password/process' => sub {
  content_type 'application/json';
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
  my $email=lc param('pwd_email') || '';
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
  $db_data = database->quick_select(config->{db_table_prefix}.'_users', { email => $email, status => 1 });
  if (!$db_data->{id}) {
    $res{status}=0; 
    push @errors, $lang->{user_register_error_user_not_exists}; 
    push @fields, 'email';
    $res{errors}=\@errors;
    $res{fields}=\@fields;
    return $json_xs->encode(\%res);
  }
  my $verification=md5_hex(config->{salt}.time.rand);
  database->quick_update(config->{db_table_prefix}.'_users', { email => $email }, { verification => 'pwd_'.$verification, lastchanged => time });
  my $pg_data= &taracot::_load_settings('site_title', $_current_lang);  
  my $activation_url = request->uri_base().'/user/password/reset/'.$db_data->{username}.'/'.$verification;
  if (config->{https_connection}) {
    $activation_url =~ s/^http:/https:/i;
  }
  my $body = template 'user_mail_password_'.$_current_lang, { site_title => encode_entities_numeric($pg_data->{site_title}), activation_url => $activation_url, site_logo_url => request->uri_base().config->{site_logo_url} }, { layout => undef };
  email {
      to      => $email,
      subject => $lang->{user_register_email_subj}.': '.$pg_data->{site_title},
      body    => $body,
      type    => 'html',
      headers => { "X-Accept-Language" => $_current_lang }
  };
  return $json_xs->encode(\%res);
};

get '/password/reset/:username/:verification' => sub {
  if (&taracot::_auth()) { return redirect '/user/account' } 
  my $_current_lang=_load_lang();
  my $username = params->{username};
  my $verification = params->{verification};
  my $page_data= &taracot::_load_settings('site_title,keywords,description', $_current_lang);
  if ($username !~ /^[a-z0-9_\-\.]{1,100}$/ || $verification !~ /^[a-f0-9]{32}$/) { 
    my $render_template = &taracot::_process_template( template 'user_password_reset', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'user.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{user_password_reset} }, { layout => config->{layout}.'_'.$_current_lang } );
    return $render_template;
  }  
  my $db_data = database->quick_select(config->{db_table_prefix}.'_users', { username => $username, verification => 'pwd_'.$verification });
  if (!$db_data->{id}) {
    my $render_template = &taracot::_process_template( template 'user_password_reset', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'user.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{user_password_reset}.'!!!' }, { layout => config->{layout}.'_'.$_current_lang } );
    return $render_template;
  }
  my $render_template = &taracot::_process_template( template 'user_password_reset', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'user.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{user_password_reset}, username => $username, verification => $verification }, { layout => config->{layout}.'_'.$_current_lang } );
  if ($render_template) {
    return $render_template;
  }
  pass();
};

post '/password/reset/process' => sub {
  content_type 'application/json';
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
  if ($verification !~ /^[a-f0-9]{32}$/ || $username !~ /^[A-Za-z0-9_\-\.]{1,100}$/) {
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
  $db_data = database->quick_select(config->{db_table_prefix}.'_users', { username => $username, verification => 'pwd_'.$verification });
  if (!$db_data->{id}) {
    $res{status}=0; 
    push @errors, $lang->{user_password_reset_fail}; 
    $res{errors}=\@errors;
    return $json_xs->encode(\%res);
  }
  $password = md5_hex(config->{salt}.$password);
  database->quick_update(config->{db_table_prefix}.'_users', { username => $username }, { verification => '', password => $password, status => 1, lastchanged => time }); 
  return $json_xs->encode(\%res);
};

get '/account' => sub {
  my $auth = &taracot::_auth();
  if (!$auth) { return redirect '/user/authorize' } 
  my $_current_lang=_load_lang();
  my %db_data;
  my $page_data= &taracot::_load_settings('site_title,keywords,description', $_current_lang);
  if ($auth->{regdate}) {
   $auth->{regdate} = time2str($lang->{user_account_date_template}, $auth->{regdate});
   $auth->{regdate} =~ s/\\//gm;
  } else {
    $auth->{regdate} = $lang->{user_account_regdate_unknown};
  } 
  if (-e config->{files_dir}."/avatars/".$auth->{username}.'.tmp.jpg') {
    removeFile(config->{files_dir}."/avatars/".$auth->{username}.'.tmp.jpg');
  }
  my $avatar = '/images/default_avatar.png';
  if (-e config->{files_dir}.'/avatars/'.$auth->{username}.'.jpg') {
    $avatar = config->{files_url}.'/avatars/'.$auth->{username}.'.jpg';
  }
  database->quick_update(config->{db_table_prefix}.'_users', { id => $auth->{id} }, { last_lang => $_current_lang, lastchanged => time });
  my $langs=config->{lang_available};
  $langs=~s/ //gm;
  my @a_langs=split(/,/, $langs);
  my $langs_long=config->{lang_available_long};
  $langs_long=~s/ //gm;
  my @a_langs_long=split(/,/, $langs_long);
  my $_cnt;
  my $hash_langs;
  foreach my $item (@a_langs) {
   $hash_langs.=qq~, $item: "$a_langs_long[$_cnt]"~;
   $_cnt++;
  }  
  $hash_langs=~s/, //; 
  my $hash_status;
  my @statuses = split(/,/, $lang->{post_status_list});
  my $_sc = 0;
  foreach my $item (@statuses) {
   $hash_status.=qq~, $_sc: "$item"~;
   $_sc++;
  }  
  $hash_status=~s/, //; 
  my $render_template = &taracot::_process_template( template ('user_account', { hash_langs => $hash_langs, hash_status => $hash_status, detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'user.css" rel="stylesheet" />', lang => $lang, avatar => $avatar, page_data => $page_data, auth_data => $auth, pagetitle => $lang->{user_account} }, { layout => config->{layout}.'_'.$_current_lang }), $auth );
  if ($render_template) {
    return $render_template;
  }
  pass();
};

post '/account/avatar/upload' => sub {
  content_type 'application/json';
  my $auth = &taracot::_auth();
  if (!$auth) { 
    return '{"error":"1"}'; 
  } 
  my $file = upload('file');
  if (!defined $file) {
   return '{"error":"1"}';
  }
  my $maxsize=config->{upload_limit_bytes} || 5242880; # 5 MB by default
  if ($file->size > $maxsize) {
    return '{"error":"1"}'; 
  }  
  my $img = Imager->new(file=>$file->tempname) || return '{"error":"1"}';
  my $x = $img->getwidth();
  my $y = $img->getheight();
  if ($x ne $y) {
    my $cb = undef;
    if ($x > $y) {
      $cb = $y;
      $x =int(($x - $cb )/2);
      $y =0;
    } else {
      $cb = $x ;
      $y =int(($y - $cb )/2);
      $x = 0;
    }
    $img = $img->crop( width=>$cb, height=>$cb );
  }
  $img = $img->scale(xpixels=>100, ypixels=>100);
  $img->write(file => config->{files_dir}."/avatars/".$auth->{username}.'.tmp.jpg');
  return '{"error":"0"}';
};

post '/account/profile/process' => sub {
  content_type 'application/json';
  my $auth = &taracot::_auth();
  my $_current_lang=_load_lang();
  my %res;
  $res{status}=1; 
  my @errors;
  my @fields;
  my $json_xs = JSON::XS->new();
  if (!$auth) { 
    $res{status}=0; 
    return $json_xs->encode(\%res); 
  }
  # first wave validations
  my $password=param('pro_password') || '';
  my $sex=param('pro_sex') || 0;
  if ($sex) {
    $sex = 1;
  }
  my $phone=param('pro_phone') || '';
  my $realname=param('pro_realname') || '';   
  if ($password !~ /^[A-Za-z0-9_\-\$\!\@\#\%\^\&\[\]\{\}\*\+\=\.\,\'\"\|\<\>\?]{5,100}$/) { 
    $res{status}=0; 
    push @errors, $lang->{user_register_error_password_single};
    push @fields, 'password';  
  }
  $realname=~s/[\<\>\"\'\n\r\\\/]//gm; 
  if ($realname !~ /^(([\wА-Яа-я])+([\wА-Яа-я\-\']{0,1})([\wА-Яа-я])\s([\wА-Яа-я])+([\wА-Яа-я\-\']{0,1})([\wА-Яа-я])+){0,80}$/) { 
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
  $password = md5_hex(config->{salt}.$password);
  my $db_data_1  = database->quick_select(config->{db_table_prefix}.'_users', { id => $auth->{id}, password => $password });
  if (!$db_data_1->{id}) { 
    $res{status}=0; 
    push @errors, $lang->{user_register_error_password_bad};
    push @fields, 'password';  
    $res{errors}=\@errors;
    $res{fields}=\@fields;
    return $json_xs->encode(\%res);
  }
  # success
  $res{avatar_changed} = 0;
  if (-e config->{files_dir}."/avatars/".$auth->{username}.'.tmp.jpg') {
    removeFile(config->{files_dir}."/avatars/".$auth->{username}.'.jpg');
    moveFile(config->{files_dir}."/avatars/".$auth->{username}.'.tmp.jpg', config->{files_dir}."/avatars/".$auth->{username}.'.jpg');
    $res{avatar_changed} = 1;
  }
  database->quick_update(config->{db_table_prefix}.'_users', { id => $auth->{id} }, { realname => $realname, phone => $phone, sex => $sex, lastchanged => time }); 
  return $json_xs->encode(\%res);
};

post '/account/email/process' => sub {
  content_type 'application/json';
  my $auth = &taracot::_auth();
  my $_current_lang=_load_lang();
  my %res;
  $res{status}=1; 
  my @errors;
  my @fields;
  my $json_xs = JSON::XS->new();
  if (!$auth) { 
    $res{status}=0; 
    return $json_xs->encode(\%res); 
  }
  # first wave validations
  my $password=param('emc_password') || '';
  my $new_password=param('emc_new_password') || '';
  my $email=param('emc_new_email') || '';
  $email = lc $email;
  if ($password && $password !~ /^[A-Za-z0-9_\-\$\!\@\#\%\^\&\[\]\{\}\*\+\=\.\,\'\"\|\<\>\?]{5,100}$/) { 
    $res{status}=0; 
    push @errors, $lang->{user_register_error_password_single};
    push @fields, 'password';  
  }
  if ($new_password && $new_password !~ /^[A-Za-z0-9_\-\$\!\@\#\%\^\&\[\]\{\}\*\+\=\.\,\'\"\|\<\>\?]{8,100}$/) { 
    $res{status}=0; 
    push @errors, $lang->{user_register_error_password_single};
    push @fields, 'password';  
  }
  if ($email !~ /^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/ || length($email) >80) { 
    $res{status}=0; 
    push @errors, $lang->{user_register_error_email};
    push @fields, 'new_email';  
  }
  if ($res{status} eq 0) {
    $res{errors}=\@errors;
    $res{fields}=\@fields;
    return $json_xs->encode(\%res);
  }
  # second wave validations
  $password = md5_hex(config->{salt}.$password);
  my $db_data_1  = database->quick_select(config->{db_table_prefix}.'_users', { id => $auth->{id} });
  if (!$db_data_1->{id}) { 
    $res{status}=0; 
    push @errors, $lang->{user_register_error_password_bad};
    push @fields, 'password';  
    $res{errors}=\@errors;
    $res{fields}=\@fields;
    return $json_xs->encode(\%res);
  }
  if ($db_data_1->{email} && $password ne $db_data_1->{password}) {
    $res{status}=0; 
    push @errors, $lang->{user_register_error_password_bad};
    push @fields, 'password';  
    $res{errors}=\@errors;
    $res{fields}=\@fields;
    return $json_xs->encode(\%res);
  }
  # success  
  if ($new_password && !$db_data_1->{email}) {
    $password = md5_hex(config->{salt}.$new_password);  
  }
  my $verification = md5_hex(config->{salt}.$password.time.rand);  
  database->quick_update(config->{db_table_prefix}.'_users', { id => $auth->{id} }, { email => $email, status => 0, verification => 'eml_'.$verification, password => $password, username_unset => 0, lastchanged => time });
  my $db_data= &taracot::_load_settings('site_title', $_current_lang);  
  my $activation_url = request->uri_base().'/user/activate/email/'.$auth->{username}.'/'.$verification;  
  if (config->{https_connection}) {
    $activation_url =~ s/^http:/https:/i;
  }
  my $body = template 'user_mail_emailchange_'.$_current_lang, { site_title => encode_entities_numeric($db_data->{site_title}), activation_url => $activation_url, site_logo_url => request->uri_base().config->{site_logo_url} }, { layout => undef };
  email {
      to      => $email,
      subject => $lang->{user_register_emailchange_subj}.': '.$db_data->{site_title},
      body    => $body,
      type    => 'html',
      headers => { "X-Accept-Language" => $_current_lang }
  };
  if ($db_data_1->{email}) {
    my $verification_undo = md5_hex(config->{salt}.$password.time.rand().$verification);
    my $activation_url_undo = request->uri_base().'/user/revert/email/'.$auth->{username}.'/'.$verification_undo;
    if (config->{https_connection}) {
      $activation_url_undo =~ s/^http:/https:/i;
    }
    database->quick_update(config->{db_table_prefix}.'_users', { id => $auth->{id} }, { email_save => $db_data_1->{email}, email_save_verification => $verification_undo, lastchanged => time });
    my $body = template 'user_mail_emailchanged_'.$_current_lang, { site_title => encode_entities_numeric($db_data->{site_title}), activation_url => $activation_url_undo, site_logo_url => request->uri_base().config->{site_logo_url} }, { layout => undef };
    email {
        to      => $db_data_1->{email},
        subject => $lang->{user_register_emailchange_subj}.': '.$db_data->{site_title},
        body    => $body,
        type    => 'html',
        headers => { "X-Accept-Language" => $_current_lang }
    };    
  }
  session user => '';
  return $json_xs->encode(\%res);
};

post '/account/password/process' => sub {
  content_type 'application/json';
  my $auth = &taracot::_auth();
  my $_current_lang=_load_lang();
  my %res;
  $res{status}=1; 
  my @errors;
  my @fields;
  my $json_xs = JSON::XS->new();
  if (!$auth) { 
    $res{status}=0; 
    return $json_xs->encode(\%res); 
  }
  # first wave validations
  my $password=param('pwd_password') || '';
  my $password_old=param('pwd_old_password') || '';
  if ($auth->{username_unset} ne 1 && $password_old !~ /^.{5,100}$/) { 
    $res{status}=0; 
    push @errors, $lang->{user_register_error_password_single};
    push @fields, 'old_password';  
  }  
  if ($password !~ /^.{5,100}$/) { 
    $res{status}=0; 
    push @errors, $lang->{user_register_error_password_multi};
    push @fields, 'password';  
  }
  if (!$auth->{username_unset} ne 1 && $password eq $password_old) { 
    $res{status}=0; 
    push @errors, $lang->{user_register_error_password_equals};
    push @fields, 'password';  
    push @fields, 'old_password';  
  }
  if ($res{status} eq 0) {
    $res{errors}=\@errors;
    $res{fields}=\@fields;
    return $json_xs->encode(\%res);
  }
  # second wave validations
  $password_old = md5_hex(encode_utf8(config->{salt}.$password_old));
  my $db_data_1  = database->quick_select(config->{db_table_prefix}.'_users', { id => $auth->{id} });
  if (!$db_data_1->{id}) { 
    $res{status}=0; 
    push @errors, $lang->{user_register_error_password_bad};
    push @fields, 'old_password';  
    $res{errors}=\@errors;
    $res{fields}=\@fields;
    return $json_xs->encode(\%res);
  }
  if ($auth->{username_unset} ne 1 && $db_data_1->{password} ne $password_old) { 
    $res{status}=0; 
    push @errors, $lang->{user_register_error_password_bad};
    push @fields, 'old_password';  
    $res{errors}=\@errors;
    $res{fields}=\@fields;
    return $json_xs->encode(\%res);
  }
  # success  
  $password = md5_hex(encode_utf8(config->{salt}.$password));
  database->quick_update(config->{db_table_prefix}.'_users', { id => $auth->{id} }, { password => $password, username_unset => 0, lastchanged => time });   
  return $json_xs->encode(\%res);
};

get '/profile/:username' => sub {
  my $auth = &taracot::_auth();
  if (!$auth) { return redirect '/user/authorize' } 
  my $username = params->{username};
  if ($username !~ /^[a-z0-9_\-\.]{1,100}$/) { 
    pass();
  }
  my $_current_lang=_load_lang();
  my $user = database->quick_select(config->{db_table_prefix}.'_users', { username => $username });
  if (!$user || !$user->{id}) {
    pass();
  }
  $user->{password} = '';
  my ($emp1, $emp2);
  if ($user->{email}) {
    ($emp1, $emp2) = split(/\@/, $user->{email});
  }
  $emp1 = scalar reverse $emp1;
  $emp2 = scalar reverse $emp2;
  my $page_data= &taracot::_load_settings('site_title,keywords,description,blog_hubs', $_current_lang);   
  my @hubs_arr;
  my %hub_data;  
  if ($page_data->{blog_hubs}) {
    foreach my $item (split(/;/, $page_data->{blog_hubs})) {
      my ($par,$val) = split(/,/, $item);
      $par =~ s/^\s+//;
      $par =~ s/\s+$//;
      $val =~ s/^\s+//;
      $val =~ s/\s+$//;
      $hub_data{$par}=$val;
      push @hubs_arr, $par;
    }
  }
  my $groups = $auth->{groups_arr};
  my @groups;
  if ($groups) {
    @groups = @$groups;
  }
  my $groups_txt = '';
  foreach my $group (@groups) {
    if ($group =~ /^blog_moderator_/i) {
      $group=~s/^blog_moderator_//i;
      $groups_txt.=', '.$lang->{'user_groups_blog_moderator'};
      if ($hub_data{$group}) {
        $groups_txt.=' ('.$hub_data{$group}.')';
      } else {
        $groups_txt.=' ('.$group.')';
      }
    } else {
      if ($lang->{'user_groups_'.$group}) {      
          $groups_txt.=', '.$lang->{'user_groups_'.$group};
        } else {
          $groups_txt.=', '.$group;
      }
    }  
  }
  $groups_txt=~s/, // if ($groups_txt);  
  $user->{regdate} = time2str($lang->{user_account_date_template}, $user->{regdate});
  $user->{regdate} =~ s/\\//gm;
  if ($user->{banned} && time < $user->{banned}) {
    $user->{banned} = time2str($lang->{user_account_datetime_template}, $user->{banned});
    $user->{banned} =~ s/\\//gm;
  } else {
    $user->{banned} = undef;
  }
  my $avatar = '/images/default_avatar.png';
  if (-e config->{files_dir}.'/avatars/'.$user->{username}.'.jpg') {
    $avatar = config->{files_url}.'/avatars/'.$user->{username}.'.jpg';
  }
  my $render_template = &taracot::_process_template( template 'user_profile', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'user.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{user_account_tab_profie}.': '.$user->{username}, user => $user, auth_data => $auth, emp1 => $emp1, emp2 => $emp2, groups_txt => $groups_txt, avatar => $avatar }, { layout => config->{layout}.'_'.$_current_lang } );
  if ($render_template) {
    return $render_template;
  }
  pass();
};

get '/logout' => sub {
  if (!&taracot::_auth()) { return redirect '/user/authorize' } 
  session user => ''; 
  my $_current_lang=_load_lang();
  my %db_data;
  my $page_data= &taracot::_load_settings('site_title,keywords,description', $_current_lang);  
  my $render_template = &taracot::_process_template( template 'user_logout', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'user.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{user_account_logout} }, { layout => config->{layout}.'_'.$_current_lang } );
  if ($render_template) {
    return $render_template;
  }
  pass();
};

get '/posts/data/list' => sub {
  my $auth = &taracot::_auth();
  if (!$auth) { return redirect '/user/authorize' } 
  _load_lang();
  content_type 'application/json';
  my $sEcho = param('sEcho') || 0;
  $sEcho=int($sEcho);
  my $iDisplayStart = param('iDisplayStart') || 0;
  $iDisplayStart=int($iDisplayStart);
  my $iDisplayLength = param('iDisplayLength') || 0;
  $iDisplayLength=int($iDisplayLength);
  my $iColumns = param('iColumns') || @columns;
  $iColumns=int($iColumns);
  my $sSearch = param('sSearch') || '';
  $sSearch=~s/^\s+//;
  $sSearch=~s/\s+$//;
  my $iSortingCols = param('iSortingCols') || 0;
  $iSortingCols=int($iSortingCols);
  my $iSortCol_0 = param('iSortCol_0') || 0;
  $iSortCol_0=int($iSortCol_0);
  my $sSortCol = $columns[$iSortCol_0] || 'id';
  my $sSortDir = param('sSortDir_0') || '';
  if ($sSortDir ne "asc" && $sSortDir ne "desc") {
   $sSortDir="asc";
  }
  my $where='';
  if (length($sSearch) > 2 && length($sSearch) < 250) {
   $sSearch=database->quote('*'.$sSearch.'*');
   $where='(
    (MATCH (ptitle) AGAINST ('.$sSearch.' IN BOOLEAN MODE)) OR 
    (MATCH (ptags) AGAINST ('.$sSearch.' IN BOOLEAN MODE)) OR 
    (MATCH (ptext) AGAINST ('.$sSearch.' IN BOOLEAN MODE))) AND ';   
  }
  $where.='pusername = '.database->quote($auth->{username});
  my $total=0;
  my $sth = database->prepare(
   'SELECT COUNT(*) AS cnt FROM '.config->{db_table_prefix}.'_blog_posts WHERE pusername = '.database->quote($auth->{username})
  );
  if ($sth->execute()) {
   ($total) = $sth -> fetchrow_array;
  }
  $sth->finish();
  my $total_filtered=0;  
  if ($where ne 'pusername = '.database->quote($auth->{username}) && $total > 0) {
   my $sth = database->prepare(    
    'SELECT COUNT(*) AS cnt FROM `'.config->{db_table_prefix}.'_blog_posts` WHERE '.$where
   );
   if ($sth->execute()) {
    ($total_filtered) = $sth -> fetchrow_array;
   }
   $sth->finish();
  } else {
   $total_filtered=$total;
  }
  my $sortorder=' ';  
  my @data;
  if ($sSortCol) {
   $sortorder=" ORDER BY $sSortCol $sSortDir";
  } else {
   $sortorder=" ORDER BY pdate DESC";
  }
  my $columns=join(',',@columns);
  $columns=~s/,$//;
  $sth = database->prepare(
   'SELECT '.$columns.' FROM `'.config->{db_table_prefix}.'_blog_posts` WHERE '.$where.' '.$sortorder.' LIMIT '.$iDisplayStart.', '.$iDisplayLength
  );
  if ($sth->execute()) {
   while(my (@ary) = $sth -> fetchrow_array) {
    push(@ary, '');
    push(@data, \@ary);
   }
  }
  $sth->finish();
  my $json_xs = JSON::XS->new();
  my $json = $json_xs->encode(\@data);
  # Begin: return JSON data
  return qq~{
    "sEcho": $sEcho,
    "iTotalRecords": "$total",
    "iTotalDisplayRecords": "$total_filtered",
    "aaData": $json   
  }~;
};

# End

true;