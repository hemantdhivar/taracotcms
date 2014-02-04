var social_search_page = 1;
var social_friends_page = 1;
var social_invitations_page = 1;

var social_update_counters = function() {
  if (friends_count > 0) {
    $('#social_friends_count').html(friends_count)
  } else {
    $('#social_friends_count').hide();
  }

  if (invitations_count > 0) {
    $('#social_invitations_count').html(invitations_count)
  } else {
    $('#social_invitations_count').hide();
  }

  if (messages_count > 0) {
    $('#social_messages_count').html(messages_count)
  } else {
    $('#social_messages_count').hide();
  }
};

social_update_counters();

$('.social_menu').click(function() {
	$('.social_menu').removeClass('active');
	$(this).addClass('active');
});


$('.social_menu').click(function() {
	$('.social_menu').removeClass('active');
	$(this).addClass('active');
	social_search_page = -1;
  social_friends_page = -1;
  social_invitations_page = -1;
});


$('#social_menu_page').click(function() {
	$('.social_tab').hide();
	$('#social_tab_page').show();
});


$('#social_menu_search').click(function() {  
	$('.social_tab').hide();
	$('#social_tab_search').show();
	$('#social_search_input').val('');
	$('#social_search_input').focus();
	$('#social_search_results').empty();  
});


var ajax_load_search_data = function(query, page) {
	$('#social_search_ajax').show();
	$.ajax({
        type: 'POST',
        url: '/social/search',
        data: {
            search_query: query,
            page: page
        },
        dataType: "json",
        success: function (data) {
        	$('#social_search_ajax').hide();
            if (data.status == 1) {    
            	if (data.total == 0) {
            		$('#social_search_results').html('<div class="alert alert-warning">'+js_lang_search_nothing_found+'</div>');
            	}
                if (data.items && data.items.length > 0) {
                	$('#social_search_results').append('<div class="row" style="padding-top:20px">');
                    for (var i = 0; i < data.items.length; i++) {
                       var h1t = '';
                       var h2t = '';
                       if (data.items[i].realname) {
                       	h1t = data.items[i].realname + '&nbsp;<small>'+data.items[i].username+'</small>';
                       } else {
                       	h21 = data.items[i].username;
                       }
                       if (data.items[i].phone) {
                         if (h2t) {
                           h2t += '<br>';
                         }
                         h2t += '<span><i class="glyphicon glyphicon-earphone" style="font-size:80%"></i>&nbsp;+' + data.items[i].phone + '</span>';
                       } else {
  						           if (h2t) {
                         	 h2t += '<br>';
                         }
                         h2t += js_lang_no_phone;
                       }
                       $('#social_search_results').append('<div class="col-lg-6 col-md-12 col-sm-12 col-xs-12 social-search-item" id="social_search_item_' + data.items[i].id + '"><div class="media social-search-media" style="margin:5px 0 5px 0"><span class="pull-left"><img class="media-object" src="'+data.items[i].avatar+'" alt="'+h1t+'" style="width:50px"></span><div class="media-body"><h4 class="media-heading">'+h1t+'</h4>'+h2t+'</div></div></div>');
                    }
                    $('#social_search_results').append('</div>');
                    $('.social-search-item').unbind();
                    $('.social-search-item').click(social_search_click_event);
                }
                if (social_search_page == 1) {
                	$("html, body").animate({ scrollTop: 0 }, "slow");
                }
                if (social_search_page > data.pages) {
                	social_search_page = -1;
                }
            } else {
                $('#social_search_results').html('<div class="alert alert-danger">'+js_lang_search_error+'</div>');
            }
        },
        error: function () {
        	$('#social_search_ajax').hide();
            $('#social_search_results').html('<div class="alert alert-danger">'+js_lang_search_error+'</div>');
        }
    });
};


