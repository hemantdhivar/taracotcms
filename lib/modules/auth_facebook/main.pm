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

  my $auth_data = &taracot::_auth();
  if ($auth_data) { redirect '/user/account' } 
  my $detect_lang = &taracot::_detect_lang();
  my $_current_lang = $detect_lang->{lng} || config->{lang_default};

  # Try to get data from facebook

  my $code = param('code');
  my $response = $agent->get("https://graph.facebook.com/oauth/access_token?client_id=".config->{auth_facebook_app_id}."&client_secret=".&config->{auth_facebook_app_secret}."&redirect_uri=".config->{auth_facebook_redirect_uri}."&code=".url_encode($code));
  if (!$response->is_success) {
    redirect '/user/authorize';
  }
  my $data = {};
  foreach my $item (split(/\&/, $response->content)) {
    my ($name, $val) = split(/\=/, $item);
    $data->{$name} = $val;
  }
  if (!$data->{access_token}) {
    redirect '/user/authorize?reason=no_token';
  }
  $response = $agent->get("https://graph.facebook.com/me?access_token=".url_encode($data->{access_token}));
  if (!$response->is_success) {
    redirect '/user/authorize?reason=token_error';
  }
  my $json;
  eval { $json = decode_json $response->content; }; 
  redirect '/user/authorize?reason=json_error' if $@;
  redirect '/user/authorize?reason=no_email' if !$json->{email};

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
    redirect '/user/account?'.md5_hex(rand*time); 
  } else {
    my $username = $json->{username};
    my $password = md5_hex(config->{salt}.(rand * time));
    my $phone = '';
    my $realname = $json->{name};
    $realname=~s/\"//gm;
    $realname=~s/\'//gm;
    $realname=~s/\<//gm;
    $realname=~s/\>//gm;
    database->quick_insert(config->{db_table_prefix}.'_users', { username => $username, password => $password, email => $email, phone => $phone, realname => $realname, status => 1, verification => '', regdate => time, lastchanged => time });
    my $id = database->{q{mysql_insertid}}; 
    if ($id) {
     session user => $id;
     redirect '/user/account?'.md5_hex(rand*time); 
    } else {
     redirect '/user/authorize'; 
    }
  }

  return "New user! $email"

};

# End

true;