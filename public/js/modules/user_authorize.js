$('#captcha_img').html('<img id="captcha_shown" src="/captcha_img?' + Math.random() + '" onclick="reloadCaptcha()" width="100" height="50" alt="" style="cursor:pointer" />');

function reloadCaptcha() {
    $('#captcha_shown').attr('src', '/captcha_img?' + Math.random());
}

$('#auth_login').focus();
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
$('#auth_login,#auth_password,#auth_captcha').bind('keypress', function (e) {
    if (submitOnEnter(e)) {
        $('#btn_submit').click();
    }
});

$('#btn_submit').bind('click', function () {
    $('#cg_auth_login').removeClass('has-error');
    $('#cg_auth_password').removeClass('has-error');
    $('#cg_auth_captcha').removeClass('has-error');
    $('#form_error_msg').hide();
    $('#social_auth').hide();
    $('#form_error_msg_text').html('');
    var form_errors = false;
    if (!$('#auth_login').val().match(/^[A-Za-z0-9_\-\.]{3,100}$/) && !$('#auth_login').val().match(/^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/)) {
        $('#cg_auth_login').addClass('has-error');
        $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_login + "<br/>");
        form_errors = true;
    }
    if (!$('#auth_password').val().match(/^[A-Za-z0-9_\-\$\!\@\#\%\^\&\[\]\{\}\*\+\=\.\,\'\"\|\<\>\?]{1,100}$/)) {
        $('#cg_auth_password').addClass('has-error');
        $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_password_single + "<br/>");
        form_errors = true;
    }
    if (!$('#cg_auth_captcha').hasClass('hide') && !$('#auth_captcha').val().match(/^[0-9]{4}$/)) {
        $('#cg_auth_captcha').addClass('has-error');
        $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_captcha + "<br/>");
        form_errors = true;
    }
    if (form_errors) {
        $('#form_error_msg').fadeIn(400);
        $('#form_error_msg').alert();
        $('#social_auth').show();
        $(window).scrollTop($('#form_error_msg').position().top);
    } else {
        $('#auth_form').hide();
        $('#auth_form_hint').hide();
        $('#auth_form_ajax').show();
        $.ajax({
            type: 'POST',
            url: '/user/authorize/process',
            data: {
                auth_login: $('#auth_login').val(),
                auth_captcha: $('#auth_captcha').val(),
                auth_password: $('#auth_password').val()
            },
            dataType: "json",
            success: function (data) {
                if (data.status == 1) {
                    $('#auth_form_ajax').html(js_lang_user_auth_success);
                    var redirect = comeback_url;
                    if (redirect && redirect.length > 0) {
                        $('#auth_form_ajax').html($('#auth_form_ajax').html() + '<br/><br/>'+js_lang_user_auth_redirect);
                        location.href = redirect;
                    }
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
                    $('#auth_form').show();
                    $('#auth_form_hint').show();
                    $('#auth_form_ajax').hide();
                    $('#auth_captcha').val('');
                    reloadCaptcha();
                    if (data.fields) {
                        for (var i = 0; i < data.fields.length; i++) {
                            if (data.fields[i] == "captcha") {                                
                                $('#cg_auth_captcha').removeClass('hide');                                
                                $('#auth_captcha').focus();
                            }
                            $('#cg_auth_' + data.fields[i]).addClass('has-error');
                            if (i == 0) {
                                $('#auth_' + data.fields[i]).focus();
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
                $('#auth_form').show();
                $('#auth_form_hint').show();
                $('#auth_form_ajax').hide();
                $('#social_auth').show();
            }
        });
    }
});
