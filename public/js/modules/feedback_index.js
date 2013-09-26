$(document).ready(function () {
	$('#f_realname').focus();
});

$('#captcha_img').html('<img id="captcha_shown" src="/captcha_img?' + Math.random() + '" onclick="reloadCaptcha()" width="100" height="50" alt="" style="cursor:pointer" />');
function reloadCaptcha() {
    $('#captcha_shown').attr('src', '/captcha_img?' + Math.random());
}

$('#btn_submit').click(function() {
	$('.feedback-form-group').removeClass('has-error');
	$('#form_error_msg').hide();
	$('#form_error_msg_text').html('');
	var form_errors = false;
	if (!$('#f_realname').val().match(/^.{1,80}$/)) {
        $('#cg_f_realname').addClass('has-error');
        $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_error_realname + "<br/>");
        form_errors = true;
    }
    if (!$('#f_phone').val().match(/^[0-9\-\+\(\)\s]{0,40}$/)) {
        $('#cg_f_phone').addClass('has-error');
        $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_error_phone + "<br/>");
        form_errors = true;
    }
    if (!$('#f_email').val().match(/^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/)) {
        $('#cg_f_email').addClass('has-error');
        $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_error_email + "<br/>");
        form_errors = true;
    }
    if ($('#f_msg').val().length = 0 || $('#f_msg').val().length > 102400) {
        $('#cg_f_msg').addClass('has-error');
        $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_error_msg + "<br/>");
        form_errors = true;
    }
    if (!$('#f_captcha').val().match(/^[0-9]{4,4}$/)) {
        $('#cg_f_captcha').addClass('has-error');
        $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_error_captcha + "<br/>");
        form_errors = true;
    }
    if (form_errors) {
    	$('#form_error_msg').show();
    	$('#f_realname').focus();
    	$(window).scrollTop($('#form_error_msg').position().top);
    } else {
    	$('#feedback-form').hide();
    	$('#feedback-ajax').show();
    	$.ajax({
            type: 'POST',
            url: '/feedback/process',
            data: {
                f_realname: $('#f_realname').val(),
                f_email: $('#f_email').val(),
                f_phone: $('#f_phone').val(),
                f_msg: $('#f_msg').val(),
                f_captcha: $('#f_captcha').val()
            },
            dataType: "json",
            success: function (data) {
                if (data.status == 1) {
                    $('#feedback-ajax').html(js_lang_ajax_success);
                } else {
                    if (data.errors) {
                        for (var i = 0; i < data.errors.length; i++) {
                            $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + data.errors[i] + "<br/>");
                        }                        
                    } else {
                    	$('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_error_ajax + "<br/>");
                    }    
                    $('#form_error_msg').show();                
                    $('#feedback-form').show();
    				$('#feedback-ajax').hide();
                    $(window).scrollTop($('#form_error_msg').position().top);
                    $('#f_captcha').val('');
                    if (data.fields) {
                        for (var i = 0; i < data.fields.length; i++) {
                            $('#cg_' + data.fields[i]).addClass('has-error');                            
                        }
                    }
                    $('#f_realname').focus();
                    reloadCaptcha();
                }
            },
            error: function () {
            	$('#form_error_msg').show();
            	$(window).scrollTop($('#form_error_msg').position().top);
                $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_error_ajax + "<br/>");
                $('#feedback-form').show();
    			$('#feedback-ajax').hide();
    			reloadCaptcha();
    			$('#f_captcha').val('');
    			$('#f_realname').focus();
            }
        });
    }
});

$('.feedback-form-control').bind('keypress', function (e) {
    if (e.keyCode == 13) {
    	$('#btn_submit').click();
	}
});
