if (post_id) {
    $('#editpost_title').html(js_lang_edit_post);
} else {
    $('#editpost_title').html(js_lang_add_post);
}
$('#btn_submit').click(function() {
	$('#form_error_msg').hide();
	$('#form_error_msg_text').html('');
	$('#cg_blog_title').removeClass('error');
    $('#cg_blog_hub').removeClass('error');
    $('#cg_blog_tags').removeClass('error');
    $('#cg_blog_state').removeClass('error');
    var form_errors = false;
    if (!$('#blog_title').val().match(/.{1,250}$/)) {
        $('#cg_blog_title').addClass('error');
        $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_invalid_post_title + "<br/>");
        form_errors = true;      
    }
    if (!$('#blog_tags').val().match(/.{1,250}$/)) {
        $('#cg_blog_tags').addClass('error');
        $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_invalid_post_tags + "<br/>");
        form_errors = true;      
    }
    if (!$('#blog_hub').val().match(/.{1,20}$/)) {
        $('#cg_blog_hub').addClass('error');
        $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_invalid_post_hub + "<br/>");
        form_errors = true;      
    }
    if ($('#blog_state').val() < 0 || $('#blog_state').val() > 2) {
        $('#cg_blog_state').addClass('error');
        $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_invalid_post_state + "<br/>");
        form_errors = true;              
    } 
    form_errors = false;   
    if (form_errors) {
            $('#form_error_msg').fadeIn(400);
            $('#form_error_msg').alert();
            $(window).scrollTop($('#form_error_msg').position().top);
    } else {
            $('#blog_form').hide();
            $('#blog_form_ajax').show();
            $.ajax({
                type: 'POST',
                url: '/blog/post/process',
                data: {
                    blog_title: $('#blog_title').val(),
                    blog_tags: $('#blog_tags').val(),
                    blog_hub: $('#blog_hub').val(),
                    blog_state: $('#blog_state').val(),
                    blog_data: $("#wbbeditor").bbcode(),
                    id: post_id
                },
                dataType: "json",
                success: function (data) {
                    if (data.status == 1) {
                        $('#form_success_msg').html(js_lang_success_save +"&nbsp;<a href=\"/blog/post/"+data.pid+"\">"+ js_lang_click_here +"</a>.<br/><br/>"+js_lang_success_new);
                        $('#blog_form_ajax').hide();
                        $('#form_success_msg').show();
                    } else {
                        $('#blog_form_ajax').hide();
                        $('#blog_form').show();
                        $('#form_error_msg_text').html("&nbsp;<b>" + js_lang_error_save + "</b><br/>");
                        if (data.errors) {
                            $('#form_error_msg_text').append("<br/>");
                            for (var i = 0; i < data.errors.length; i++) {
                                $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + data.errors[i] + "<br/>");
                            }
                        }
                        $('#form_error_msg').fadeIn(400);
                        $('#form_error_msg').alert();
                        $(window).scrollTop($('#form_error_msg').position().top);                    
                        if (data.fields) {
                            for (var i = 0; i < data.fields.length; i++) {
                                $('#cg_' + data.fields[i]).addClass('error');
                                if (i == 0) {
                                    $('#' + data.fields[i]).focus();
                                }
                            }
                        }
                    }
                },
                error: function () {
                    $('#blog_form_ajax').hide();
                    $('#blog_form').show();
                    $('#form_error_msg_text').html("&nbsp;<b>" + js_lang_error_save + "</b><br/>");
                    $('#form_error_msg').fadeIn(400);
                    $('#form_error_msg').alert();
                    $(window).scrollTop($('#form_error_msg').position().top);
                }
            });
    }
});

function loadData(wbbOpt) {
    $.ajax({
        type: 'POST',
        url: '/blog/post/load',
        data: {
            pid: post_id
        },
        dataType: "json",
        success: function (data) {
            $('#blog_form_ajax').hide();
            if (data.status == 1) {
                if (data.ptitle) {
                    $('#blog_title').val(data.ptitle);
                }
                if (data.phub) {
                    $('#blog_hub').val(data.phub);
                }
                if (data.ptags) {
                    $('#blog_tags').val(data.ptags);
                }
                if (data.pstate) {
                    $('#blog_state').val(data.pstate);
                }
                if (data.pstate) {
                    $('#blog_state').val(data.pstate);
                }
                if (data.ptext) {     
                  $('#wbbeditor').val(data.ptext);                  
                }
                $('#wbbeditor').wysibb(wbbOpt);
                $('#blog_form').show();
            } else {
                $('#blog_form_error').show();
            }
        },
        error: function () {
            $('#blog_form_ajax').hide();
            $('#blog_form_error').show();
        }
    });    
}