package modules::auth_yandex::main;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use LWP::UserAgent;
use URL::Encode qw(url_encode);
use JSON::XS("decode_json");
use Digest::MD5 qw(md5_hex);
use Dancer::Plugin::Database;

my $agent=LWP::UserAgent->new;
$agent->timeout(10);
$agent->env_proxy;
$agent->default_header('Content-Length' => "0 ");

prefix '/';

get '/user/authorize/yandex/' => sub { 

  my $auth_uri_base = session('auth_uri_base') || '/';
  my $auth_comeback = session('auth_comeback') || '/user/account?'.md5_hex(rand*time);

  my $auth_data = &taracot::_auth();
  if ($auth_data) { 
    redirect $auth_uri_base.'/user/account';
    return;
  } 
  
  my $detect_lang = &taracot::_detect_lang($auth_uri_base);
  my $_current_lang = $detect_lang->{lng} || config->{lang_default};

  # Try to get data from yandex

  my $code = param('code');
  my $response = $agent->post("https://oauth.yandex.ru/token", { code => $code, grant_type => 'authorization_code', client_id => config->{auth_yandex_client_id}, client_secret => config->{auth_yandex_client_secret} });
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
  $response = $agent->get("https://login.yandex.ru/info?format=json&oauth_token=".$data->{access_token});
  if (!$response->is_success) {
    redirect $auth_uri_base.'/user/authorize1';
    return;
  }
  my $json;
  eval { $json = decode_json $response->content; }; 
  if ($@) {
    redirect $auth_uri_base.'/user/authorize';
    return;
  }
  if (!$json->{default_email}) {
    redirect $auth_uri_base.'/user/authorize';
    return;
  }

  # Check if user is registered

  my $email = lc $json->{default_email};
  my $username = $json->{display_name};  
  if (!$username) {
    redirect $auth_uri_base.'/user/authorize';
    return;
  }
  $username='yandex.'.$username;

  my ($id, $db_email);
  my $sth = database->prepare(
    'SELECT id, email FROM `'.config->{db_table_prefix}.'_users` WHERE username='.database->quote($username)
  );
  if ($sth->execute()) {
    ($id, $db_email) = $sth->fetchrow_array();
  }
  $sth->finish();
  if (!$id) {
    my $sth = database->prepare(
      'SELECT id, email FROM `'.config->{db_table_prefix}.'_users` WHERE email='.database->quote($email)
    );
    if ($sth->execute()) {
      ($id, $db_email) = $sth->fetchrow_array();
    }
    $sth->finish();
  }

  # Registered

  if ($id) {
    session user => $id;
    session email => $db_email;
    database->quick_update(config->{db_table_prefix}.'_users', { id => $id }, { last_lang => $_current_lang, lastchanged => time });
    redirect $auth_uri_base.$auth_comeback; 
    return;
  } else {
    my $password = md5_hex(config->{salt}.(rand * time));
    my $phone = '';
    my $realname = $json->{real_name};
    $realname=~s/\"//gm;
    $realname=~s/\'//gm;
    $realname=~s/\<//gm;
    $realname=~s/\>//gm;
    #database->quick_insert(config->{db_table_prefix}.'_users', { username => $username, password => $password, username_unset => 1, password_unset => 1, email => $email, phone => $phone, realname => $realname, status => 1, verification => '', regdate => time, lastchanged => time });
    my $sth = database->prepare(
      'INSERT INTO '.config->{db_table_prefix}.'_users SET username = '.database->quote($username).', username_social = '.database->quote($username).', password = '.database->quote($password).', username_unset = 1, password_unset = 1, email = '.database->quote($email).', phone = '.database->quote($phone).', realname = '.database->quote($realname).', status = 1, verification = \'\', regdate = '.time.', lastchanged = '.time
    );
    $sth->execute();
    $sth->finish();
    my $id = database->{q{mysql_insertid}}; 
    if ($id) {
     session user => $id;
     database->quick_update(config->{db_table_prefix}.'_users', { id => $id }, { last_lang => $_current_lang, lastchanged => time });
     redirect $auth_uri_base.$auth_comeback; 
    } else {
     redirect $auth_uri_base.'/user/authorize'; 
    }
  }

};

# End

true;