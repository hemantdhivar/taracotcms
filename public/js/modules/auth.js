$('#auth_finish_dlg').modal({keyboard:false,backdrop:'static'});
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
$('#authdlg_username,#authdlg_password,#authdlg_password_repeat').bind('keypress', function (e) {
    if (submitOnEnter(e)) {
        $('#authdlg_btn_submit').click();
        e.preventDefault();
    }
});
$('#authdlg_btn_change_username').bind('click', function () {
    $('#authdlg_btn_change_username').hide();
    $('#authdlg_btn_cancel').hide();
    $('#authdlg_hint').hide();
    $('#authdlg_authdlg_form').show();
    $('#authdlg_btn_submit').show();
    $('#authdlg_username').focus();
});
$('#authdlg_btn_submit').bind('click', function () {
    $('#authdlg_cg_username').removeClass('has-error');
    $('#authdlg_form_error_msg').hide();
    $('#authdlg_form_error_msg_text').html('');
    var form_errors = false;
    if (!$('#authdlg_username').val().match(/^[A-Za-z0-9_\-]{3,100}$/)) {
        $('#authdlg_cg_username').addClass('has-error');
        $('#authdlg_form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_authdlg_invalid_username + "<br/>");
        form_errors = true;
    }
    if (form_errors) {
        $('#authdlg_form_error_msg').fadeIn(400);
        $('#authdlg_form_error_msg').alert();
        $('#authdlg_username').focus();
        $('#authdlg_username').select();
    } else {
        $('#authdlg_authdlg_body').hide();
        $('#authdlg_authdlg_progress').show();
        $('#auth_finish_dlg_footer').hide();
        $.ajax({
            type: 'POST',
            url: '/user/register/finish',
            data: {
                auth_username: $('#authdlg_username').val()                
            },
            dataType: "json",
            success: function (data) {
                if (data.status == 1) {
                    location.href="/user/account?" + Math.random();
                } else { 
                    $('#authdlg_authdlg_body').show();
                    $('#authdlg_authdlg_progress').hide();
                    $('#auth_finish_dlg_footer').show();
                    $('#authdlg_username').focus();                   
                    $('#authdlg_username').select();
                    if (data.errors) {
                        for (var i = 0; i < data.errors.length; i++) {
                            $('#authdlg_form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + data.errors[i] + "<br/>");
                        }
                    }
                    $('#authdlg_form_error_msg').fadeIn(400);
                    $('#authdlg_form_error_msg').alert();                    
                    if (data.fields) {
                        for (var i = 0; i < data.fields.length; i++) {
                            $('#authdlg_cg_' + data.fields[i]).addClass('has-error');
                            if (i == 1) {
                                $('#authdlg_' + data.fields[i]).focus();                                
                            }
                        }
                    }
                }
            },
            error: function () {
                $('#authdlg_authdlg_body').show();
                $('#authdlg_authdlg_progress').hide();
                $('#auth_finish_dlg_footer').show();
                $('#authdlg_form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_error_ajax + "<br/>");
                $('#authdlg_form_error_msg').fadeIn(400);
                $('#authdlg_form_error_msg').alert();  
                $('#authdlg_username').focus();              
                $('#authdlg_username').select();                
            }
        })
    }
});
$('#authdlg_btn_cancel').bind('click', function () {
    $('#authdlg_cg_username').removeClass('has-error');
    $('#authdlg_form_error_msg').hide();
    $('#authdlg_form_error_msg_text').html('');
    $('#authdlg_authdlg_body').hide();
    $('#authdlg_authdlg_progress').show();
    $('#auth_finish_dlg_footer').hide();
    $.ajax({
        type: 'POST',
        url: '/user/register/finish/default',
        dataType: "json",
        success: function (data) {
            if (data.status == 1) {
                location.href="/user/account?" + Math.random();
            } else { 
                $('#authdlg_authdlg_body').show();
                $('#authdlg_authdlg_progress').hide();
                $('#auth_finish_dlg_footer').show();
                if (data.errors) {
                    for (var i = 0; i < data.errors.length; i++) {
                        $('#authdlg_form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + data.errors[i] + "<br/>");
                    }
                }
                $('#authdlg_form_error_msg').fadeIn(400);
                $('#authdlg_form_error_msg').alert();                    
                if (data.fields) {
                    for (var i = 0; i < data.fields.length; i++) {
                        $('#authdlg_cg_' + data.fields[i]).addClass('has-error');
                        if (i == 1) {
                            $('#authdlg_' + data.fields[i]).focus();                                
                        }
                    }
                }
            }
        },
        error: function () {
            $('#authdlg_authdlg_body').show();
            $('#authdlg_authdlg_progress').hide();
            $('#auth_finish_dlg_footer').show();
            $('#authdlg_form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_error_ajax + "<br/>");
            $('#authdlg_form_error_msg').fadeIn(400);
            $('#authdlg_form_error_msg').alert();  
            $('#authdlg_username').focus();              
            $('#authdlg_username').select();                
        }
    })
});