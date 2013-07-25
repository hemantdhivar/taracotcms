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
        $('#form_error_msg').show();
    }
    if (!$('#blog_tags').val().match(/.{1,250}$/)) {
        $('#cg_blog_tags').addClass('error');
        $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_invalid_post_tags + "<br/>");
        form_errors = true;      
        $('#form_error_msg').show();
    }
    if (!$('#blog_hub').val().match(/.{1,20}$/)) {
        $('#cg_blog_hub').addClass('error');
        $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_invalid_post_hub + "<br/>");
        form_errors = true;      
        $('#form_error_msg').show();
    }
    if ($('#blog_state').val() < 0 || $('#blog_state').val() > 2) {
        $('#cg_blog_state').addClass('error');
        $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_invalid_post_state + "<br/>");
        form_errors = true;      
        $('#form_error_msg').show();
    }    
    
});