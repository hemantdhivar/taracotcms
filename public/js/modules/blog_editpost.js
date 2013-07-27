$('#btn_submit').click(function() {
    blog_data: $("#wbbeditor").bbcode()
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
                    blog_data: $("#wbbeditor").bbcode()
                },
                dataType: "json",
                success: function (data) {
                    if (data.status == 1) {
                        $('#form_success_msg').html(js_lang_success_save +"&nbsp;<a href=\"/blog/post/"+data.pid+"\">"+ js_lang_click_here +"</a>.<br/><br/>"+js_lang_success_new);
                        $('#blog_form_ajax').hide();
                        $('#form_success_msg').show();
                    }
                },
                error: function () {

                }
            });
    }
});