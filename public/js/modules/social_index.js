var social_search_page = 1;
var social_friends_page = 1;
var social_invitations_page = 1;
var social_message_uid = undefined;
var sent_message_ids = [];
var social_friends_id = undefined;

socket = io.connect("http://ns.ahu.li");
socket.on( 'connect', function() {
  socket.emit('set_session_id', {"session": session_id});
});
socket.on('got_update', function (data) {
  var pl = $.unparam(document.URL.substr(document.URL.indexOf('#')+1));
  var up = $.parseJSON(data.update);    
  if (up) {
    // New message arrived
    if (up.reason && up.reason == "message") {      
      if (pl['view'] == "message" && up.uto && up.uto == pl['id'] && data.session == session_id && data.mid && jQuery.inArray("_"+data.mid, sent_message_ids) == -1) {
        $('#social_messaging_chat_inner').append('<div class="media"><span class="pull-left"><img class="media-object" style="width:50px;height:50px" src="' + up.avatar  + '"></span><span class="pull-right"><small>' +up.mtime  + '</small></span><div class="media-body"><b>' + up.username  + '</b><div style="height:3px"></div>' + up.msg  + '</div></div>');
        $("#social_messaging_chat").scrollTop($("#social_messaging_chat")[0].scrollHeight);
        sent_message_ids.push(data.mid);
      }
      if (pl['view'] == "message" && up.ufrom && up.ufrom == pl['id'] && !data.mid) {
        $('#social_messaging_chat_inner').append('<div class="media"><span class="pull-left"><img class="media-object" style="width:50px;height:50px" src="' + up.avatar  + '"></span><span class="pull-right"><small>' +up.mtime  + '</small></span><div class="media-body"><b>' + up.username  + '</b><div style="height:3px"></div>' + up.msg  + '</div></div>');
        $("#social_messaging_chat").scrollTop($("#social_messaging_chat")[0].scrollHeight);
        $.ajax({ type: 'POST', url: '/social/messages/read', data: { uid: up.ufrom }, dataType: "json" });
      }
      if (pl['view'] != "message") {
        messages_flag = 1;
        social_update_counters();
      }
      if (pl['view'] == "messaging") {
        ajax_load_talks_data();
      }
    }
    // New friendship request
    if (up.reason && up.reason == "friend_request" && !data.mid) {
      invitations_count++;
      social_update_counters();
      if (pl['view'] == "invitations") {                
        $('#social_invitations_results').empty();
        social_invitations_page = 1;
        ajax_load_invitations_data(1);
      }      
    }
    // Friendship request accepted
    if (up.reason && up.reason == "friend_request_accepted" && !data.mid) {      
      if (pl['view'] == "friends") {
        $('#social_friends_results').empty();
        social_friends_page = 1;
        if (pl['id'] && pl['id'].length > 0) {
          social_friends_id = pl['id'];
        } else {
          social_friends_id = undefined;
        }        
        $('#social_friends_results').empty();
        social_friends_page = 1;
        ajax_load_friends_data(1, social_friends_id);
      } else {
        friends_flag=1;
        social_update_counters();
      }
      if (up.id && pl['page'] == "page" && pl['id'] == up.id) {
        $('#social_page_results').show();
        $('#social_page_user').hide();
        ajax_load_user_data(ph['id']);  
      }
    }
  }
});
var timerId = setInterval(function() {
  if (socket.connected) {
    socket.emit('set_session_id', {"session": session_id}); 
  }
}, 30000)

