var verification_code = js_verification;
var username = js_username;

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
$('#pwd_password,#pwd_password_repeat').bind('keypress', function (e) {
    if (submitOnEnter(e)) {
        $('#btn_submit').click();
    }
});

if ((verification_code).length < 32) {
    $('#fail_notice').show();
} else {
    $('#reset_form').show();
    $('#captcha_img').html('<img id="captcha_shown" src="/captcha_img?' + Math.random() + '" onclick="reloadCaptcha()" width="100" height="50" alt="" style="cursor:pointer" />');

    function reloadCaptcha() {
        $('#captcha_shown').attr('src', '/captcha_img?' + Math.random());
    }
    $('#pwd_password').focus();
    $('#btn_submit').bind('click', function () {
        $('#cg_pwd_password').removeClass('error');
        $('#form_error_msg').hide();
        $('#form_error_msg_text').html('');
        var form_errors = false;
        if (!$('#pwd_password').val().match(/^[A-Za-z0-9_\-\$\!\@\#\%\^\&\[\]\{\}\*\+\=\.\,\'\"\|\<\>\?]{8,100}$/) || $('#pwd_password').val() != $('#pwd_password_repeat').val()) {
            $('#cg_pwd_password').addClass('error');
            $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_password + "<br/>");
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
                url: '/user/password/reset/process',
                data: {
                    pwd_username: username,
                    pwd_password: $('#pwd_password').val(),
                    verification: verification_code
                },
                dataType: "json",
                success: function (data) {
                    if (data.status == 1) {
                        $('#pwd_form_ajax').html(js_lang_user_password_success_reset);
                    } else {
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
} // else