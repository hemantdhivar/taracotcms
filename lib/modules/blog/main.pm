package modules::blog::main;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use JSON::XS();
use Digest::MD5 qw(md5_hex);
use Date::Format;
use taracot::fs;
use taracot::AUBBC;
use URI::Encode qw(uri_encode uri_decode);
use Encode;

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
  my $hub = $_[1] || '';
  my $tag = $_[2] || '';
  my $_current_lang=_load_lang();   
  my $auth = &taracot::_auth();
  my $where = 'plang='.database->quote($_current_lang);
  if ($auth->{id}) {
    $where.=' AND pstate > 0';
  } else {
    $where.=' AND pstate = 1';
  }
  if ($hub) {
    $where.=' AND phub='.database->quote($hub);
  }
  if ($tag) {
    $where.=' AND MATCH (ptags) AGAINST (\''.$tag.'*\' IN BOOLEAN MODE)';
  }
  my $total=0;
  my $sth = database->prepare(
   'SELECT COUNT(*) AS cnt FROM '.config->{db_table_prefix}.'_blog_posts WHERE '.$where
  );
  if ($sth->execute()) {
   ($total) = $sth -> fetchrow_array;
  }
  $sth->finish();
  my $page_data= &taracot::_load_settings('site_title,keywords,description,blog_hubs', $_current_lang);
  my %hub_data;
  if ($page_data->{blog_hubs}) {
    foreach my $item (split(/;/, $page_data->{blog_hubs})) {
      my ($par,$val) = split(/,/, $item);
      $par =~ s/^\s+//;
      $par =~ s/\s+$//;
      $val =~ s/^\s+//;
      $val =~ s/\s+$//;
      $hub_data{$par}=$val;
    }
  }
  my $pc = int($total / $ipp);
  if ($total % $ipp) {
    $pc++;
  }
  my $paginator='';
  # Paginator code : begin
  if ($pc > 1) {
    my $url = '/blog/page/';
    if ($hub) {
      $url='/blog/hub/'.$hub.'/';
    }
    if ($tag) {          
      my $tagurl = uri_encode($tag);
      $tagurl=~s/%/_/gm;
      $url='/blog/tag/'.$tagurl.'/';
    }
    my $pitems='';
    if ($page ne 1) {
      $pitems .= template 'blog_paginator_item', { page_url => $url.'1', page_text => '&laquo;' }, { layout => undef };
    }    
    my $lof = 4-$page;
    if ($lof > 3 || $lof < 0) {
      $lof=0;
    }
    my $rof = -($page-$pc);
    if ($rof > 3) {
      $rof=0;
    } else {
      $rof=3-$rof;
    }
    for (my $it=1; $it<=$pc; $it++) {    
      if ($pc>7) {
        if ($it < $page-3-$rof || $it > $page+3+$lof) {
          next;
        }
      }
      my $active;
      if ($it eq $page) {
        $active = 1;
      }
      $pitems .= template 'blog_paginator_item', { page_url => $url.$it, page_text => $it,active => $active }, { layout => undef };
    }
    if ($page ne $pc) {
      $pitems .= template 'blog_paginator_item', { page_url => $url.$pc, page_text => '&raquo;' }, { layout => undef };
    }
    $paginator = template 'blog_paginator', { items => $pitems }, { layout => undef };
  }

  my $limx = $page*$ipp-$ipp;
  $sth = database->prepare(
   'SELECT id,pusername,phub,ptitle,ptags,pdate,ptext_html_cut,pcut,lastchanged,pviews,pcomments,pstate FROM '.config->{db_table_prefix}.'_blog_posts WHERE '.$where.' ORDER BY pdate DESC LIMIT '.$limx.', '.$ipp
  );
  if ($sth->execute()) {
   while(my ($id,$pusername,$phub,$ptitle,$ptags,$pdate,$ptext_html_cut,$pcut,$lastchanged,$pviews,$pcomments,$pstate) = $sth -> fetchrow_array) {
    my $phub_url;
    if ($phub) {
      $phub_url = '/blog/hub/'.$phub.'/1';
    }
    if (!$pviews) {
      $pviews='&nbsp;0';
    }
    my $post_url = '/blog/post/'.$id;
    my $read_more_url;
    if ($pcut) {
      $read_more_url = $post_url;
    }    
    $ptags =~ s/[^\w\n ,]//g;
    my @tags = split(/,/, $ptags);
    if ($hub_data{$phub}) {
      $phub = $hub_data{$phub};
    }
    $ptags='';
    foreach my $tag (@tags) {
      $tag=~s/^ //; 
      #tags!!!   
      my $tagurl = uri_encode($tag);
      $tagurl=~s/%/_/gm;
      $ptags.=', <a href="/blog/tag/'.$tagurl.'/1">'.$tag.'</a>';
    }
    $ptags=~s/, //;
    my $item_template = template 'blog_feed', { post_title => $ptitle, blog_hub => $phub, blog_hub_url => $phub_url, blog_text_cut => $ptext_html_cut, blog_user => $pusername, blog_views => $pviews, blog_tags => $ptags, blog_comments => $pcomments, blog_read_more => $read_more_url, blog_post_url => $post_url, read_more => $lang->{read_more} }, { layout => undef };
    $flow .= $item_template;    
   }
  }
  $sth->finish();  
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

