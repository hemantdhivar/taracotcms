package modules::auth_google::main;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use LWP::UserAgent;
use URL::Encode qw(url_encode);
use JSON::XS("decode_json");
use Digest::MD5 qw(md5_hex);
use Dancer::Plugin::Database;

my $agent=LWP::UserAgent->new;
$agent->timeout(5);
$agent->env_proxy;
$agent->default_header('Content-Length' => "0 ");

prefix '/';

get '/user/authorize/google/' => sub { 

  my $auth_uri_base = session('auth_uri_base') || '/';
  my $auth_comeback = session('auth_comeback') || '/user/account?'.md5_hex(rand*time);

  my $auth_data = &taracot::_auth();
  if ($auth_data) { 
    redirect $auth_uri_base.'/user/account';
    return;
  } 

  my $detect_lang = &taracot::_detect_lang($auth_uri_base);
  my $_current_lang = $detect_lang->{lng} || config->{lang_default};

  # Try to get data from google

  my $code = param('code');
  my $response = $agent->post("https://accounts.google.com/o/oauth2/token", { code => $code, client_id => config->{auth_google_client_id}, client_secret => config->{auth_google_client_secret}, redirect_uri => config->{auth_google_redirect_uri}, grant_type => 'authorization_code' });
  if (!$response->is_success) {
    redirect $auth_uri_base.'/user/authorize';
    return;
  }
  my $data;
  eval { $data = decode_json $response->content; }; 
  if (!$data->{access_token}) {
    redirect $auth_uri_base.'/user/authorize';
    return;
  }
  $response = $agent->get("https://www.googleapis.com/oauth2/v1/userinfo?access_token=".url_encode($data->{access_token}));
  if (!$response->is_success) {
    redirect $auth_uri_base.'/user/authorize';
    return;
  }
  my $json;
  eval { $json = decode_json $response->content; }; 
  if ($@) {
    redirect $auth_uri_base.'/user/authorize';
    return;
  }
  if (!$json->{email}) {
    redirect $auth_uri_base.'/user/authorize';
    return;
  }

  # Check if user is registered

  my $email = lc $json->{email};
  my $id;
  my $sth = database->prepare(
    'SELECT id FROM `'.config->{db_table_prefix}.'_users` WHERE email='.database->quote($email)
  );
  if ($sth->execute()) {
    ($id) = $sth->fetchrow_array();
  }
  $sth->finish();

  # Registered

  if ($id) {
    database->quick_update(config->{db_table_prefix}.'_users', { id => $id }, { last_lang => $_current_lang, lastchanged => time }); 
    session user => $id;
    database->quick_update(config->{db_table_prefix}.'_users', { id => $id }, { last_lang => $_current_lang, lastchanged => time });
    redirect $auth_uri_base.$auth_comeback; 
    return;
  } else {
    my $username = $json->{id};
    redirect $auth_uri_base.'/user/authorize' if !$username;
    $username='google.'.$username;
    my $password = md5_hex(config->{salt}.(rand * time));
    my $phone = '';
    my $realname = $json->{name};
    $realname=~s/\"//gm;
    $realname=~s/\'//gm;
    $realname=~s/\<//gm;
    $realname=~s/\>//gm;
    database->quick_insert(config->{db_table_prefix}.'_users', { username => $username, password => $password, password_unset => 1, email => $email, phone => $phone, realname => $realname, status => 1, verification => '', regdate => time, lastchanged => time });
    my $id = database->{q{mysql_insertid}}; 
    if ($id) {
     session user => $id;
     database->quick_update(config->{db_table_prefix}.'_users', { id => $id }, { last_lang => $_current_lang, lastchanged => time });
     redirect $auth_uri_base.$auth_comeback; 
     return;
    } else {
     redirect $auth_uri_base.'/user/authorize'; 
     return;
    }
  }

};

# End

true;