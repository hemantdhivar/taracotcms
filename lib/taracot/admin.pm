package taracot::admin;
use Dancer ':syntax';
use YAML::XS;
use Module::Load;
use Dancer::Plugin::Database;
use Digest::MD5 qw(md5_hex);

my $lang = YAML::XS::LoadFile(config->{root_dir}.'lib/taracot/lang/'.config->{lang_default}.'.lng');

my $navdata;
my $authdata;

sub _auth() {
  if (session('user')) { 
   my $id = session('user');
   $authdata  = database->quick_select(config->{db_table_prefix}.'_users', { id => $id });
  } else {
   $authdata->{id} = 0;
   $authdata->{status} = 0;
   $authdata->{username} = '';
   $authdata->{password} = '';
  }
  if ($authdata->{status}) {
   if ($authdata->{status} == 2) {
    return true;
   }
  }
  return false;
};

# Load modules and navigation data

my $load_modules = config->{load_modules_admin};
$load_modules=~s/ //gm;
my @modules = split(/,/, $load_modules);
foreach my $module (@modules) {
 my $taracot_module_load="modules::".lc($module)."::main";
 load $taracot_module_load;
 my $name = $taracot_module_load->_name() || lc($module);
 my $defroute = $taracot_module_load->_defroute(); 
 $navdata.=qq~<li id="nav_$module"><a href="$defroute">$name</a></li>~; 
}
$navdata.=qq~\n~;
foreach my $mod (@modules) {
 my $module="modules::".lc($mod)."::main";
 $module->_navdata($navdata);
}

# Process admin routes

prefix "/admin";

get '/' => sub {
  if (_auth()) {
	  return template 'admin_index', { lang => $lang, navdata => $navdata, authdata => $authdata }, { layout => 'admin' };
  }
  return template 'admin_login_raw', { lang => $lang }, { layout => undef };
};

post '/authorize' => sub {
  content_type 'application/json';
  my $username = param('username');
  my $password = md5_hex(config->{salt}.param('password'));
  my $ud  = database->quick_select(config->{db_table_prefix}.'_users', { username => $username, password => $password });
  if ($ud) {
    if ($ud->{status} == 2) {
     session user => $ud->{id};
     return '{"result":"1"}'."\n";
    }
  }
  return '{"result":"0"}'."\n";
};

get '/logout' => sub {
  if (!_auth()) {
   redirect '/admin?'.md5_hex(time)
  } else {
   session user => '';
   redirect '/admin?'.md5_hex(time);
  }
};

true;