var ajax_load_friends_data = function(page) {
  $('#social_friends_ajax').show();
  $.ajax({
        type: 'POST',
        url: '/social/friends',
        data: {
            page: page
        },
        dataType: "json",
        success: function (data) {
          $('#social_friends_ajax').hide();
            if (data.status == 1) {    
              if (data.total == 0) {
                $('#social_friends_results').html('<div class="alert alert-warning">'+js_lang_friends_nothing_found+'</div>');
              }
                if (data.items && data.items.length > 0) {
                  $('#social_friends_results').append('<div class="row">');
                    for (var i = 0; i < data.items.length; i++) {
                       var h1t = '';
                       var h2t = '';
                       if (data.items[i].realname) {
                        h1t = data.items[i].realname + '&nbsp;<small>'+data.items[i].username+'</small>';
                       } else {
                        h21 = data.items[i].username;
                       }
                       if (data.items[i].phone) {
                         if (h2t) {
                           h2t += '<br>';
                         }
                         h2t += '<span><i class="glyphicon glyphicon-earphone" style="font-size:80%"></i>&nbsp;+' + data.items[i].phone + '</span>';
                       } else {
                         if (h2t) {
                           h2t += '<br>';
                         }
                         h2t += js_lang_no_phone;
                       }
                       $('#social_friends_results').append('<div class="col-lg-6 col-md-12 col-sm-12 col-xs-12 social-search-item" id="social_search_item_' + data.items[i].id + '"><div class="media social-search-media" style="margin:5px 0 5px 0"><span class="pull-left"><img class="media-object" src="'+data.items[i].avatar+'" alt="'+h1t+'" style="width:50px"></span><div class="media-body"><h4 class="media-heading">'+h1t+'</h4>'+h2t+'</div></div></div>');
                    }
                    $('#social_friends_results').append('</div>');
                    $('.social-search-item').unbind();
                    $('.social-search-item').click(social_search_click_event);
                }
                if (social_friends_page == 1) {
                  $("html, body").animate({ scrollTop: 0 }, "slow");
                }
                if (social_friends_page > data.pages) {
                  social_friends_page = -1;
                }
            } else {
                $('#social_friends_results').html('<div class="alert alert-danger">'+js_lang_loading_error+'</div>');
            }
        },
        error: function () {
          $('#social_friends_ajax').hide();
            $('#social_friends_results').html('<div class="alert alert-danger">'+js_lang_loading_error+'</div>');
        }
    });
};


var ajax_load_invitations_data = function(page) {
  $('#social_invitations_ajax').show();
  $.ajax({
        type: 'POST',
        url: '/social/friends',
        data: {
            invitations: 'true',
            page: page
        },
        dataType: "json",
        success: function (data) {
          $('#social_invitations_ajax').hide();
            if (data.status == 1) {    
              if (data.total == 0) {
                $('#social_invitations_results').html('<div class="alert alert-warning">'+js_lang_invitations_nothing_found+'</div>');
              }
                if (data.items && data.items.length > 0) {
                  $('#social_invitations_results').append('<div class="row">');
                    for (var i = 0; i < data.items.length; i++) {
                       var h1t = '';
                       var h2t = '';
                       if (data.items[i].realname) {
                        h1t = data.items[i].realname + '&nbsp;<small>'+data.items[i].username+'</small>';
                       } else {
                        h21 = data.items[i].username;
                       }
                       if (data.items[i].phone) {
                         if (h2t) {
                           h2t += '<br>';
                         }
                         h2t += '<span><i class="glyphicon glyphicon-earphone" style="font-size:80%"></i>&nbsp;+' + data.items[i].phone + '</span>';
                       } else {
                         if (h2t) {
                           h2t += '<br>';
                         }
                         h2t += js_lang_no_phone;
                       }
                       $('#social_invitations_results').append('<div class="col-lg-6 col-md-12 col-sm-12 col-xs-12 social-search-item" id="social_search_item_' + data.items[i].id + '"><div class="media social-search-media" style="margin:5px 0 5px 0"><span class="pull-left"><img class="media-object" src="'+data.items[i].avatar+'" alt="'+h1t+'" style="width:50px"></span><div class="media-body"><h4 class="media-heading">'+h1t+'</h4>'+h2t+'</div></div></div>');
                    }
                    $('#social_invitations_results').append('</div>');
                    $('.social-search-item').unbind();
                    $('.social-search-item').click(social_search_click_event);
                }
                if (social_invitations_page == 1) {
                  $("html, body").animate({ scrollTop: 0 }, "slow");
                }
                if (social_invitations_page > data.pages) {
                  social_invitations_page = -1;
                }
            } else {
                $('#social_invitations_results').html('<div class="alert alert-danger">'+js_lang_loading_error+'</div>');
            }
        },
        error: function () {
          $('#social_invitations_ajax').hide();
            $('#social_invitations_results').html('<div class="alert alert-danger">'+js_lang_loading_error+'</div>');
        }
    });
};


$('#social_search_btn').click(function () {		
	$('#social_search_results').empty();
	social_search_page = 1;
	$('#social_cg_search').removeClass('has-error');
	if ($('#social_search_input').val().length < 3 && $('#social_search_input').val().length > 0) {
		$('#social_cg_search').addClass('has-error');
		return;
	}
  ajax_load_search_data($('#social_search_input').val(), 1);
  $.history.push("view=search&query=" + $('#social_search_input').val() );
});


$(window).scroll(function() {
   if($(window).scrollTop() + $(window).height() > $(document).height() - 100) {
       if (social_search_page > 0) {
         social_search_page++;
         ajax_load_search_data($('#social_search_input').val(), social_search_page);
       }
       if (social_friends_page > 0) {
         social_friends_page++;
         ajax_load_friends_data(social_friends_page);
       }
       if (social_invitations_page > 0) {
         social_invitations_page++;
         ajax_load_invitatoins_data(social_invitations_page);
       }
   }
});

