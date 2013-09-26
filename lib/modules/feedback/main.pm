package modules::feedback::main;
use Dancer ':syntax';
use Dancer::Plugin::Email;
use HTML::Entities qw(encode_entities_numeric);
use HTML::Restrict;

# Configuration

my $defroute = '/feedback';

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
  my $lang_adm = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/feedback/lang/en.lng') || {};
  my $lang_adm_cnt={};
  if ($lng ne 'en') {
   $lang_adm_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/feedback/lang/'.$lng.'.lng') || {};
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

get '/' => sub {
  my $auth = &taracot::_auth(); 
  my $_current_lang=_load_lang();
  my $page_data= &taracot::_load_settings('site_title,keywords,description', $_current_lang);
  return &taracot::_process_template( template 'feedback_index', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'feedback.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{module_name}, auth_data => $auth }, { layout => config->{layout}.'_'.$_current_lang } ); 
};

post '/process' => sub {
  content_type 'application/json';
  my $_current_lang=_load_lang();
  my %res;
  $res{status}=1; 
  my @errors;
  my @fields;
  my $json_xs = JSON::XS->new();
  my $captcha=int(param('f_captcha')) || 0;
  my $session_captcha=session('captcha');
  session captcha => rand; 
  if ($session_captcha ne $captcha) {    
    push @errors, $lang->{error_captcha};
    push @fields, 'f_captcha';
    $res{errors}=\@errors;
    $res{fields}=\@fields;
    $res{status}=0; 
    return $json_xs->encode(\%res); 
  }
  # first wave validations
  my $email=param('f_email') || '';
  my $phone=param('f_phone') || '';
  my $realname=param('f_realname') || '';   
  my $msg=param('f_msg') || '';     
  if ($email !~ /^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/ || length($email) >80) { 
    $res{status}=0; 
    push @errors, $lang->{error_email};
    push @fields, 'f_email';  
  }
  $email=lc($email);
  $realname=~s/[\<\>\"\'\n\r\\\/]//gm; 
  if ($realname !~ /^.{1,80}$/) { 
    $res{status}=0; 
    push @errors, $lang->{error_realname};
    push @fields, 'f_realname';  
  }
  $phone=~s/[^0-9]//gm;
  if (!$phone || length($phone) > 40) {
    $res{status}=0; 
    push @errors, $lang->{error_phone};
    push @fields, 'f_phone';
  }
  if (!$msg || length($msg) > 102400) { 
    $res{status}=0; 
    push @errors, $lang->{error_msg};
    push @fields, 'f_msg';  
  }
  if ($res{status} eq 0) {
    $res{errors}=\@errors;
    $res{fields}=\@fields;
    return $json_xs->encode(\%res);
  }
  my $db_data= &taracot::_load_settings('site_title,feedback_email', $_current_lang);
  if (!$db_data->{feedback_email}) {
    $res{status}=0; 
    push @errors, $lang->{feedback_email_missing};
    $res{errors}=\@errors;
    return $json_xs->encode(\%res);
  }
  my $hs = HTML::Restrict->new(); 
  $realname = $hs->process($realname);
  $msg = $hs->process($msg);  
  $realname =~ s/\</&lt;/gm;
  $realname =~ s/\>/&gt;/gm;
  $msg =~ s/\</&lt;/gm;
  $msg =~ s/\>/&gt;/gm;
  $realname =~ s/[\n\r\t]/<br\/>/gm;
  $msg =~ s/[\n\r\t]/<br\/>/gm;
  my $body = template 'feedback_mail_'.$_current_lang, { site_title => encode_entities_numeric($db_data->{site_title}), site_logo_url => request->uri_base().config->{site_logo_url}, realname => $realname, email => $email, phone => $phone, msg => $msg }, { layout => undef };
  email {
      to      => $db_data->{feedback_email},
      subject => $lang->{feedback_email_subj}.': '.$db_data->{site_title},
      body    => $body,
      type    => 'html',
      headers => { "X-Accept-Language" => $_current_lang }
  };  
  return $json_xs->encode(\%res); 
};

# End

true;