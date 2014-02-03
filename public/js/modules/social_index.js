var social_search_page = 1;
$('.social_menu').click(function() {
	$('.social_menu').removeClass('active');
	$(this).addClass('active');
});
$('.social_menu').click(function() {
	$('.social_menu').removeClass('active');
	$(this).addClass('active');
	social_search_page = -1;
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
	$('#social_search_results').html('');  
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
$('#social_search_btn').click(function () {		
	$('#social_search_results').html('');
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
   if($(window).scrollTop() + $(window).height() > $(document).height() - 100 && social_search_page > 0) {
       social_search_page++;
       ajax_load_search_data($('#social_search_input').val(), social_search_page);
   }
});
var ajax_load_user_data = function(uid) {
	$('#social_page_ajax').show();
	$('#social_page_results').html('');
  console.log('ajax_load_user_data called, id='+uid);
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
            	$('#social_page_results').append('<h1 class="social_page_header">' + data.realname + '<img src="' + data.avatar +'" class="pull-right" alt="' + data.realname + '"></h1>');
              if (uid != current_user_id) {
                $('#social_page_results').append('<button class="btn btn-success"><i class="glyphicon glyphicon-plus"></i>&nbsp;' + js_lang_add_friend + '</button>');
              }
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
	ajax_load_user_data(id);	
};
$('.social_menu_link').click(function(e) {
  $.history.push($(this).attr('href'));
  e.preventDefault();
});
$.history.on('load change', function(event, url, type) {
  var items = url.split('&');
  var ph = $.unparam(url);  
  if (ph['view'] == 'search_results') {
    $('.social_tab').hide();    
    $('#social_tab_search').show();
    return;
  }
  social_search_page = -1;
  if (ph['view'] == 'page' || ph['view'] == '') {
    $('.social_menu').removeClass('active');
    $('.social_tab').hide();
    $('#social_tab_page').show();    
    if (ph['id'] && ph['id'].length > 0) {
      ajax_load_user_data(ph['id']);
    } else {
      $('#social_menu_page_li').addClass('active');
      ajax_load_user_data(current_user_id);
    }
    return;
  }
  if (ph['view'] == 'friends') {
    $('.social_menu').removeClass('active');
    $('.social_tab').hide();
    $('#social_tab_friends').show();
    $('#social_menu_friends_li').addClass('active');
    return;
  }
  if (ph['view'] == 'search') {
    $('.social_menu').removeClass('active');
    $('.social_tab').hide();
    $('#social_tab_search').show();
    $('#social_search_results').html('');
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