var json_send_friendship_request = function() {
 var id = jQuery(this).attr("id");
 uid = id.replace('btn_add_friend_','');
 if ($('#btn_add_friend_' + uid).hasClass('disabled')) {
  return;
 }
 $('#btn_add_friend_' + uid).addClass('disabled');
 $('#prg_add_friend_' + uid).show();
 $.ajax({
        type: 'POST',
        url: '/social/friend/request',
        data: {
            id: uid
        },
        dataType: "json",
        success: function (data) {
          $('#prg_add_friend_' + uid).hide();
          if (data.status == 0) {
            $('#btn_add_friend_' + uid).removeClass('disabled');
            $('#btn_add_friend_' + uid).popover('destroy');
            if (data.msg && data.msg.length > 0) {
              $('#btn_add_friend_' + uid).popover({trigger:'manual',placement:'right',content:data.msg}); 
            } else {
              $('#btn_add_friend_' + uid).popover({trigger:'manual',placement:'right',content:js_lang_ajax_error}); 
            }
            $('#btn_add_friend_' + uid).popover('show');
            $('#prg_add_friend_' + uid).hide();  
          } else {
            $('#btn_add_friend_' + uid).replaceWith('<div class="label label-warning" style="font-size:100%;font-weight:normal">' + js_lang_friend_status_request_sent + '</div>');
          }
        },
        error: function () {
          $('#btn_add_friend_' + uid).removeClass('disabled');
          $('#btn_add_friend_' + uid).popover('destroy');
          $('#btn_add_friend_' + uid).popover({trigger:'manual',placement:'right',content:js_lang_ajax_error}); 
          $('#btn_add_friend_' + uid).popover('show');
          $('#prg_add_friend_' + uid).hide();
        }
    });
};


var json_accept_friendship_request = function() {
 var id = jQuery(this).attr("id");
 uid = id.replace('btn_accept_friend_','');
 if ($('#btn_accept_friend_' + uid).hasClass('disabled')) {
  return;
 }
 $('#btn_accept_friend_' + uid).addClass('disabled');
 $('#prg_accept_friend_' + uid).show();
 $.ajax({
        type: 'POST',
        url: '/social/friend/accept',
        data: {
            id: uid
        },
        dataType: "json",
        success: function (data) {
          $('#prg_accept_friend_' + uid).hide();
          if (data.status == 0) {
            $('#btn_accept_friend_' + uid).removeClass('disabled');
            $('#btn_accept_friend_' + uid).popover('destroy');
            if (data.msg && data.msg.length > 0) {
              $('#btn_accept_friend_' + uid).popover({trigger:'manual',placement:'right',content:data.msg}); 
            } else {
              $('#btn_accept_friend_' + uid).popover({trigger:'manual',placement:'right',content:js_lang_ajax_error}); 
            }
            $('#btn_accept_friend_' + uid).popover('show');
            $('#prg_accept_friend_' + uid).hide();  
          } else {
            $('#btn_accept_friend_' + uid).replaceWith('<div class="label label-primary" style="font-size:100%;font-weight:normal">' + js_lang_friend_status_established + '</div>');
            friends_count++;
            social_update_counters();
          }
        },
        error: function () {
          $('#btn_accept_friend_' + uid).removeClass('disabled');
          $('#btn_accept_friend_' + uid).popover('destroy');
          $('#btn_accept_friend_' + uid).popover({trigger:'manual',placement:'right',content:js_lang_ajax_error}); 
          $('#btn_accept_friend_' + uid).popover('show');
          $('#prg_accept_friend_' + uid).hide();
        }
    });
};


var json_render_user_data = function(data, uid, where) {
  $(where).append('<h1 class="social_page_header">' + data.realname + '<img src="' + data.avatar +'" class="pull-right" alt="' + data.realname + '"></h1>');
  if (uid != current_user_id) {
    if (data.friendship_status == 0) {
      if (data.friendship_details && data.friendship_details.length > 0) {        
        if (data.friendship_unaccepted) {
          $(where).append('&nbsp;&nbsp;<button class="btn btn-sm btn-success btn-social-accept_friend" id="btn_accept_friend_' + uid + '"><i class="glyphicon glyphicon-plus"></i>&nbsp;' + js_lang_friend_accept_request + '</button>&nbsp;&nbsp;<img src="/images/white_loading.gif" style="width:16px;height:16px;display:none" id="prg_accept_friend_' + uid + '">');
          $('.btn-social-accept_friend').unbind();
          $('.btn-social-accept_friend').click(json_accept_friendship_request);
        } else {
          $(where).append('<span class="label label-warning" style="font-size:100%;font-weight:normal">' + data.friendship_details + '</span>');
        }
      } else {
        $(where).append('<button class="btn btn-sm btn-success btn-social-add_friend" id="btn_add_friend_' + uid + '"><i class="glyphicon glyphicon-plus"></i>&nbsp;' + js_lang_add_friend + '</button>&nbsp;&nbsp;<img src="/images/white_loading.gif" style="width:16px;height:16px;display:none" id="prg_add_friend_' + uid + '">');
        $('.btn-social-add_friend').unbind();
        $('.btn-social-add_friend').click(json_send_friendship_request);
      }      
    } else {
      $(where).append('<div class="label label-primary" style="font-size:100%;font-weight:normal">' + js_lang_friend_status_established + '</div>');      
    }
  }
};


