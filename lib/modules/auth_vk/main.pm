package modules::auth_vk::main;
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
$agent->default_header('Content-Length' => "0");

my $_debug = 1;

prefix '/';

get '/user/authorize/vk/' => sub { 
  my $auth_uri_base = session('auth_uri_base') || '/';
  my $auth_comeback = session('auth_comeback') || '/user/account?'.md5_hex(rand*time);
  my $auth_data = &taracot::_auth();
  if ($auth_data) { 
    return redirect $auth_uri_base.'/user/account';
  } 
  my $detect_lang = &taracot::_detect_lang($auth_uri_base);
  my $_current_lang = $detect_lang->{lng} || config->{lang_default};
  # Try to get data from vk
  my $code = param('code');
  my $response = $agent->post("https://oauth.vk.com/token", { code => $code, redirect_uri => config->{auth_vk_redirect_uri}, client_id => config->{auth_vk_client_id}, client_secret => config->{auth_vk_client_secret} });
  if (!$response->is_success) {
    return redirect $auth_uri_base.'/user/authorize';    
  }
  my $data;  
  eval { $data = decode_json $response->content; }; 
  if (!$data->{access_token}) {
    return redirect $auth_uri_base.'/user/authorize';    
  }
  if (!$data->{user_id}) {
    return redirect $auth_uri_base.'/user/authorize';    
  }
  $response = $agent->get("https://api.vk.com/method/users.get?access_token=".$data->{access_token}."&uids=".$data->{user_id}."&fields=uid,first_name,last_name,screen_name");
  if (!$response->is_success) {
    return redirect $auth_uri_base.'/user/authorize';    
  }
  my $json;
  eval { $json = decode_json $response->content; }; 
  if ($@) {
    return redirect $auth_uri_base.'/user/authorize';
  }
  my @da = @{$$json{response}};
  $json = $da[0];
  if (!$json->{uid}) {
    return redirect $auth_uri_base.'/user/authorize';
  }
  # Check if user is registered
  my $username = 'vk.'.lc($json->{uid});
  my ($id, $db_email);
  my $sth = database->prepare(
    'SELECT id, email FROM `'.config->{db_table_prefix}.'_users` WHERE username_social='.database->quote($username)
  );
  if ($sth->execute()) {
    ($id, $db_email) = $sth->fetchrow_array();
  }
  $sth->finish();
  # Registered
  if ($id) {
    session user => $id;
    session email => $db_email;
    database->quick_update(config->{db_table_prefix}.'_users', { id => $id }, { last_lang => $_current_lang, lastchanged => time });
    return redirect $auth_uri_base.$auth_comeback;     
  } else {
    my $password = md5_hex(config->{salt}.(rand * time));
    my $realname = $json->{first_name}.' '.$json->{last_name};
    $realname=~s/\"//gm;
    $realname=~s/\'//gm;
    $realname=~s/\<//gm;
    $realname=~s/\>//gm;
    database->quick_insert(config->{db_table_prefix}.'_users', { username => $username, username_social => $username, password => $password, username_unset => 1, password_unset => 1, email => '', phone => '', realname => $realname, status => 1, verification => '', regdate => time, lastchanged => time });
    my $sql_id = database->{q{mysql_insertid}};
    if ($sql_id) {     
     database->quick_update(config->{db_table_prefix}.'_users', { id => $sql_id }, { last_lang => $_current_lang, lastchanged => time });
     session user => $sql_id;
     session email => '';
     return redirect $auth_uri_base.$auth_comeback; 
    } else {
     return redirect $auth_uri_base.'/user/authorize';
    }
  }
};

# End

true;