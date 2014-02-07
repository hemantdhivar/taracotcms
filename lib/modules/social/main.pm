package modules::social::main;
use Dancer ':syntax';
use Date::Format;
use Dancer::Plugin::Database;

# Configuration

my $defroute = '/social';

# Module core settings 

my $lang;
my $detect_lang;
prefix $defroute;

sub _load_lang {
  $detect_lang = &taracot::_detect_lang();
  my $lng = $detect_lang->{lng} || config->{lang_default};
  my $lang_adm = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/social/lang/en.lng') || {};
  my $lang_adm_cnt={};
  if ($lng ne 'en') {
   $lang_adm_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/social/lang/'.$lng.'.lng') || {};
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
  my $auth_data = &taracot::_auth();
  if (!$auth_data) {
    return redirect '/user/authorize?comeback=/social'
  }
  my $_current_lang=_load_lang();
  my $page_data = &taracot::_load_settings('site_title,keywords,description', $_current_lang);
  my $sth = database->prepare(
    'SELECT id, username, realname, phone, regdate FROM '.config->{db_table_prefix}.'_users WHERE id='.$auth_data->{id}
  );
  my $user_data;
  if ($sth->execute()) {
    $user_data = $sth->fetchrow_hashref;
  }
  $sth->finish();
  $sth = database->prepare(
    'SELECT COUNT(*) AS cnt FROM '.config->{db_table_prefix}.'_social_friends WHERE (user1 = '.database->quote($auth_data->{id}).' OR user2 = '.database->quote($auth_data->{id}).') AND status = 1'
  );
  my $friends_count = '0';
  if ($sth->execute()) {
    ($friends_count) = $sth -> fetchrow_array;
  } 
  $sth->finish();
  $sth = database->prepare(
    'SELECT COUNT(*) AS cnt FROM '.config->{db_table_prefix}.'_social_friends WHERE user2 = '.database->quote($auth_data->{id}).' AND status = 0'
  );
  my $inv_count = '0';
  if ($sth->execute()) {
    ($inv_count) = $sth -> fetchrow_array;
  } 
  $sth->finish();
  $user_data->{'regdate'} = time2str($lang->{user_account_date_template}, $user_data->{'regdate'});
  $user_data->{'regdate'} =~ s/\\//gm;  
  $user_data->{'avatar'} = '/images/default_avatar.png';
  if (-e config->{files_dir}.'/avatars/'.$auth_data->{username}.'.jpg') {
    $user_data->{'avatar'} = config->{files_url}.'/avatars/'.$auth_data->{username}.'.jpg';
  } 
  my $json_xs = JSON::XS->new();
  return &taracot::_process_template( template ('social_index', { head_html => '<link href="'.config->{modules_css_url}.'social.css" rel="stylesheet" />', detect_lang => $detect_lang, lang => $lang, page_data => $page_data, pagetitle => $lang->{social_network}, auth_data => $auth_data, user_data => $json_xs->encode($user_data), friends_count => $friends_count, invitations_count => $inv_count, messages_count => 0 }, { layout => config->{layout}.'_'.$_current_lang }), $auth_data );  
};

post '/search' => sub {
  my $auth_data = &taracot::_auth();
  if (!$auth_data) {
    return '{"status":"0"}'; 
  }
  my $ipp = 30; # items per page
  my %res;
  $res{'status'} = 1;
  my $_current_lang=_load_lang(); 
  my $page = param('page') || 1;
  if ($page < 1) {
    return '{"status":"0"}'; 
  }
  my $search_query = param('search_query');  
  $search_query =~ s/[^\w\dА-Яа-яёЁ\s\-]//gm;
  $search_query =~ s/ +/ /gm;
  if (length($search_query) > 100) {
    return '{"status":"0"}';
  }  
  my $query_sql = '';
  if ($search_query && length($search_query) > 2) {
    $search_query = lc ($search_query);
    $query_sql = '(MATCH (username) AGAINST ('.database->quote($search_query.'*').' IN BOOLEAN MODE) OR MATCH (username) AGAINST ('.database->quote($search_query).' IN BOOLEAN MODE) OR MATCH (realname) AGAINST ('.database->quote($search_query.'*').' IN BOOLEAN MODE) OR MATCH (realname) AGAINST ('.database->quote($search_query).' IN BOOLEAN MODE) OR MATCH (phone) AGAINST ('.database->quote($search_query.'*').' IN BOOLEAN MODE) OR MATCH (phone) AGAINST ('.database->quote($search_query).' IN BOOLEAN MODE) OR MATCH (email) AGAINST ('.database->quote($search_query.'*').' IN BOOLEAN MODE) OR MATCH (email) AGAINST ('.database->quote($search_query).' IN BOOLEAN MODE)) AND ';
  }
  my $sth = database->prepare(
      'SELECT COUNT(*) AS cnt FROM '.config->{db_table_prefix}.'_users WHERE '.$query_sql.'status > 0'
  );
  my $total = 0;
  if ($sth->execute()) {
    ($total) = $sth -> fetchrow_array;
  } 
  $sth->finish();
  my $pc = $total / $ipp;  
  $res{'total'} = $total;
  $res{'pages'} = $pc;
  my $limx = $page*$ipp-$ipp;
  if ($total) {
    my $sth = database->prepare(
     'SELECT id, username, realname, phone, regdate FROM '.config->{db_table_prefix}.'_users WHERE '.$query_sql.'status > 0 ORDER BY realname, username LIMIT '.$limx.', '.$ipp
    );        
    my @res_arr;
    if ($sth->execute()) {
      while (my ($id, $username, $realname, $phone, $regdate) = $sth->fetchrow_array) {
        my %item;
        $regdate = time2str($lang->{user_account_date_template}, $regdate);
        $regdate =~ s/\\//gm;
        my $avatar = '/images/default_avatar.png';
        if (-e config->{files_dir}.'/avatars/'.$username.'.jpg') {
          $avatar = config->{files_url}.'/avatars/'.$username.'.jpg';
        } 
        $item{'id'} = $id;
        $item{'username'} = $username;
        $item{'realname'} = $realname;
        $item{'phone'} = $phone;
        $item{'avatar'} = $avatar;
        $item{'regdate'} = $regdate;
        push @res_arr, \%item;
      }
    }
    $res{items} = \@res_arr;
  }  
  my $json_xs = JSON::XS->new();
  return $json_xs->encode(\%res);
};

post '/user' => sub {
  my $auth_data = &taracot::_auth();
  if (!$auth_data) {
    return '{"status":"0"}'; 
  }
  my $id = int(param('id'));
  if ($id < 1) {
    return '{"status":"0"}';
  }
  my $sth = database->prepare(
    'SELECT id, username, realname, phone, regdate FROM '.config->{db_table_prefix}.'_users WHERE id='.$id.' AND status > 0'
  );
  my ($dbid, $username, $realname, $phone, $regdate) = undef;
  if ($sth->execute()) {
    ($dbid, $username, $realname, $phone, $regdate) = $sth->fetchrow_array;
  }
  $sth->finish();
  if (!$dbid) {
    return '{"status":"0"}';  
  }    
  my %item;
  $regdate = time2str($lang->{user_account_date_template}, $regdate);
  $regdate =~ s/\\//gm;
  my $avatar = '/images/default_avatar.png';
  if (-e config->{files_dir}.'/avatars/'.$username.'.jpg') {
    $avatar = config->{files_url}.'/avatars/'.$username.'.jpg';
  }
  $sth = database->prepare(
    'SELECT id, user1, user2, status FROM '.config->{db_table_prefix}.'_social_friends WHERE (user1 = '.database->quote($auth_data->{id}).' AND user2 = '.database->quote($id).') OR (user1 = '.database->quote($id).' AND user2 = '.database->quote($auth_data->{id}).')'
  );
  my $frdata;
  if ($sth->execute()) {
    $frdata = $sth->fetchrow_hashref;
  } 
  $sth->finish();
  $item{'friendship_status'} = 0;
  if ($frdata && $frdata->{id}) {
    if ($frdata->{status} eq 1) {
      $item{'friendship_status'} = 1;
      $item{'friendship_details'} = $lang->{friend_status_established};
    } else {
      if ($frdata->{user1} eq $auth_data->{id}) {
        $item{'friendship_details'} = $lang->{friend_status_request_sent};
      }
      if ($frdata->{user2} eq $auth_data->{id}) {
        $item{'friendship_details'} = $lang->{friend_status_request_recieved};
        $item{'friendship_unaccepted'} = 1;
      }
    }
  }
  $item{'id'} = $dbid;
  $item{'username'} = $username;
  $item{'realname'} = $realname;
  $item{'phone'} = $phone;
  $item{'avatar'} = $avatar;
  $item{'regdate'} = $regdate;
  $item{'status'} = 1;
  my $json_xs = JSON::XS->new();
  return $json_xs->encode(\%item);
};

post '/friend/request' => sub {
  my $auth_data = &taracot::_auth();
  if (!$auth_data) {
    return '{"status":"0"}'; 
  }
  my $id = int(param('id'));
  if ($id < 1) {
    return '{"status":"0"}';
  }
  my $sth = database->prepare(
    'SELECT id, user1, user2, status FROM '.config->{db_table_prefix}.'_social_friends WHERE (user1 = '.database->quote($auth_data->{id}).' AND user2 = '.database->quote($id).') OR (user1 = '.database->quote($id).' AND user2 = '.database->quote($auth_data->{id}).')'
  );
  my $user_data;
  if ($sth->execute()) {
    $user_data = $sth->fetchrow_hashref;
  } 
  $sth->finish();
  my $json_xs = JSON::XS->new();
  if ($user_data && $user_data->{id}) {
    if ($user_data->{user1} eq $auth_data->{id}) {
      my %res;
      $res{status} = 0;
      $res{msg} = $lang->{friend_request_already_sent};
      return $json_xs->encode(\%res);
    }
    if ($user_data->{user2} eq $auth_data->{id}) {
      my %res;
      $res{status} = 0;
      $res{msg} = $lang->{friend_request_already_received};
      return $json_xs->encode(\%res);
    }
    if ($user_data->{status} eq 1) {
      my %res;
      $res{status} = 0;
      $res{msg} = $lang->{friend_already_established};
      return $json_xs->encode(\%res);
    }
  }
  $sth = database->prepare(
    'INSERT INTO '.config->{db_table_prefix}.'_social_friends SET user1 = '.database->quote($auth_data->{id}).', user2 = '.database->quote($id).', status = 0'
  );
  $sth->execute();
  $sth->finish();
  return '{"status":"1"}';
};

post '/friend/accept' => sub {
  my $auth_data = &taracot::_auth();
  if (!$auth_data) {
    return '{"status":"0"}'; 
  }
  my $id = int(param('id'));
  if ($id < 1) {
    return '{"status":"0"}';
  }
  my $sth = database->prepare(
    'SELECT id, user1, user2, status FROM '.config->{db_table_prefix}.'_social_friends WHERE (user1 = '.database->quote($id).' AND user2 = '.database->quote($auth_data->{id}).')'
  );
  my $user_data;
  if ($sth->execute()) {
    $user_data = $sth->fetchrow_hashref;
  } 
  $sth->finish();
  if (!$user_data) {
    return '{"status":"0"}';
  }
  my $json_xs = JSON::XS->new();
  if ($user_data && $user_data->{id}) {    
    if ($user_data->{status} eq 1) {
      my %res;
      $res{status} = 0;
      $res{msg} = $lang->{friend_already_established};
      return $json_xs->encode(\%res);
    }
  }
  $sth = database->prepare(
    'UPDATE '.config->{db_table_prefix}.'_social_friends SET status=1 WHERE id = '.$user_data->{id}
  );
  $sth->execute();
  $sth->finish();
  return '{"status":"1"}';
};

post '/friends' => sub {
  my $auth_data = &taracot::_auth();
  if (!$auth_data) {
    return '{"status":"0"}'; 
  }
  my $ipp = 30; # items per page
  my %res;
  $res{'status'} = 1;
  my $_current_lang=_load_lang(); 
  my $page = param('page') || 1;
  if ($page < 1) {
    return '{"status":"0"}'; 
  }  
  my $uid = param('uid') || 1;
  if (!$uid || $uid < 1) {
    $uid = $auth_data->{id};
  } 
  my $req_status = 1;  
  my $inv_sql = '';
  if (param('invitations')) {
    $req_status = 0;
  } else {
    $inv_sql = ' OR f.user1 = '.$auth_data->{id}
  }
  if (param('invitations') && $auth_data->{id} ne $uid) {
    return '{"status":"0"}';
  }
  my $sth = database->prepare(
      'SELECT COUNT(*) AS cnt FROM '.config->{db_table_prefix}.'_social_friends WHERE (user1 = '.database->quote($auth_data->{id}).' OR user2 = '.database->quote($auth_data->{id}).') AND status='.$req_status
  );
  my $total = 0;
  if ($sth->execute()) {
    ($total) = $sth -> fetchrow_array;
  } 
  $sth->finish();
  my $pc = $total / $ipp;  
  $res{'total'} = $total;
  $res{'pages'} = $pc;
  my $limx = $page*$ipp-$ipp;
  if ($total) {
    my $sth = database->prepare(
     'SELECT u.id, u.username, u.realname, u.phone, u.regdate FROM '.config->{db_table_prefix}.'_users u LEFT JOIN '.config->{db_table_prefix}.'_social_friends f ON (f.user1 = u.id OR f.user2 = u.id) WHERE (f.user2 = '.$auth_data->{id}.$inv_sql.') AND f.status='.$req_status.' AND u.status > 0 AND u.id != '.$auth_data->{id}.' ORDER BY u.realname, u.username LIMIT '.$limx.', '.$ipp
    );        
    my @res_arr;
    if ($sth->execute()) {
      while (my ($id, $username, $realname, $phone, $regdate) = $sth->fetchrow_array) {
        my %item;
        $regdate = time2str($lang->{user_account_date_template}, $regdate);
        $regdate =~ s/\\//gm;
        my $avatar = '/images/default_avatar.png';
        if (-e config->{files_dir}.'/avatars/'.$username.'.jpg') {
          $avatar = config->{files_url}.'/avatars/'.$username.'.jpg';
        } 
        $item{'id'} = $id;
        $item{'username'} = $username;
        $item{'realname'} = $realname;
        $item{'phone'} = $phone;
        $item{'avatar'} = $avatar;
        $item{'regdate'} = $regdate;
        push @res_arr, \%item;
      }
    }
    $res{items} = \@res_arr;
  }  
  my $json_xs = JSON::XS->new();
  return $json_xs->encode(\%res);
};

any '/messages/load' => sub {
  my $auth_data = &taracot::_auth();
  if (!$auth_data) {
    return '{"status":"0"}'; 
  }
  my %res;
  $res{'status'} = 1;
  my $_current_lang=_load_lang(); 
  my $uid = param('uid');
  if (!$uid || $uid < 1) {
    return '{"status":"0"}';
  } 
  my $sth = database->prepare(
    'SELECT id, ufrom, uto, mtime, msg, unread FROM '.config->{db_table_prefix}.'_social_messaging WHERE ((ufrom = '.$auth_data->{id}.' AND uto = '.$uid.') OR (uto = '.$auth_data->{id}.' AND ufrom = '.$uid.')) ORDER BY utime ASC LIMIT 50'
  );        
  my @res_arr;
  if ($sth->execute()) {
    while (my ($id, $ufrom, $uto, $mtime, $msg, $unread) = $sth->fetchrow_array) {
      my %item;
      $item{'id'} = $id;
      $item{'ufrom'} = $ufrom;
      $item{'uto'} = $uto;
      $item{'mtime'} = $mtime;
      $item{'msg'} = $msg;
      $item{'unread'} = $unread;
      push @res_arr, \%item;
    }
  }
  $sth->finish();
  $res{messages} = \@res_arr;
  $sth = database->prepare(
    'SELECT id, username, realname FROM '.config->{db_table_prefix}.'_users WHERE id = '.$auth_data->{id}.' OR id = '.$uid
  );
  if ($sth->execute()) {
    my %users;
    while (my ($id, $username, $realname) = $sth->fetchrow_array) {
      my %user;
      $user{'id'} = $id;
      $user{'username'} = $username;
      $user{'realname'} = $realname;
      my $avatar = '/images/default_avatar.png';
      if (-e config->{files_dir}.'/avatars/'.$username.'.jpg') {
        $avatar = config->{files_url}.'/avatars/'.$username.'.jpg';
      } 
      $user{'avatar'} = $avatar;
      $users{$id} = \%user;
    }
    $res{'users'} = \%users;
  }
  $sth->finish();
  my $json_xs = JSON::XS->new();
  return $json_xs->encode(\%res);
};

1;