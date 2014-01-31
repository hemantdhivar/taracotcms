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
  return &taracot::_process_template( template ('social_index', { head_html => '<link href="'.config->{modules_css_url}.'social.css" rel="stylesheet" />', detect_lang => $detect_lang, lang => $lang, page_data => $page_data, pagetitle => $lang->{social_network}, auth_data => $auth_data  }, { layout => config->{layout}.'_'.$_current_lang }), $auth_data );  
};

post '/search' => sub {
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
  if (!$id) {
    return '{"status":"0"}';  
  }
  my %item;
  $regdate = time2str($lang->{user_account_date_template}, $regdate);
  $regdate =~ s/\\//gm;
  my $avatar = '/images/default_avatar.png';
  if (-e config->{files_dir}.'/avatars/'.$username.'.jpg') {
    $avatar = config->{files_url}.'/avatars/'.$username.'.jpg';
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


1;