var ajax_load_user_data = function(uid) {
	$('#social_page_ajax').show();
	$('#social_page_results').empty();
	$.ajax({
        type: 'POST',
        url: '/social/user',
        data: {
            id: uid
        },
        dataType: "json",
        success: function (data) {
        	$('#social_page_ajax').hide();
            if (data.status == 1) {    
              json_render_user_data(data, uid, '#social_page_results');
            } else {
              $('#social_page_results').html('<div class="alert alert-danger">'+js_lang_page_error+'</div>');
            }
        },
        error: function () {
        	$('#social_page_ajax').hide();
            $('#social_page_results').html('<div class="alert alert-danger">'+js_lang_page_error+'</div>');
        }
    });
};


var social_search_click_event = function(uid) {
	var id = jQuery(this).attr("id");
	if (id) {
    id = id.replace('social_search_item_','');	
  } else {
    id = uid;
  }
	$('.social_menu').removeClass('active');
	$('.social_tab').hide();
	social_search_page = -1;
	$('#social_tab_page').show();
  $.history.push("view=page&id=" + id );
  $('#social_page_results').show();
  $('#social_page_user').hide();
	ajax_load_user_data(id);	
};
$('.social_menu_link').click(function(e) {
  $.history.push($(this).attr('href'));
  e.preventDefault();
});

// Render user page

json_render_user_data(user_data, current_user_id, '#social_page_user');

// History API

$.history.on('load change', function(event, url, type) {
  var items = url.split('&');
  var ph = $.unparam(url);  
  if (ph['view'] == 'search_results') {
    $('.social_tab').hide();    
    $('#social_tab_search').show();
    return;
  }
  social_search_page = -1;
  social_friends_page = -1;
  social_invitations_page = -1;
  if (ph['view'] == 'page' || ph['view'] == '') {
    $('.social_menu').removeClass('active');
    $('.social_tab').hide();
    $('#social_tab_page').show();    
    if (ph['id'] && ph['id'].length > 0) {
      $('#social_page_results').show();
      $('#social_page_user').hide();
      ajax_load_user_data(ph['id']);
    } else {
      $('#social_menu_page_li').addClass('active');
      $('#social_page_results').hide();
      $('#social_page_user').show();
    }
    return;
  }
  if (ph['view'] == 'friends') {
    $('.social_menu').removeClass('active');
    $('.social_tab').hide();
    $('#social_tab_friends').show();
    $('#social_menu_friends_li').addClass('active');
    $('#social_friends_results').empty();
    social_friends_page = 1;
    ajax_load_friends_data(1);
    return;
  }
  if (ph['view'] == 'search') {
    $('.social_menu').removeClass('active');
    $('.social_tab').hide();
    $('#social_tab_search').show();
    $('#social_search_results').empty();
    $('#social_menu_search_li').addClass('active');
    if (ph['query'] && ph['query'].length > 0) {
      $('#social_search_input').val(ph['query']);
      $('#social_search_btn').click();      
    }    
    $('#social_search_input').focus();
    return;
  }
  if (ph['view'] == 'invitations') {
    $('.social_menu').removeClass('active');
    $('.social_tab').hide();
    $('#social_tab_invitations').show();
    $('#social_menu_invitations_li').addClass('active');
    $('#social_invitations_results').empty();
    social_invitations_page = 1;
    ajax_load_invitations_data(1);
    return;
  }
  if (ph['view'] == 'messaging') {
    $('.social_menu').removeClass('active');
    $('.social_tab').hide();
    $('#social_tab_messaging').show();
    $('#social_menu_messaging_li').addClass('active');
    return;
  }
  if (ph['view'] == 'settings') {
    $('.social_menu').removeClass('active');
    $('.social_tab').hide();
    $('#social_tab_settings').show();
    $('#social_menu_settings_li').addClass('active');
    return;
  }  
}).listen('hash');