var social_update_counters = function() {
  if (friends_flag == 1) {
    $('#social_friends_flag').show();
  } else {
    $('#social_friends_flag').hide();
  }
  if (invitations_count > 0) {
    $('#social_invitations_count').show();
    $('#social_invitations_count').html(invitations_count)
  } else {
    $('#social_invitations_count').hide();
  }
  if (messages_flag == 1) {
    $('#social_messages_flag').show();
  } else {
    $('#social_messages_flag').hide();
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
  if ($('#social_search_btn').hasClass('disabled')) {
    return;
  }
  $('#social_search_btn').addClass('disabled');
	$('#social_search_ajax').show();  
	$.ajax({
        type: 'POST',
        url: '/social/search',
        async: true,
        data: {
            search_query: query,
            page: page
        },
        dataType: "json",
        success: function (data) {
        	$('#social_search_ajax').hide();
            if (data.status == 1) {                  
              if (((!data.items) || (data.items && data.items.length == 0)) && social_search_page == 1) {
                $('#social_search_results').html('<div class="alert alert-warning">'+js_lang_search_nothing_found+'</div>');
              } else {
                  if (data.items.length > 0) {
                    	$('#social_search_results').append('<div class="row" style="padding-top:20px">');
                        for (var i = 0; i < data.items.length; i++) {
                           var h1t = '';
                           var h2t = '';
                           if (data.items[i].realname) {
                           	h1t = data.items[i].realname + '&nbsp;<small>'+data.items[i].username+'</small>';
                           } else {
                           	h1t = data.items[i].username;
                           }
                           if (data.items[i].phone) {                             
                             h2t += '<span><i class="glyphicon glyphicon-earphone" style="font-size:80%"></i>&nbsp;+' + data.items[i].phone + '</span>';
                           } else {      						           
                             h2t += js_lang_no_phone;
                           }
                           $('#social_search_results').append('<div class="social-search-item" id="social_search_item_' + data.items[i].id + '"><div class="media social-search-media" style="margin:5px 0 5px 0"><span class="pull-left"><img class="media-object" src="'+data.items[i].avatar+'" alt="'+h1t+'" style="width:50px"></span><div class="media-body"><h4 class="media-heading">'+h1t+'</h4>'+h2t+'</div></div></div>');
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
              }
            } else {
                $('#social_search_results').html('<div class="alert alert-danger">'+js_lang_search_error+'</div>');
            }
        },
        error: function () {
        	$('#social_search_ajax').hide();
            $('#social_search_results').html('<div class="alert alert-danger">'+js_lang_search_error+'</div>');
        },
        complete: function() {
          $('#social_search_btn').removeClass('disabled');
        }
    });
};


var ajax_load_friends_data = function(page, user) {
  $('#social_friends_ajax').show();
  $('#social_friends_header').html('');
  $.ajax({
        type: 'POST',
        url: '/social/friends',
        data: {
            page: page,
            uid: user
        },
        dataType: "json",
        success: function (data) {
          $('#social_friends_ajax').hide();
            if (data.status == 1) {    
              var _friends_title = js_lang_users_friends;
              if (user) {
                if (taracot_lang == 'en') {
                  _friends_title = data.name + "'s " + js_lang_users_friends;
                }
                if (taracot_lang == 'ru') {
                  var _sex = Petrovich.MALE;
                  if (data.sex == 1) {
                    _sex = Petrovich.FEMALE;
                  }
                  var _first = data.name.split(' ')[0];
                  var p = new Petrovich("", _first, "", _sex);
                  _friends_title = js_lang_users_friends + ' ' + p.firstName(Petrovich.GENITIVE);
                }
              }
              $('#social_friends_header').html(_friends_title);              
              if (((!data.items) || (data.items && data.items.length == 0)) && $('#social_friends_results').html().length == 0) {
                var _msg = js_lang_friends_nothing_found;
                if (user && user > 0) {
                  _msg = js_lang_friends_nothing_found_user;
                }
                $('#social_friends_results').html('<div class="alert alert-warning">'+_msg+'</div>');
              } else {
                if (data.items.length > 0) {                    
                    $('#social_friends_results').append('<div class="row">');
                      for (var i = 0; i < data.items.length; i++) {
                         var h1t = '';
                         var h2t = '';
                         if (data.items[i].realname) {
                          h1t = data.items[i].realname + '&nbsp;<small>'+data.items[i].username+'</small>';
                         } else {
                          h1t = data.items[i].username;
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
                         $('#social_friends_results').append('<div class="social-search-item" id="social_search_item_' + data.items[i].id + '"><div class="media social-search-media" style="margin:5px 0 5px 0"><span class="pull-left"><img class="media-object" src="'+data.items[i].avatar+'" alt="'+h1t+'" style="width:50px"></span><div class="media-body"><h4 class="media-heading">'+h1t+'</h4>'+h2t+'</div></div></div>');
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
              if (((!data.items) || (data.items && data.items.length == 0)) && $('#social_invitations_results').html().length == 0) {
                $('#social_invitations_results').html('<div class="alert alert-warning">'+js_lang_inv_nothing_found+'</div>');
              } else {
                if (data.items.length > 0) {
                  $('#social_invitations_results').append('<div class="row">');
                    for (var i = 0; i < data.items.length; i++) {
                       var h1t = '';
                       var h2t = '';
                       if (data.items[i].realname) {
                        h1t = data.items[i].realname + '&nbsp;<small>'+data.items[i].username+'</small>';
                       } else {
                        h1t = data.items[i].username;
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
                       $('#social_invitations_results').append('<div class="social-search-item" id="social_search_item_' + data.items[i].id + '"><div class="media social-search-media" style="margin:5px 0 5px 0"><span class="pull-left"><img class="media-object" src="'+data.items[i].avatar+'" alt="'+h1t+'" style="width:50px"></span><div class="media-body"><h4 class="media-heading">'+h1t+'</h4>'+h2t+'</div></div></div>');
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


$('#social_search_btn').click(function (e) {			
  e.preventDefault();
	$('#social_cg_search').removeClass('has-error');
	if ($('#social_search_input').val().length < 3 && $('#social_search_input').val().length > 0) {
		$('#social_cg_search').addClass('has-error');
		return;
	}  
  $('#social_search_results').empty();
  social_search_page = 1;
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
         ajax_load_friends_data(social_friends_page, social_friends_id);
       }
       if (social_invitations_page > 0) {
         social_invitations_page++;         
         ajax_load_invitations_data(social_invitations_page);
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
            $('#btn_add_friend_' + uid).replaceWith('');
            $('#social_page_friendship_status').html(js_lang_friend_status_request_sent);
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
            $('#social_page_friendship_status').html(js_lang_friend_status_established);
            $('#btn_accept_friend_' + uid).replaceWith('');
            friends_flag=1;
            invitations_count--;
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
  if (!data.realname) {
    data.realname = data.username;
  }
  $(where).append('<div class="row"><div class="col-lg-2 col-md-3 col-sm-3" style="width:100px"><img style="width:85px" src="' + data.avatar +'" alt="' + data.realname + '"></div><div class="col-lg-10 col-md-9 col-sm-9"><h1 class="social_page_header">' + data.realname + '&nbsp;<span id="social_page_friendship_status"></span></h1><div id="taracot_social_page_top_buttons"</div></div>');    
  var _s_lang_users_friends = js_lang_users_friends;
  if (taracot_lang == 'en') {
      _s_lang_users_friends = data.realname + "'s " + js_lang_users_friends;
  }
  if (taracot_lang == 'ru') {
      var _sex = Petrovich.MALE;
      if (data.sex == 1) {
        _sex = Petrovich.FEMALE;
      }
      var _first = data.realname.split(' ')[0];
      var p = new Petrovich("", _first, "", _sex);
      _s_lang_users_friends = js_lang_users_friends + ' ' + p.firstName(Petrovich.GENITIVE);
  }
  if (uid != current_user_id) {    
    $('#taracot_social_page_top_buttons').append('<button class="btn btn-default btn-sm btn-social-friends" id="btn_friends_' + uid + '"><i class="glyphicon glyphicon-user"></i>&nbsp;' + _s_lang_users_friends + '</button>&nbsp;');
    $('#taracot_social_page_top_buttons').append('&nbsp;<button class="btn btn-default btn-sm btn-social-message" id="btn_sendmessage_' + uid + '"><i class="glyphicon glyphicon-envelope"></i>&nbsp;' + js_lang_send_message + '</button>');
    if (data.friendship_status == 0) {
      if (data.friendship_details && data.friendship_details.length > 0) {        
        if (data.friendship_unaccepted) {
          $('#taracot_social_page_top_buttons').append('&nbsp;&nbsp;<button class="btn btn-sm btn-success btn-social-accept_friend" id="btn_accept_friend_' + uid + '"><i class="glyphicon glyphicon-plus"></i>&nbsp;' + js_lang_friend_accept_request + '</button>&nbsp;&nbsp;<img src="/images/white_loading.gif" style="width:16px;height:16px;display:none" id="prg_accept_friend_' + uid + '">');
          $('.btn-social-accept_friend').unbind();
          $('.btn-social-accept_friend').click(json_accept_friendship_request);
        } else {
          //$('#taracot_social_page_top_buttons').append('<button class="btn btn-warning btn-sm disabled">' + data.friendship_details + '</button>');
          $('#social_page_friendship_status').html(data.friendship_details);
        }
      } else {
        $('#taracot_social_page_top_buttons').append('&nbsp;&nbsp;<button class="btn btn-sm btn-success btn-social-add_friend" id="btn_add_friend_' + uid + '"><i class="glyphicon glyphicon-plus"></i>&nbsp;' + js_lang_add_friend + '</button>&nbsp;&nbsp;<img src="/images/white_loading.gif" style="width:16px;height:16px;display:none" id="prg_add_friend_' + uid + '">');
        $('.btn-social-add_friend').unbind();
        $('.btn-social-add_friend').click(json_send_friendship_request);
      }      
    } else {
      //$('#taracot_social_page_top_buttons').append('<button class="btn btn-primary btn-sm disabled">' + js_lang_friend_status_established + '</button>');
      $('#social_page_friendship_status').html(data.friendship_details);
    }    
    $('.btn-social-message').unbind();
    $('.btn-social-message').click(ajax_social_message_click_handler);
    $('.btn-social-friends').click(ajax_friends_click_handler);
  } else {
    $('#taracot_social_page_top_buttons').append('<button class="btn btn-default btn-sm" onclick="location.href=\'#view=friends\'"><i class="glyphicon glyphicon-user"></i>&nbsp;' + js_lang_friends + '</button>&nbsp;');
    $('#taracot_social_page_top_buttons').append('&nbsp;<button class="btn btn-default btn-sm" onclick="location.href=\'#view=messaging\'"><i class="glyphicon glyphicon-envelope"></i>&nbsp;' + js_lang_my_messages + '</button>');
  }
};


var ajax_load_message_history = function(id) {
  $('#social_messaging_ajax').show();
  $('#social_messaging_chat_inner').empty();
  $.ajax({
        type: 'POST',
        url: '/social/messages/load',
        data: {
            uid: id
        },
        dataType: "json",
        success: function (data) {
          $('#social_messaging_ajax').hide();
          if (data.status == 1) {    
            for (var i=0; i<data.messages.length; i++) {
              $('#social_messaging_chat_inner').append('<div class="media"><span class="pull-left"><img class="media-object" style="width:50px;height:50px" src="' + data.users[data.messages[i].ufrom].avatar  + '"></span><span class="pull-right"><small>' + data.messages[i].mtime  + '</small></span>    <div class="media-body"><b>' + data.users[data.messages[i].ufrom].username  + '</b><div style="height:3px"></div>' + data.messages[i].msg  + '</div></div>');
            }
            $('#social_messaging_chat_with').html(data.users[social_message_uid].realname || data.users[social_message_uid].username);
            $('#social_messaging_chatbox_title').show();
            $("#social_messaging_chat").scrollTop($("#social_messaging_chat")[0].scrollHeight);
            $("#social_messaging_answer_area").val('');
            $("#social_messaging_answer_area").focus();
            messages_flag = data.unread_flag;
            social_update_counters();
          } else {
            $('#social_messaging_chat_inner').html('<div class="alert alert-danger">'+js_lang_load_messages_error+'</div>');
          }
        },
        error: function () {
          $('#social_messaging_ajax').hide();
          $('#social_messaging_chat_inner').html('<div class="alert alert-danger">'+js_lang_load_messages_error+'</div>');
        }
    });
};


var ajax_social_message_click_handler = function(uid) {
  $('#social_messaging_chatbox').show();
  $('#social_messaging_talks').hide();
  var id = jQuery(this).attr("id");
  if (id) {
    id = id.replace('btn_sendmessage_','');  
  } else {
    id = uid;
  }
  $.history.push("view=message&id=" + id );
  $('.social_menu').removeClass('active');
  $('.social_tab').hide();
  $('#social_messaging_chatbox_title').hide();
  $('#social_menu_messaging_li').addClass('active');  
  $('#social_tab_messaging').show();
  $('#social_messaging_chat').show();
  $('#social_messaging_chat_inner').empty();
  $('#social_messaging_talks').hide(); 
  social_message_uid = id; 
  ajax_load_message_history(id);
  $('#social_messaging_answer_error').hide();
  $('#social_messaging_answer_area').focus();
};

var ajax_friends_click_handler = function(uid) {  
  var id = jQuery(this).attr("id");
  if (id) {
    id = id.replace('btn_friends_','');  
  } else {
    id = uid;
  }
  $.history.push("view=friends&id=" + id );  
  $('.social_menu').removeClass('active');
  $('.social_tab').hide();
  $('#social_tab_friends').show();
  $('#social_friends_results').empty();
  social_friends_page = 1;
  social_friends_id = id;
  ajax_load_friends_data(1, social_friends_id);
};


var social_messaging_answer_btn_click_handler = function() {
  if ($('#social_messaging_answer_btn').hasClass('disabled')) {
    return;
  }
  $('#social_messaging_answer_error').hide();
  if ($('#social_messaging_answer_area').val().length < 1 || $('#social_messaging_answer_area').val().length > 4096) {
    $('#social_messaging_answer_error_msg').html(js_lang_incorrect_msg);
    $('#social_messaging_answer_error').show();
    $('#social_messaging_answer_area').focus();
    return;
  }
  $('#social_messaging_answer_btn').addClass('disabled');
  $('#social_messaging_answer_ajax').show();
  var sent_message_id = new Date().getTime();  
  sent_message_ids.push("_"+sent_message_id);  
  $.ajax({
        type: 'POST',
        url: '/social/messages/save',
        data: {
            uid: social_message_uid,
            msg: $('#social_messaging_answer_area').val(),
            mid: sent_message_id
        },
        dataType: "json",
        success: function (data) {          
          $('#social_messaging_answer_ajax').hide();
          if (data.status == 1) {    
            $('#social_messaging_chat_inner').append('<div class="media"><span class="pull-left"><img class="media-object" style="width:50px;height:50px" src="' + data.avatar  + '"></span><span class="pull-right"><small>' + data.mtime  + '</small></span><div class="media-body"><b>' + data.username  + '</b><div style="height:3px"></div>' + data.msg  + '</div></div>');
            $("#social_messaging_chat").scrollTop($("#social_messaging_chat")[0].scrollHeight);
            $('#social_messaging_answer_area').val('');            
          } else {
            if (data.errmsg) {
              $('#social_messaging_answer_error_msg').html(data.errmsg);
              $('#social_messaging_answer_error').show();
              $('#social_messaging_answer_area').focus();
            } else {
              $('#social_messaging_answer_error_msg').html(js_lang_ajax_error);
              $('#social_messaging_answer_error').show();
              $('#social_messaging_answer_area').focus();
            }
          }
          $('#social_messaging_answer_btn').removeClass('disabled');
        },
        error: function () {
          $('#social_messaging_answer_ajax').hide();          
          $('#social_messaging_answer_error_msg').html(js_lang_ajax_error);
          $('#social_messaging_answer_error').show();
          $('#social_messaging_answer_area').focus();
          $('#social_messaging_answer_btn').removeClass('disabled');
        }
    });    
};


$('#social_messaging_answer_btn').click(social_messaging_answer_btn_click_handler);


$('#social_messaging_answer_area').keydown(function (e) {
  if (e.ctrlKey && e.keyCode == 13) {
    e.preventDefault();
    social_messaging_answer_btn_click_handler();
  }
});


$('.social_menu_link').click(function(e) {
  $.history.push($(this).attr('href'));
  e.preventDefault();
});


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


var ajax_load_talks_data = function(uid) {
  $('#social_messaging_talks_ajax').show();
  $('#social_messaging_talks_data').empty();
  $.ajax({
        type: 'POST',
        url: '/social/messages/list',
        dataType: "json",
        success: function (data) {
          $('#social_messaging_talks_ajax').hide();
          if (data.status == 1) {    
            if ((!data.items) || (data.items && data.items.length == 0)) {
              $('#social_messaging_talks_data').html('<div class="alert alert-warning">'+js_lang_messages_nothing_found+'</div>')
            }
            for (var i=0; i<data.items.length; i++) {
              var count_msg = data.items[i].total || 0;
              var last_msg = data.items[i].last_msg || '';
              var last_date = data.items[i].last_msg_date || '';
              var unread_icon = '';
              if (data.items[i].unread) {
               unread_icon = '&nbsp;<span class="badge" style="background:#ff6666;color:#fff;font-size:80%"><i class="glyphicon glyphicon-envelope"></i></span>';
              }
              $('#social_messaging_talks_data').append('<div class="media" onclick="location.href=\'#view=message&id=' + data.items[i].id + '\'" style="cursor:pointer"><span class="pull-left"><img class="media-object" style="width:64px;height:64px" src="' + data.items[i].avatar + '"></span><div class="media-body"><span class="media-heading" style="font-size:110%;font-weight:bold">' + (data.items[i].realname || data.items[i].username)  + '</span>&nbsp;&nbsp;<span class="badge" data-toggle="tooltip" data-placement="top" title="' + js_lang_messages_total + '">' + count_msg + '</span>' + unread_icon + '<span class="pull-right"><small>' + last_date + '</small></span><div style="height:10px"></div>' + last_msg  + '</div></div>');
              if (i != data.items.length-1) {
                $('#social_messaging_talks_data').append('<hr>');
              }
            }
          } else {
            $('#social_messaging_talks_data').html('<div class="alert alert-danger">' + js_lang_load_message_list_error + '</div>');
          }
        },
        error: function () {
          $('#social_messaging_talks_ajax').hide();
          $('#social_messaging_talks_data').html('<div class="alert alert-danger">' + js_lang_load_message_list_error + '</div>');
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
var _cpl = $.unparam(document.URL.substr(document.URL.indexOf('#')+1));
if (!_cpl['view']) {
  $('#social_page_user').show();
}

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
  if (ph['view'] == 'page') {
    $('.social_menu').removeClass('active');
    $('.social_tab').hide();
    $('#social_tab_page').show();    
    if (ph['id'] && ph['id'].length > 0) {
      $('#social_page_user').hide();
      $('#social_page_results').show();
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
    $('#social_friends_results').empty();
    social_friends_page = 1;
    if (ph['id'] && ph['id'].length > 0) {
      social_friends_id = ph['id'];
      ajax_load_friends_data(1, social_friends_id);
    } else {
      $('#social_menu_friends_li').addClass('active');
      social_friends_id = undefined;
      ajax_load_friends_data(1);      
    }    
    friends_flag = 0;
    social_update_counters();
    return;
  }
  if (ph['view'] == 'search') {
    $('.social_menu').removeClass('active');
    $('.social_tab').hide();
    $('#social_tab_search').show();
    $('#social_search_results').empty();
    $('#social_menu_search_li').addClass('active');
    if (ph['query'] && ph['query'].length > 0) {
      social_search_page = 1;
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
    $('#social_messaging_chatbox').hide();
    $('#social_messaging_talks').show();
    $('#social_menu_messaging_li').addClass('active');
    ajax_load_talks_data();
    return;
  }
  if (ph['view'] == 'message' && ph['id'] && ph['id'] > 0) {        
    $('#social_messaging_chatbox').show();
    $('#social_messaging_talks').hide();
    ajax_social_message_click_handler(ph['id']);    
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