package modules::auth_facebook::main;
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

get '/user/authorize/facebook/' => sub { 

  my $auth_uri_base = session('auth_uri_base') || '/';
  my $auth_comeback = session('auth_comeback') || '/user/account?'.md5_hex(rand*time);

  my $auth_data = &taracot::_auth();
  if ($auth_data) { 
    return redirect $auth_uri_base.'/user/account';    
  } 
  
  my $detect_lang = &taracot::_detect_lang($auth_uri_base);
  my $_current_lang = $detect_lang->{lng} || config->{lang_default};

  # Try to get data from facebook

  my $code = param('code');

  my $response = $agent->get("https://graph.facebook.com/oauth/access_token?client_id=".config->{auth_facebook_app_id}."&client_secret=".&config->{auth_facebook_app_secret}."&redirect_uri=".config->{auth_facebook_redirect_uri}."&code=".url_encode($code));
  if (!$response->is_success) {
    return redirect $auth_uri_base.'/user/authorize';
  }
  my $data = {};
  foreach my $item (split(/\&/, $response->content)) {
    my ($name, $val) = split(/\=/, $item);
    $data->{$name} = $val;
  }
  if (!$data->{access_token} || length($data->{access_token}) == 0) {
    return redirect $auth_uri_base.'/user/authorize';
  }
  $response = $agent->get("https://graph.facebook.com/me?access_token=".url_encode($data->{access_token}));
  if (!$response->is_success) {
    return redirect $auth_uri_base.'/user/authorize';    
  }
  my $json;
  eval { $json = decode_json $response->content; }; 
  if ($@) {
    return redirect $auth_uri_base.'/user/authorize';
  }
  if (!$json->{email}) {
    return redirect $auth_uri_base.'/user/authorize';
  }

  # Check if user is registered

  my $email = lc $json->{email};
  my $username = lc $json->{username};

  if (!$username) {
    return redirect $auth_uri_base.'/user/authorize';
  }  
  $username='facebook.'.$username;

  my $id;
  my $sth = database->prepare(
    'SELECT id FROM `'.config->{db_table_prefix}.'_users` WHERE username='.database->quote($username)
  );
  if ($sth->execute()) {
    ($id) = $sth->fetchrow_array();
  }
  $sth->finish();
  if (!$id) {
    my $sth = database->prepare(
      'SELECT id FROM `'.config->{db_table_prefix}.'_users` WHERE email='.database->quote($email)
    );
    if ($sth->execute()) {
      ($id) = $sth->fetchrow_array();
    }
    $sth->finish();
  }

  # Registered

  if ($id) {
    session user => $id;
    database->quick_update(config->{db_table_prefix}.'_users', { id => $id }, { last_lang => $_current_lang, lastchanged => time });
    return redirect $auth_uri_base.$auth_comeback;
  } else {    
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
     return redirect $auth_uri_base.$auth_comeback;
    } else {
     return redirect $auth_uri_base.'/user/authorize'; 
    }
  }

};

# End

true;