package modules::blog::main;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use JSON::XS();
use Digest::MD5 qw(md5_hex);
use Date::Format;
use taracot::fs;
use taracot::AUBBC;

# Configuration

my $defroute = '/blog';

# Module core settings 

my $lang;
prefix $defroute;
my $detect_lang;

sub _name() {
 &_load_lang();
  return $lang->{module_name};
}           
sub _defroute() {
  return $defroute;
}
sub _load_lang {
  $detect_lang = &taracot::_detect_lang();
  my $lng = $detect_lang->{lng} || config->{lang_default};
  my $lang_adm = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/blog/lang/en.lng') || {};
  my $lang_adm_cnt={};
  if ($lng ne 'en') {
   $lang_adm_cnt = YAML::XS::LoadFile(config->{root_dir}.'lib/modules/blog/lang/'.$lng.'.lng') || {};
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

sub flow() {  
  my $flow = '';
  my $ipp = 2; # items per page
  my $page = int($_[0]) || 1;
  my $_current_lang=_load_lang(); 
  my $aubbc = taracot::AUBBC->new();
  my $auth = &taracot::_auth();

  my $total=0;
  my $sth = database->prepare(
   'SELECT COUNT(*) AS cnt FROM '.config->{db_table_prefix}.'_blog_posts WHERE 1'
  );
  if ($sth->execute()) {
   ($total) = $sth -> fetchrow_array;
  }
  $sth->finish();
  my $pc = int($total / $ipp);
  my $pitems='';
  if ($page ne 1) {
    $pitems .= template 'blog_paginator_item', { page_url => '/blog/page/1', page_text => '&laquo;' }, { layout => undef };
  }  
  my $lof = 5-$page;
  if ($lof > 4 || $lof < 0) {
    $lof=0;
  }
  my $rof = -($page-$pc);
  if ($rof > 4) {
    $rof=0;
  } else {
    $rof=4-$rof;
  }

  for (my $it=1; $it<=$pc; $it++) {    
    if ($pc>9) {
      if ($it < $page-4-$rof || $it > $page+4+$lof) {
        next;
      }
    }
    my $active;
    if ($it eq $page) {
      $active = 1;
    }
    $pitems .= template 'blog_paginator_item', { page_url => '/blog/page/'.$it, page_text => $it,active => $active }, { layout => undef };
  }
  if ($page ne $pc) {
    $pitems .= template 'blog_paginator_item', { page_url => '/blog/page/'.$pc, page_text => '&raquo;' }, { layout => undef };
  }
  my $paginator = template 'blog_paginator', { items => $pitems }, { layout => undef };

  my $limx = $page*$ipp-$ipp;
  $sth = database->prepare(
   'SELECT id,pusername,phub,ptitle,ptags,pdate,uid,ptext,lastmodified,pviews,is_public FROM '.config->{db_table_prefix}.'_blog_posts WHERE plang='.database->quote($_current_lang).' ORDER BY pdate DESC LIMIT '.$limx.', '.$ipp
  );
  if ($sth->execute()) {
   while(my ($id,$pusername,$phub,$ptitle,$ptags,$pdate,$uid,$ptext,$lastmodified,$pviews,$is_public) = $sth -> fetchrow_array) {
    my $phub_url;
    if ($phub) {
      $phub_url = '/blog/hub/'.$phub;
    }
    if (!$pviews) {
      $pviews='&nbsp;0';
    }
    my $post_url = '/blog/post/'.$id;
    my $read_more_url;
    if ($ptext=~/\[cut\]/i) {
      ($ptext) = split(/\[cut\]/i, $ptext);
      $read_more_url = $post_url;
    }
    $ptext = $aubbc->do_all_ubbc($ptext);
    $ptags =~ s/[^\w\n ,]//g;
    my @tags = split(/,/, $ptags);
    $ptags='';
    foreach my $tag (@tags) {
      $tag=~s/^ //;      
      $ptags.=', <a href="/blog/tag/'.$tag.'">'.$tag.'</a>';
    }
    $ptags=~s/, //;
    my $item_template = template 'blog_feed', { post_title => $ptitle, blog_hub => $phub, blog_hub_url => $phub_url, blog_text_cut => $ptext, blog_user => $pusername, blog_views => $pviews, blog_tags => $ptags, blog_read_more => $read_more_url, blog_post_url => $post_url, read_more => $lang->{read_more} }, { layout => undef };
    $flow .= $item_template;    
   }
  }
  $sth->finish();     
  my $page_data= &taracot::_load_settings('site_title,keywords,description', $_current_lang);    
  return &taracot::_process_template( template 'blog_index', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'blog.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{module_name}, news_feed => $flow, paginator => $paginator, auth_data => $auth  }, { layout => config->{layout}.'_'.$_current_lang } );
}

get '/' => sub {  
  my $render_template = &flow();
  if ($render_template) {
    return $render_template;
  }
  pass();
};

get '/page/:page' => sub {  
  my $bpage = int(params->{page});
  if (!$bpage) {
    pass();
  }
  my $render_template = &flow($bpage);
  if ($render_template) {
    return $render_template;
  }
  pass();
};

get '/post/:post_id' => sub {
  my $post_id = params->{post_id};  
  $post_id=~s/[^0-9]//gm; 
  if (!$post_id) {
    pass();
  }
  my $auth = &taracot::_auth();
  my $_current_lang=_load_lang(); 
  my $aubbc = taracot::AUBBC->new();
  my $item_template;
  my $page_data= &taracot::_load_settings('site_title,keywords,description', $_current_lang);  
  my $sth = database->prepare(
   'SELECT id,pusername,phub,ptitle,ptags,pdate,uid,ptext,lastmodified,pviews,is_public FROM '.config->{db_table_prefix}.'_blog_posts WHERE id = '.$post_id.' ORDER BY pdate DESC'
  );
  if ($sth->execute()) {
   my ($id,$pusername,$phub,$ptitle,$ptags,$pdate,$uid,$ptext,$lastmodified,$pviews,$is_public) = $sth -> fetchrow_array();
   my $phub_url;
   if ($phub) {
     $phub_url = '/blog/hub/'.$phub;
   }
   if (!$pviews) {
     $pviews='&nbsp;0';
   }    
   $ptext =~s/\[cut\]/ /igm;
   $ptext = $aubbc->do_all_ubbc($ptext);
   $item_template = &taracot::_process_template( template 'blog_post', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'blog.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $ptitle.' | '.$lang->{module_name}, post_title => $ptitle, blog_hub => $phub, blog_hub_url => $phub_url, blog_text => $ptext, blog_user => $pusername, blog_views => $pviews, blog_tags => $ptags, auth_data => $auth }, { layout => config->{layout}.'_'.$_current_lang } );
  }
  $sth->finish(); 
  if ($item_template) {
    return $item_template;
  }
  pass();
};

# End

true;