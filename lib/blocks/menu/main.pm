package blocks::menu::main;
use Dancer ':syntax';
use JSON::XS("decode_json");
use Fcntl qw(:flock SEEK_END); # import LOCK_* and SEEK_END constants 
use Encode qw(decode decode_utf8);
use taracot::fs;
use HTML::Entities;

sub new {
 my ($class)=shift;
 my $self = {
     @_,
 };
 bless $self, ref $class || $class || "blocks::menu::main";
 return $self;
}

my $lang;

sub _load_lang {
  my $lng=shift;
  my $lang_adm = YAML::XS::LoadFile(config->{root_dir}.'lib/blocks/menu/lang/en.lng') || {};
  my $lang_adm_cnt={};
  if ($lng ne 'en') {
   my $lang_adm_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/blocks/menu/lang/'.$lng.'.lng') || {};
  }
  $lang = { %$lang_adm, %$lang_adm_cnt };
}

sub data() {
 my $self=shift;
 my $dl = &taracot::_detect_lang();
 my $current_lang = $dl->{lng} || config->{lang_default};
 &_load_lang($current_lang);
 my %reply = (
  block_content    => ''  
 );
 my $sitemap_html=config->{root_dir}.'/'.config->{data_dir}.'/sitemap_'.$current_lang.'.html';
 if (-e $sitemap_html) {
  open(DATA, $sitemap_html) || return \%reply;
  flock(DATA, LOCK_EX) || return \%reply;
  binmode DATA, ':utf8';
  my $data=join('', <DATA>);
  close(DATA) || return \%reply;
  $reply{block_content}=$data;
  return \%reply; 
 }
 my $json;
 my $sitemap_file=config->{root_dir}.'/'.config->{data_dir}.'/sitemap_'.$current_lang.'.json';
 if (!-e $sitemap_file) {
  $reply{block_content}=$lang->{no_menu_available};
 } else {
  my $data=loadFile($sitemap_file);
  if (defined $data) { 
   $json = decode_json($$data)
  } 
 }
 my $res;
 my $level0=@$json[0];
 my $level0_children=$level0->{children};
 my @level1;
 if (defined $level0_children) {
  @level1=@$level0_children;
 }
 my $cnt=0;
 foreach my $item (@level1) {
  if ($item->{children}) {
   $cnt++;
   my $url='#_taracot_bar_menu'.$cnt;
   if ($item->{url}) {
    $url=$item->{url};
   }
   if ($item->{title}) {
    $res.=qq~<li class="dropdown" id="_taracot_bar_menu$cnt"><a class="dropdown-toggle" data-toggle="dropdown" href="$url">~.$item->{title}.qq~<b class="caret"></b></a><ul class="dropdown-menu">~;
   } 
   my $level2_children=$item->{children};
   my @level2=@$level2_children;
   foreach my $child (@level2) {
    if ($child->{title}) {
     if ($child->{title} eq '-') {
      $res.=qq~<li class="divider"></li>~;
     } else {
      my $url='#';
      if ($child->{url}) {
       $url=$child->{url};
      }
      my $idbu = lc $url;
      $idbu=~s/\//_/;
      $res.=qq~<li id="_taracot_bar_$idbu"><a href="$url">~.encode_entities($child->{title}).qq~</a></li>~;
     }
    } 
   }
   $res.=qq~</ul></li>~;
  } else {
   my $url='#';
   if ($item->{url}) {
    $url=$item->{url};
   }
   my $idbu = lc $url;
   $idbu=~s/\//_/;
   $res.=qq~<li id="_taracot_bar_$idbu"><a href="$url">~.encode_entities($item->{title}).qq~</a></li>~;
  }
 }
 $reply{block_content}=$lang->{input_output_error};
 open(DATA, '>'.config->{root_dir}.'/'.config->{data_dir}.'/sitemap_'.$current_lang.'.html') || return \%reply;
 flock(DATA, LOCK_EX) || return \%reply;
 binmode DATA;
 print DATA $res || return \%reply;
 close(DATA) || return \%reply; 
 $reply{block_content}=$res;
 return \%reply;
}

true;