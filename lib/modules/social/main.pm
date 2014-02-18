package modules::social::main;
use Dancer ':syntax';
use Date::Format;
use Dancer::Plugin::Database;
use Time::HiRes qw ( time );
use HTML::Restrict;
use Digest::MD5 qw(md5_hex);
use LWP::UserAgent; 
use HTTP::Request::Common qw{ POST };

# Configuration

my $defroute = '/social';
my $sq_url = 'http://127.0.0.1:3000/data';

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
  $sth = database->prepare(
    'SELECT COUNT(*) AS cnt FROM '.config->{db_table_prefix}.'_social_messaging_stat WHERE ref_id = '.database->quote($auth_data->{id}).' AND flag_unread = 1'
  );
  my $unread_flag = '0';
  if ($sth->execute()) {
    ($unread_flag) = $sth -> fetchrow_array;
    $unread_flag = 1 if ($unread_flag);
  } 
  $sth->finish();
  $user_data->{'regdate'} = time2str($lang->{user_account_date_template}, $user_data->{'regdate'});
  $user_data->{'regdate'} =~ s/\\//gm;  
  $user_data->{'avatar'} = '/images/default_avatar.png';
  if (-e config->{files_dir}.'/avatars/'.$auth_data->{username}.'.jpg') {
    $user_data->{'avatar'} = config->{files_url}.'/avatars/'.$auth_data->{username}.'.jpg';
  } 
  my $json_xs = JSON::XS->new();
  my $session_id = md5_hex($auth_data->{id}.'-'.config->{salt}).md5_hex($auth_data->{username}.'-'.config->{salt});
  return &taracot::_process_template( template ('social_index', { head_html => '<link href="'.config->{modules_css_url}.'social.css" rel="stylesheet" />', detect_lang => $detect_lang, lang => $lang, page_data => $page_data, pagetitle => $lang->{social_network}, auth_data => $auth_data, user_data => $json_xs->encode($user_data), friends_count => $friends_count, invitations_count => $inv_count, messages_flag => $unread_flag, session_id => $session_id }, { layout => config->{layout}.'_'.$_current_lang }), $auth_data );  
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
  my $uid = param('uid') || 0;
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
    'SELECT COUNT(*) AS cnt FROM '.config->{db_table_prefix}.'_social_friends WHERE user1 = '.database->quote($auth_data->{id}).' OR user2 = '.database->quote($auth_data->{id}).' AND status='.$req_status
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