get '/hub/:hub/:page' => sub {  
  my $bpage = int(params->{page}) || 1;
  my $bhub = params->{hub};
  $bhub =~ s/[^\w\n,]//g;
  if ($bpage<1 || !$bhub) {
    pass();
  }
  my $render_template = &flow($bpage, $bhub);
  if ($render_template) {
    return $render_template;
  }
  pass();
};

get '/tag/:tag/:page' => sub {  
  my $bpage = int(params->{page}) || 1;
  my $btag = params->{tag};
  $btag=~s/_/%/gm;
  $btag = decode_utf8(uri_decode($btag));
  $btag =~ s/[^\w\nА-Яа-я ]//g;
  if ($bpage<1 || !$btag) {
    pass();
  }
  my $render_template = &flow($bpage, undef, $btag);
  if ($render_template) {
    return $render_template;
  }
  pass();
};

get '/post/:post_id' => sub {
  my $post_id = params->{post_id};  
  $post_id=~s/[^0-9]+//gm; 
  if (!$post_id) {
    pass();
  }
  my $auth = &taracot::_auth();
  my $_current_lang=_load_lang();   
  my $item_template;
  my $page_data= &taracot::_load_settings('site_title,keywords,description,blog_hubs', $_current_lang);
  my %hub_data;
  if ($page_data->{blog_hubs}) {
    foreach my $item (split(/;/, $page_data->{blog_hubs})) {
      my ($par,$val) = split(/,/, $item);
      $par =~ s/^\s+//;
      $par =~ s/\s+$//;
      $val =~ s/^\s+//;
      $val =~ s/\s+$//;
      $hub_data{$par}=$val;
    }
  }
  my $sth = database->prepare(
   'SELECT id,pusername,phub,ptitle,ptags,pdate,ptext_html,lastchanged,pviews,pstate FROM '.config->{db_table_prefix}.'_blog_posts WHERE id = '.$post_id.' ORDER BY pdate DESC'
  );  
  if ($sth->execute()) {
   my ($id,$pusername,$phub,$ptitle,$ptags,$pdate,$ptext_html,$lastchanged,$pviews,$pstate) = $sth -> fetchrow_array();   
   if ($pstate eq 2 && !$auth->{id}) {
    $sth->finish(); 
    &taracot::_load_settings('site_title,keywords,description', $_current_lang);    
    return &taracot::_process_template( template 'blog_error', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'blog.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{module_name}, errmsg => $lang->{error_unauth}, auth_data => $auth  }, { layout => config->{layout}.'_'.$_current_lang } )
   }
   if ($pstate eq 0 && $auth->{status} ne 2) {
    $sth->finish(); 
    &taracot::_load_settings('site_title,keywords,description', $_current_lang);    
    return &taracot::_process_template( template 'blog_error', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'blog.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{module_name}, errmsg => $lang->{error_draft}, auth_data => $auth  }, { layout => config->{layout}.'_'.$_current_lang } )
   }
   my $phub_url;
   if ($phub) {
     $phub_url = '/blog/hub/'.$phub.'/1';
   }
   if (!$pviews) {
     $pviews='&nbsp;0';
   }    
   if ($hub_data{$phub}) {
    $phub = $hub_data{$phub};
   }   
   $ptags =~ s/[^\w\n ,]//g;
    my @tags = split(/,/, $ptags);
    $ptags='';
    foreach my $tag (@tags) {
      $tag=~s/^ //;   
      #tags!!!   
      my $tagurl = uri_encode(substr($tag,1,20));   
      $tagurl=~s/%/_/gm;
      $ptags.=', <a href="/blog/tag/'.$tagurl.'/1">'.$tag.'</a>';
    }
  $ptags=~s/, //;
  my $comments_flow='';
  my $sth = database->prepare(
   'SELECT id,post_id,deleted,cusername,ctext,cdate,chash,level FROM '.config->{db_table_prefix}.'_blog_comments WHERE post_id='.$post_id.' ORDER BY left_key'
  );
  my $comments_count='0';
  if ($sth->execute()) {
    my %avatars;
    while (my ($id,$post_id,$deleted,$cusername,$ctext,$cdate,$chash,$level) = $sth->fetchrow_array) {      
      $comments_count++;
      $cdate = time2str($lang->{comment_date_template}, $cdate);
      $cdate =~ s/\\//gm;
      my $avatar = '/images/default_avatar.png';
      if ($avatars{$cusername}) {
        $avatar = $avatars{$cusername}
      } else {
        if (-e config->{files_dir}.'/avatars/'.$cusername.'.jpg') {
          $avatar = config->{files_url}.'/avatars/'.$cusername.'.jpg';
          $avatars{$cusername} = $avatar;
        } 
      }
      $comments_flow .= template 'blog_comment', { lang => $lang, auth => $auth, id => $id, post_id => $post_id, deleted => $deleted, username => $cusername, text => $ctext, ts => $cdate, level => $level, avatar => $avatar }, { layout => undef }
    }   
  }  
  $sth->finish();
  my $comments = template 'blog_comments', { lang => $lang, auth => $auth, post_id => $post_id, comments => $comments_flow, comments_count => $comments_count }, { layout => undef };
  $item_template = &taracot::_process_template( template 'blog_post', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'blog.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $ptitle.' | '.$lang->{module_name}, post_title => $ptitle, blog_hub => $phub, blog_hub_url => $phub_url, blog_text => $ptext_html, blog_user => $pusername, blog_views => $pviews, blog_tags => $ptags, auth_data => $auth, comments => $comments }, { layout => config->{layout}.'_'.$_current_lang } );
  }
  $sth->finish(); 
  $sth = database->prepare(
   'UPDATE '.config->{db_table_prefix}.'_blog_posts SET pviews=pviews+1 WHERE id = '.$post_id
  );
  $sth->execute();
  $sth->finish(); 
  if ($item_template) {
    return $item_template;
  }
  pass();
};

get '/post' => sub {
  my $auth = &taracot::_auth();
  my $_current_lang=_load_lang(); 
  my $page_data= &taracot::_load_settings('site_title,keywords,description,blog_hubs', $_current_lang);
  if (!$auth->{id}) {
    return &taracot::_process_template( template 'blog_error', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'blog.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{module_name}, auth_data => $auth, errmsg => $lang->{error_unauth_long} }, { layout => config->{layout}.'_'.$_current_lang } );
  }
  my %hub_data;
  if ($page_data->{blog_hubs}) {
    foreach my $item (split(/;/, $page_data->{blog_hubs})) {
      my ($par,$val) = split(/,/, $item);
      $par =~ s/^\s+//;
      $par =~ s/\s+$//;
      $val =~ s/^\s+//;
      $val =~ s/\s+$//;
      $hub_data{$par}=$val;
    }
  }
  my $edit_template = &taracot::_process_template( template 'blog_editpost', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'blog.css" rel="stylesheet" /><link href="'.config->{modules_css_url}.'wbbtheme.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{module_name}, auth_data => $auth, hub_data => \%hub_data }, { layout => config->{layout}.'_'.$_current_lang } );
  if ($edit_template) {
    return $edit_template;
  }
  pass();
};

get '/post/edit/:post_id' => sub {
  my $post_id = params->{post_id};  
  $post_id=~s/[^0-9]+//gm; 
  if (!$post_id) {
    pass();
  }
  my $auth = &taracot::_auth();
  my $_current_lang=_load_lang(); 
  my $page_data= &taracot::_load_settings('site_title,keywords,description,blog_hubs', $_current_lang);
  if (!$auth->{id}) {
    return &taracot::_process_template( template 'blog_error', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'blog.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{module_name}, auth_data => $auth, errmsg => $lang->{error_unauth_long} }, { layout => config->{layout}.'_'.$_current_lang } );
  }
  my $pst  = database->quick_select(config->{db_table_prefix}.'_blog_posts', { id => $post_id }); 
  if (!$pst->{id}) {
    pass();
  }
  if ($pst->{pusername} ne $auth->{username} && $auth->{status} < 2) {
    return &taracot::_process_template( template 'blog_error', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'blog.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{module_name}, auth_data => $auth, errmsg => $lang->{error_rights_long} }, { layout => config->{layout}.'_'.$_current_lang } );
  }
  my %hub_data;
  if ($page_data->{blog_hubs}) {
    foreach my $item (split(/;/, $page_data->{blog_hubs})) {
      my ($par,$val) = split(/,/, $item);
      $par =~ s/^\s+//;
      $par =~ s/\s+$//;
      $val =~ s/^\s+//;
      $val =~ s/\s+$//;
      $hub_data{$par}=$val;
    }
  }
  my $edit_template = &taracot::_process_template( template 'blog_editpost', { detect_lang => $detect_lang, head_html => '<link href="'.config->{modules_css_url}.'blog.css" rel="stylesheet" /><link href="'.config->{modules_css_url}.'wbbtheme.css" rel="stylesheet" />', lang => $lang, page_data => $page_data, pagetitle => $lang->{module_name}, auth_data => $auth, hub_data => \%hub_data, post => $pst, post_id => $post_id }, { layout => config->{layout}.'_'.$_current_lang } );
  if ($edit_template) {
    return $edit_template;
  }
  pass();
};

any '/post/load' => sub {
  my $post_id = params->{pid}; 
  my $auth = &taracot::_auth();
  my $json_xs = JSON::XS->new(); 
  my %res;
  if (!$auth->{id}) {
    $res{status}=0;     
    return $json_xs->encode(\%res); 
  }
  my $pst  = database->quick_select(config->{db_table_prefix}.'_blog_posts', { id => $post_id }); 
  if (!$pst->{id}) {
    $res{status}=0;     
    return $json_xs->encode(\%res); 
  }
  if ($pst->{pusername} ne $auth->{username} && $auth->{status} < 2) {
    $res{status}=0;     
    return $json_xs->encode(\%res); 
  }
  $pst->{ptext_html}='';
  $pst->{ptext_html_cut}='';
  $pst->{status} = 1;
  return $json_xs->encode($pst); 
};

post '/post/process' => sub {
  my $_current_lang=_load_lang();
  my @errors;
  my @fields;
  my $json_xs = JSON::XS->new(); 
  my %res;
  $res{status}=1;  
  my $auth = &taracot::_auth();
  # Not authorized?
  if (!$auth->{id}) {
    $res{status}=0; 
    push @errors, $lang->{error_unauth}; 
    $res{errors}=\@errors; 
    return $json_xs->encode(\%res);   
  }   
  # End if not authorized
  my $pid = int(params->{id}) || 0;
  # Post owner check
  if ($pid) {
    my $pst  = database->quick_select(config->{db_table_prefix}.'_blog_posts', { id => $pid }); 
    if (!$pst->{id}) {
      $res{status}=0; 
      push @errors, $lang->{error_pid}; 
      $res{errors}=\@errors; 
      return $json_xs->encode(\%res);    
    }
    if ($pst->{username} ne $auth->{username} && $auth->{status} ne 2) {
      $res{status}=0; 
      push @errors, $lang->{error_pid}; 
      $res{errors}=\@errors; 
      return $json_xs->encode(\%res);    
    }
  }
  # End: post owner check
  my $blog_title = params->{blog_title} || '';  
  $blog_title =~ s/[\<\>\\\/\"\']+//g;
  $blog_title =~ s/^\s+//;
  $blog_title =~ s/\s+$//;
  $blog_title =~ tr/ //s;
  if (!$blog_title || length($blog_title) > 250) {
    $res{status}=0; 
    push @errors, $lang->{error_title}; 
    push @fields, 'blog_title';    
  }
  my $blog_tags = params->{blog_tags} || '';
  my @tags = split(/,/, $blog_tags);
  $blog_tags = '';
  foreach my $item (@tags) {
    $item =~ s/^\s+//;
    $item =~ s/\s+$//;
    $item =~ tr/ //s;
    $item =~ s/[^\w\nА-Яа-я ]//g;
    if (length($item) > 0) {
      $blog_tags.=", $item";
    }
  }
  $blog_tags =~ s/, //;
  if (!$blog_tags || length($blog_tags) > 250) {
    $res{status}=0; 
    push @errors, $lang->{error_tags}; 
    push @fields, 'blog_tags';
  }
  my $blog_hub = params->{blog_hub} || '';
  my $page_data= &taracot::_load_settings('site_title,keywords,description,blog_hubs', $_current_lang);
  my %hub_data;
  if ($page_data->{blog_hubs}) {
    foreach my $item (split(/;/, $page_data->{blog_hubs})) {
      my ($par,$val) = split(/,/, $item);
      $par =~ s/^\s+//;
      $par =~ s/\s+$//;
      $val =~ s/^\s+//;
      $val =~ s/\s+$//;
      $hub_data{$par}=$val;
    }
  }
  if (!$hub_data{$blog_hub}) {
    $res{status}=0; 
    push @errors, $lang->{error_hub}; 
    push @fields, 'blog_hub';    
  }
  my $blog_state = int(params->{blog_state}) || 0;
  if ($blog_state < 0 || $blog_state > 2) {
    $res{status}=0; 
    push @errors, $lang->{error_state}; 
    push @fields, 'blog_state';    
  }
  # Errors? return
  if (!$res{status}) {
    $res{errors}=\@errors;
    $res{fields}=\@fields;     
    return $json_xs->encode(\%res);  
  }  
  # End if errors  
  my $blog_data = params->{blog_data} || '';    
  my $blog_data_html_cut = $blog_data;
  my $cut = 0;
  if ($blog_data_html_cut=~/\[cut\]/i) {
    ($blog_data_html_cut) = split(/\[cut\]/i, $blog_data);
    $cut=1;
  }
  my $aubbc = taracot::AUBBC->new();
  $aubbc->add_build_tag(
        name     => 's',
        pattern  => 'l',
        type     => 3,
        function => 'modules::blog::main::get_tag',
  );
  my $blog_data_html = $aubbc->do_all_ubbc($blog_data);
  $blog_data_html =~s/\[cut\]/ /igm;
  $blog_data_html_cut = $aubbc->do_all_ubbc($blog_data_html_cut);
  $blog_data =~ s/\</&lt;/gm;
  $blog_data =~ s/\>/&gt;/gm;
  my $remote_ip = $ENV{'HTTP_X_REAL_IP'};
  if (!$remote_ip) {
    $remote_ip = $ENV{REMOTE_ADDR} || $ENV{REMOTE_HOST} || 'unknown';
  }
  if ($pid) {
    database->quick_update(config->{db_table_prefix}.'_blog_posts', { id => $pid }, { phub => $blog_hub, ptitle => $blog_title, ptags => $blog_tags, ptext => $blog_data, ptext_html => $blog_data_html, pcut => $cut, ptext_html_cut => $blog_data_html_cut,  pstate => $blog_state, lastchanged => time, ipaddr => $remote_ip }); 
  } else {
    database->quick_insert(config->{db_table_prefix}.'_blog_posts', { pusername => $auth->{username}, phub => $blog_hub, ptitle => $blog_title, pdate => time, ptags => $blog_tags, ptext => $blog_data, ptext_html => $blog_data_html, pcut => $cut, ptext_html_cut => $blog_data_html_cut, pviews => 0, plang => $_current_lang, pstate => $blog_state, lastchanged => time, ipaddr => $remote_ip }); 
      $pid = database->{q{mysql_insertid}};
  }
  if ($pid) {    
    $res{pid}=$pid; 
    return $json_xs->encode(\%res); 
  } else {
    $res{status}=0;     
    push @errors, $lang->{error_db}; 
    $res{errors}=\@errors;
    return $json_xs->encode(\%res); 
  }
  pass();
};

# Comment-related subroutines

post '/comment/put' => sub {
  my $_current_lang=_load_lang();
  my $auth = &taracot::_auth();
  my %res;
  my $json_xs = JSON::XS->new(); 
  if (!$auth->{id}) {
    $res{'status'} = 0;
    $res{'errmsg'} = $lang->{comment_error_unauth};
    return $json_xs->encode(\%res); 
  }
  my $ctext = params->{ctext} || '';
  my $cpid = int(params->{cpid}) || 0;
  my $cmid = int(params->{cmid}) || 0;
  $ctext =~ s/\&/&amp;/gm;
  $ctext =~ s/\</&lt;/gm;
  $ctext =~ s/\>/&gt;/gm;
  $ctext =~ s/\"/&quot;/gm;
  $ctext =~ s/[\n\r]//gm;
  if ($cpid < 0) {
    $cpid = undef;
  }
  if ($cmid < 0) {
    $cmid = 0;
  }  
  if (!$ctext || !$cpid) {
    $res{'status'} = 0;
    $res{'errmsg'} = $lang->{comment_error_mandatory};
    return $json_xs->encode(\%res); 
  }
  my $chash = md5_hex($ctext);
  # Find duplicates
  my $hash_dupe  = database->quick_select(config->{db_table_prefix}.'_blog_comments', { post_id => $cpid, chash => $chash, cusername => $auth->{username} });
  if ($hash_dupe->{id}) {
    $res{'status'} = 0;
    $res{'errmsg'} = $lang->{comment_error_dupe};
    return $json_xs->encode(\%res);   
  }
  # User posted a comment less than 10 seconds ago?
  my $last_post = 0;
  my $sth = database->prepare(
   'SELECT cdate FROM '.config->{db_table_prefix}.'_blog_comments WHERE cusername='.database->quote($auth->{username}).' ORDER BY cdate DESC'
  );
  if ($sth->execute()) {
   ($last_post) = $sth -> fetchrow_array;
  }
  $sth->finish();
  if ($last_post && time-$last_post < 10) {
    $res{'status'} = 0;
    $res{'errmsg'} = $lang->{comment_error_time};
    return $json_xs->encode(\%res);   
  }
  # Get comment count
  my $comments_count=0;
  $sth = database->prepare(
   'SELECT COUNT(*) AS cnt FROM '.config->{db_table_prefix}.'_blog_comments WHERE post_id='.$cpid
  );
  if ($sth->execute()) {
   ($comments_count) = $sth -> fetchrow_array;
  }
  $sth->finish();
  my $left_key = 0;
  my $right_key = 0;
  my $level = 0;
  my $deleted = 0;
  if ($cmid) {
    my $sth = database->prepare(
     'SELECT left_key, right_key, level, deleted FROM '.config->{db_table_prefix}.'_blog_comments WHERE id='.$cmid.' AND post_id='.$cpid
    );
    if ($sth->execute()) {
     ($left_key, $right_key, $level, $deleted) = $sth -> fetchrow_array;     
    }  
    $sth->finish();
  } else {
    my $sth = database->prepare(
     'SELECT left_key, right_key FROM '.config->{db_table_prefix}.'_blog_comments WHERE post_id='.$cpid.' ORDER BY right_key DESC LIMIT 1'
    );
    if ($sth->execute()) {
     ($left_key, $right_key) = $sth -> fetchrow_array;
     $right_key++;
    }  
    $sth->finish();
  }
  if ((!$right_key && $comments_count) || $deleted) {
    $res{'status'} = 0;
    return $json_xs->encode(\%res); 
  }
  # Find last child ID
  my $last_child_id = 0;
  if ($left_key && $right_key) {
    $sth = database->prepare(
      'SELECT id FROM '.config->{db_table_prefix}.'_blog_comments WHERE left_key >= '.$left_key.' AND right_key <= '.$right_key.' AND post_id='.$cpid.' ORDER BY left_key DESC'
    );
    if ($sth->execute()) {
     ($last_child_id) = $sth -> fetchrow_array;
    }  
    $sth->finish();
  }
  # Update 1
  $sth = database->prepare(
   'UPDATE '.config->{db_table_prefix}.'_blog_comments SET left_key = left_key + 2, right_key = right_key + 2 WHERE left_key > '.$right_key.' AND post_id='.$cpid
  );  
  $sth->execute();
  $sth->finish();
  # Update 2
  $sth = database->prepare(
   'UPDATE '.config->{db_table_prefix}.'_blog_comments SET right_key = right_key + 2 WHERE right_key >= '.$right_key.' AND left_key < '.$right_key.' AND post_id='.$cpid
  );  
  $sth->execute();
  $sth->finish();  
  # Get remote IP
  my $remote_ip = $ENV{'HTTP_X_REAL_IP'};
  if (!$remote_ip) {
    $remote_ip = $ENV{REMOTE_ADDR} || $ENV{REMOTE_HOST} || 'unknown';
  }  
  # Insert  
  $sth = database->prepare(
   'INSERT INTO '.config->{db_table_prefix}.'_blog_comments SET left_key = '.$right_key.', right_key = '.($right_key+1).', level = '.($level+1).', cusername='.database->quote($auth->{username}).', deleted=0, post_id='.$cpid.', ctext='.database->quote($ctext).', chash='.database->quote($chash).', cdate='.time.', ipaddr='.database->quote($remote_ip)
  );
  $sth->execute();
  $sth->finish();
  my $cid = database->{q{mysql_insertid}};
  # Check
  $sth = database->prepare(
   'UPDATE '.config->{db_table_prefix}.'_blog_comments SET right_key = right_key + 2, left_key = IF(left_key > '.$right_key.', left_key + 2, left_key) WHERE right_key >= '.$right_key.' AND post_id='.$cpid
  ); 
  $sth->execute();
  $sth->finish();  
  # Update comment count
  $sth = database->prepare(
   'UPDATE '.config->{db_table_prefix}.'_blog_posts SET pcomments = pcomments + 1 WHERE id='.$cpid
  );  
  $sth->execute();
  $sth->finish();
  # Return data
  $res{'status'} = 1;
  my $cdate = time2str($lang->{comment_date_template}, time);
  $cdate =~ s/\\//gm;
  my $avatar = '/images/default_avatar.png';
  if (-e config->{files_dir}.'/avatars/'.$auth->{username}.'.jpg') {
    $avatar = config->{files_url}.'/avatars/'.$auth->{username}.'.jpg';    
  } 
  $res{last_child_id} = $last_child_id;
  $res{comments_count} = $comments_count+1;
  $res{html} = template 'blog_comment', { lang => $lang, auth => $auth, id => $cid, post_id => $cpid, deleted => 0, username => $auth->{username}, text => $ctext, ts => $cdate, level => $level+1, avatar => $avatar  }, { layout => undef };
  return $json_xs->encode(\%res); 
};

# Comment-related subroutines: end

# End

true;