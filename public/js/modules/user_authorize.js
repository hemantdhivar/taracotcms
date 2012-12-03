$('#auth_login').focus();
$('#btn_submit').bind('click', function () {
    $('#cg_auth_login').removeClass('error');
    $('#cg_auth_password').removeClass('error');
    $('#form_error_msg').hide();
    $('#form_error_msg_text').html('');
    var form_errors = false;
    if (!$('#auth_login').val().match(/^[A-Za-z0-9_\-]{3,100}$/) && !$('#auth_login').val().match(/^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/)) {
        $('#cg_auth_login').addClass('error');
        $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_login + "<br/>");
        form_errors = true;
    }
    if (!$('#auth_password').val().match(/^[A-Za-z0-9_\-\$\!\@\#\%\^\&\[\]\{\}\*\+\=\.\,\'\"\|\<\>\?]{1,100}$/)) {
        $('#cg_auth_password').addClass('error');
        $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_password_single + "<br/>");
        form_errors = true;
    }
    if (form_errors) {
        $('#form_error_msg').fadeIn(400);
        $('#form_error_msg').alert();
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
                auth_password: $('#auth_password').val()
            },
            dataType: "json",
            success: function (data) {
                if (data.status == 1) {
                    $('#auth_form_ajax').html(js_lang_user_auth_success);
                } else {
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
                    if (data.fields) {
                        for (var i = 0; i < data.fields.length; i++) {
                            $('#cg_auth_' + data.fields[i]).addClass('error');
                            if (i == 1) {
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
            }
        });
    }
});