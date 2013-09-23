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
$('#reg_username,#reg_password,#reg_password_repeat,#reg_realname,#reg_email,#reg_phone,#reg_captcha,#reg_agreement').bind('keypress', function (e) {
    if (submitOnEnter(e)) {
        $('#btn_submit').click();
    }
});
function reloadCaptcha() {
    $('#captcha_shown').attr('src', '/captcha_img?' + Math.random());
}
$('#btn_submit').bind('click', function () {
    $('#cg_reg_username').removeClass('has-error');
    $('#cg_reg_password').removeClass('has-error');
    $('#cg_reg_realname').removeClass('has-error');
    $('#cg_reg_email').removeClass('has-error');
    $('#cg_reg_phone').removeClass('has-error');
    $('#cg_reg_captcha').removeClass('has-error');
    $('#cg_reg_agreement').removeClass('has-error');
    $('#social_auth').hide();
    $('#form_error_msg').hide();
    $('#form_error_msg_text').html('');
    var form_errors = false;
    if (!$('#reg_username').val().match(/^[A-Za-z0-9_\-]{3,100}$/)) {
        $('#cg_reg_username').addClass('has-error');
        $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_username + "<br/>");
        form_errors = true;
    }
    if (!$('#reg_password').val().match(/^[A-Za-z0-9_\-\$\!\@\#\%\^\&\[\]\{\}\*\+\=\.\,\'\"\|\<\>\?]{8,100}$/) || $('#reg_password').val() != $('#reg_password_repeat').val()) {
        $('#cg_reg_password').addClass('has-error');
        $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_password + "<br/>");
        form_errors = true;
    }
    if (!$('#reg_realname').val().match(/^.{0,80}$/)) {
        $('#cg_reg_realname').addClass('has-error');
        $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_realname + "<br/>");
        form_errors = true;
    }
    if (!$('#reg_phone').val().match(/^[0-9\-\(\)\s]{0,40}$/)) {
        $('#cg_reg_phone').addClass('has-error');
        $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_phone + "<br/>");
        form_errors = true;
    }
    if (!$('#reg_email').val().match(/^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/)) {
        $('#cg_reg_email').addClass('has-error');
        $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_email + "<br/>");
        form_errors = true;
    }
    if (!$('#reg_captcha').val().match(/^[0-9]{4}$/)) {
        $('#cg_reg_captcha').addClass('has-error');
        $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_captcha + "<br/>");
        form_errors = true;
    }
    if (!$('#reg_accept').is(':checked')) {
        $('#cg_reg_agreement').addClass('has-error');
        $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_agreement + "<br/>");
        form_errors = true;
    }
    if (form_errors) {
        $('#form_error_msg').fadeIn(400);
        $('#form_error_msg').alert();
        $(window).scrollTop($('#form_error_msg').position().top);
        $('#social_auth').show();
    } else {
        $('#reg_form').hide();
        $('#reg_form_hint').hide();
        $('#reg_form_ajax').show();
        $.ajax({
            type: 'POST',
            url: '/user/register/process',
            data: {
                reg_username: $('#reg_username').val(),
                reg_realname: $('#reg_realname').val(),
                reg_email: $('#reg_email').val(),
                reg_phone: $('#reg_phone').val(),
                reg_password: $('#reg_password').val(),
                reg_captcha: $('#reg_captcha').val()
            },
            dataType: "json",
            success: function (data) {
                if (data.status == 1) {
                    $('#reg_form_ajax').html(js_lang_user_register_success);
                } else {
                    $('#social_auth').show();
                    if (data.errors) {
                        for (var i = 0; i < data.errors.length; i++) {
                            $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + data.errors[i] + "<br/>");
                        }
                    }
                    $('#form_error_msg').fadeIn(400);
                    $('#form_error_msg').alert();
                    $(window).scrollTop($('#form_error_msg').position().top);
                    $('#reg_form').show();
                    $('#reg_form_hint').show();
                    $('#reg_form_ajax').hide();
                    $('#reg_captcha').val('');
                    if (data.fields) {
                        for (var i = 0; i < data.fields.length; i++) {
                            $('#cg_reg_' + data.fields[i]).addClass('has-error');
                            if (i == 1) {
                                $('#reg_' + data.fields[i]).focus();
                            }
                        }
                    }
                    reloadCaptcha();
                }
            },
            error: function () {
                $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_error_ajax + "<br/>");
                $('#form_error_msg').fadeIn(400);
                $('#form_error_msg').alert();
                $(window).scrollTop($('#form_error_msg').position().top);
                $('#reg_form').show();
                $('#reg_form_hint').show();
                $('#reg_form_ajax').hide();
                $('#social_auth').show();
            }
        });
    }
});
$('#reg_captcha').val('');
reloadCaptcha();
$('#reg_username').focus();