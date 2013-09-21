$('#captcha_img').html('<img id="captcha_shown" src="/captcha_img?' + Math.random() + '" onclick="reloadCaptcha()" width="100" height="50" alt="" style="cursor:pointer" />');
function submitOnEnter(e) {
    var keycode;
    if (window.event) keycode = window.event.keyCode;
    else if (e) keycode = (e.keyCode ? e.keyCode : e.which);
    else return false;
    if (keycode == 13) {
        if (window.previousKeyCode) {
            // down=40,up=38,pgdn=34,pgup=33
            if (window.previousKeyCode == 33 || window.previousKeyCode == 34 ||
                window.previousKeyCode == 39 || window.previousKeyCode == 40) {
                    window.previousKeyCode = keycode;
                    return false;
            }
        }
        return true;
    } else {
        window.previousKeyCode = keycode;
        return false;
    }
}
// bind enter keys to form fields
$('#pwd_email,#pwd_captcha').bind('keypress', function (e) {
    if (submitOnEnter(e)) {
        $('#btn_submit').click();
    }
});
function reloadCaptcha() {
    $('#captcha_shown').attr('src', '/captcha_img?' + Math.random());
}
$('#pwd_email').focus();
$('#btn_submit').bind('click', function () {
    $('#cg_pwd_email').removeClass('error');
    $('#cg_pwd_captcha').removeClass('error');
    $('#form_error_msg').hide();
    $('#form_error_msg_text').html('');
    var form_errors = false;    
    if (!$('#pwd_email').val().match(/^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/)) {
        $('#cg_pwd_email').addClass('error');
        $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_email + "<br/>");
        form_errors = true;
    }
    if (!$('#pwd_captcha').val().match(/^[0-9]{4}$/)) {
        $('#cg_pwd_captcha').addClass('error');
        $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_captcha + "<br/>");
        form_errors = true;
    }
    if (form_errors) {
        $('#form_error_msg').fadeIn(400);
        $('#form_error_msg').alert();
        reloadCaptcha();
        $(window).scrollTop($('#form_error_msg').position().top);
    } else {
        $('#pwd_form').hide();
        $('#pwd_form_hint').hide();
        $('#pwd_form_ajax').show();
        $.ajax({
            type: 'POST',
            url: '/user/password/process',
            data: {
                pwd_email: $('#pwd_email').val(),
                pwd_captcha: $('#pwd_captcha').val()
            },
            dataType: "json",
            success: function (data) {
                if (data.status == 1) {
                    $('#pwd_form_ajax').html(js_lang_user_pwd_success_sent);
                } else {
                    reloadCaptcha();
                    if (data.errors) {
                        for (var i = 0; i < data.errors.length; i++) {
                            $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + data.errors[i] + "<br/>");
                        }
                    }
                    $('#form_error_msg').fadeIn(400);
                    $('#form_error_msg').alert();
                    $(window).scrollTop($('#form_error_msg').position().top);
                    $('#pwd_form').show();
                    $('#pwd_form_hint').show();
                    $('#pwd_form_ajax').hide();
                    $('#pwd_captcha').val('');
                    if (data.fields) {
                        for (var i = 0; i < data.fields.length; i++) {
                            $('#cg_pwd_' + data.fields[i]).addClass('error');
                            if (i == 1) {
                                $('#pwd_' + data.fields[i]).focus();
                            }
                        }
                    }
                }
            },
            error: function () {
                $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_error_ajax + "<br/>");
                $('#form_error_msg').fadeIn(400);
                $('#form_error_msg').alert();
                $(window).scrollTop($('#form_error_msg').position().top);
                $('#pwd_form').show();
                $('#pwd_form_hint').show();
                $('#pwd_form_ajax').hide();
            }
        });
    }
});