post '/messages/load' => sub {
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
    'SELECT id, ufrom, uto, mtime, msg FROM '.config->{db_table_prefix}.'_social_messaging WHERE ((ufrom = '.$auth_data->{id}.' AND uto = '.$uid.') OR (uto = '.$auth_data->{id}.' AND ufrom = '.$uid.')) ORDER BY mtime ASC LIMIT 50'
  );        
  my @res_arr;
  if ($sth->execute()) {
    while (my ($id, $ufrom, $uto, $mtime, $msg) = $sth->fetchrow_array) {
      my %item;
      $item{'id'} = $id;
      $item{'ufrom'} = $ufrom;
      $item{'uto'} = $uto;
      $item{'mtime'} = time2str($lang->{chat_time_template}, int($mtime));
      $item{'mtime'} =~ s/\\//gm; 
      $item{'msg'} = $msg;
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
  $sth = database->prepare(
    'UPDATE '.config->{db_table_prefix}.'_social_messaging_stat SET flag_unread=0 WHERE ref_id='.database->quote($auth_data->{id}).' AND user_id='.database->quote($uid)
  );  
  $sth->execute();
  $sth->finish();
  $sth = database->prepare(
    'SELECT COUNT(*) AS cnt FROM '.config->{db_table_prefix}.'_social_messaging_stat WHERE ref_id = '.database->quote($auth_data->{id}).' AND flag_unread = 1'
  );
  my $unread_flag = '0';
  if ($sth->execute()) {
    ($unread_flag) = $sth -> fetchrow_array;
    $unread_flag = 1 if ($unread_flag);
  } 
  $sth->finish();
  $res{'unread_flag'} = $unread_flag;
  my $json_xs = JSON::XS->new();
  return $json_xs->encode(\%res);
};

post '/messages/save' => sub {
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
  my $json_xs = JSON::XS->new();
  my $msg = param('msg');
  my $hr = HTML::Restrict->new();
  $msg = $hr->process($msg);
  $msg =~ s/\n/<br>/gm;
  if (!$msg || length($msg) > 4096) {
    $res{'status'} = 0;
    $res{'errmsg'} = $lang->{incorrect_msg};
    return $json_xs->encode(\%res);
  }
  my $sth = database->prepare(
    'SELECT id, username FROM '.config->{db_table_prefix}.'_users WHERE id = '.$uid.' AND status > 0'
  );  
  my $check_id;  
  my $dest_username;
  if ($sth->execute()) {
    ($check_id, $dest_username) = $sth->fetchrow_array();
  }
  $sth->finish();
  if (!$check_id) {
    $res{'status'} = 0;
    $res{'errmsg'} = $lang->{incorrect_user};
    return $json_xs->encode(\%res);
  }
  my $last_time;
  $sth = database->prepare(
    'SELECT mtime FROM '.config->{db_table_prefix}.'_social_messaging WHERE uto = '.$uid.' AND ufrom = '.$auth_data->{id}.' ORDER BY mtime DESC LIMIT 1'
  );  
  if ($sth->execute()) {
    ($last_time) = $sth->fetchrow_array();
  }
  $sth->finish();
  if (time-$last_time < 5) {
    $res{'status'} = 0;
    $res{'errmsg'} = $lang->{too_frequent_msg};
    return $json_xs->encode(\%res);
  }
  my $mtime = time;
  database->quick_insert(config->{db_table_prefix}.'_social_messaging', { ufrom => $auth_data->{id}, uto => $uid, mtime => $mtime, msg => $msg }); 
  my $mid = database->last_insert_id(undef,undef,undef,undef);
  if (!$mid) {
    $sth = database->prepare(
      'SELECT id FROM `'.config->{db_table_prefix}.'_social_messaging` WHERE mtime = '.$mtime.' AND uto = '.$uid.' AND ufrom = '.$auth_data->{id}
    );
    if ($sth->execute()) {
      ($mid) = $sth->fetchrow_array();
    }
    $sth->finish();
  }
  if (!$mid) {
    $res{'status'} = 0;
    $res{'errmsg'} = $lang->{ajax_error};
    return $json_xs->encode(\%res);  
  }
  my $dbdata  = database->quick_select(config->{db_table_prefix}.'_social_messaging_stat', { user_id => $auth_data->{id}, ref_id => $uid }); 
  if ($dbdata->{id}) {
    $sth = database->prepare(
      'UPDATE '.config->{db_table_prefix}.'_social_messaging_stat SET flag_unread=1, count_msg=count_msg+1, last_msg='.database->quote($msg).', last_msg_date='.database->quote($mtime).' WHERE id='.database->quote($dbdata->{id})
    );  
    $sth->execute();
    $sth->finish();
  } else {
    database->quick_insert(config->{db_table_prefix}.'_social_messaging_stat', { user_id => $auth_data->{id}, ref_id => $uid, flag_unread => 1, count_msg => 1, last_msg => $msg, last_msg_date => $mtime }); 
  }
  my $username = $auth_data->{username};
  my $avatar = '/images/default_avatar.png';
  if (-e config->{files_dir}.'/avatars/'.$username.'.jpg') {
    $avatar = config->{files_url}.'/avatars/'.$username.'.jpg';
  } 
  $res{'id'} = $mid;
  $res{'username'} = $username;
  $res{'avatar'} = $avatar;
  $res{'ufrom'} = $auth_data->{id};
  $res{'uto'} = $uid;
  $res{'mtime'} = time2str($lang->{chat_time_template}, int($mtime));
  $res{'mtime'} =~ s/\\//gm; 
  $res{'msg'} = $msg;

  my $session_id = md5_hex($uid.'-'.config->{salt}).md5_hex($dest_username.'-'.config->{salt});
  my $ua = LWP::UserAgent->new();
  my $request = POST( $sq_url, [ 'session' => $session_id, 'update' => 'Oops! I did it again ;)' ] );
  $ua->request($request)->as_string();

  return $json_xs->encode(\%res);
};

post '/messages/list' => sub {
  my $auth_data = &taracot::_auth();
  if (!$auth_data) {
    return '{"status":"0"}'; 
  }
  my $json_xs = JSON::XS->new();
  my %res;
  $res{'status'} = 1;
  my $_current_lang=_load_lang(); 
  my $sth = database->prepare(
   'SELECT DISTINCT u.id, u.username, u.realname, s.flag_unread, s.count_msg, t.count_msg, s.last_msg, s.last_msg_date, t.last_msg, t.last_msg_date FROM taracot_users u JOIN (SELECT IF (uto='.database->quote($auth_data->{id}).', ufrom, uto) as uid, mtime FROM taracot_social_messaging WHERE uto='.database->quote($auth_data->{id}).' OR ufrom='.database->quote($auth_data->{id}).') m ON u.id = m.uid LEFT JOIN taracot_social_messaging_stat s ON (s.user_id = m.uid AND s.ref_id = '.database->quote($auth_data->{id}).') LEFT JOIN taracot_social_messaging_stat t ON (t.ref_id = m.uid AND t.user_id = '.database->quote($auth_data->{id}).') ORDER BY IF (s.last_msg_date > t.last_msg_date, s.last_msg_date, t.last_msg_date) DESC'
  );  
  my @items;
  if ($sth->execute()) {
   while (my ($id, $username, $realname, $unread, $cnt, $cnt2, $last_msg, $last_msg_date, $last_msg2, $last_msg_date2) = $sth->fetchrow_array()) {
    my %item;
    my $avatar = '/images/default_avatar.png';
    if (-e config->{files_dir}.'/avatars/'.$username.'.jpg') {
      $avatar = config->{files_url}.'/avatars/'.$username.'.jpg';
    } 
    $item{'avatar'} = $avatar;
    $item{id} = $id;
    $item{username} = $username;    
    $item{realname} = $realname;
    $item{unread} = $unread || 0;
    $item{total} = $cnt || 0;
    if ($cnt2) {
      $item{total} += $cnt2;
    }
    if ($last_msg_date2 > $last_msg_date) {
      $item{last_msg} = truncate_string($last_msg2, 256);
      $item{last_msg_date} = $last_msg_date2;
    } else {
      $item{last_msg} = truncate_string($last_msg, 256);
      $item{last_msg_date} = $last_msg_date;
    }    
    $item{last_msg_date} = time2str($lang->{chat_time_template}, $item{last_msg_date});
    $item{last_msg_date} =~ s/\\//gm;  
    push @items, \%item;
   }
  }
  $res{'items'} = \@items;
  $sth->finish();
  return $json_xs->encode(\%res);
};

sub truncate_string($$) {
  my ( $string, $max ) = @_;
  $string =~ s/<br>/ /igm;
  $string =~ tr/ +/ /;
  ( length( $string ) <= $max ) and return $string;
  if ( $string =~ /\s/ ) {
    return substr( $string, 0, $max ).'...';
  }
  $string =~ /^(.*)\s+$/ and return $1.'...';
  $string =~ s/\S+$// and return $string.'...';
  return $string;
}

1;