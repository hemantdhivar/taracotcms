$(document).ready(function () {
    $('#account_tabs a').click(function (e) {
        e.preventDefault();
        $(this).tab('show');
        if ($('#emc_email').val()) {
            $('#cg_emc_password').show();
            $('#cg_emc_new_password').hide();
        } else {
            $('#cg_emc_password').hide();
            $('#cg_emc_new_password').show();
            $('#emc_new_password').val('');
            $('#emc_new_password_repeat').val('');
            $('#cg_emc_email').hide();            
        }
    });    
    if (!$('#emc_email').val()) {
        $('#change_password_tab').hide();
    }
    if (password_unset == 1) {
        $('#cg_pwd_old_password').hide();
    }
    var uploader;
    $('.nav-tabs a').on('shown', function (e) {
        var target = e.target.toString();
        if (target.search('tab_profile') != -1) {
            $('#pro_realname').focus();
            if (!uploader) {
                uploader = new plupload.Uploader({
                    runtimes: 'html5,flash,silverlight,html4',
                    browse_button: 'btn_avatar_change',
                    max_file_size: '1mb',
                    multi_selection: 'false',
                    url: '/user/account/avatar/upload',
                    flash_swf_url: '/js/plupload/plupload.flash.swf',
                    silverlight_xap_url: '/js/plupload/plupload.silverlight.xap',
                    filters: [{
                        title: js_lang_image_files,
                        extensions: "jpg,jpeg,png"
                    }]
                });
                uploader.init();
                uploader.bind('FilesAdded', function (up, files) {
                    $('#avatar_loading').show();
                    $('#avatar_profile_img').hide();
                    uploader.start();
                });
                uploader.bind('FileUploaded', function (up, file, response) {
                    var res = jQuery.parseJSON(response.response);
                    if (res.error == '1') {
                        $('#avatar_loading').hide();
                        $('#avatar_profile_img').show();
                        alert(js_lang_user_account_avatar_uploading_error);
                    } else {
                        $('#avatar_loading').hide();
                        $("#avatar_profile_img").attr("src", "/files/avatars/"+ js_auth_data_username +".tmp.jpg?" + Math.random());
                        $('#avatar_profile_img').show();
                    }
                });
                uploader.bind('Error', function (up, error) {
                    alert(js_lang_user_account_avatar_uploading_error);
                });
            }
        }
        if (target.search('tab_email') != -1) {
            $('#emc_new_email').focus();
        }
        if (target.search('tab_password') != -1) {
            $('#pwd_password').focus();
        }
    });
    $('#btn_submit_profile').bind('click', function () {
        $('#cg_pro_realname').removeClass('error');
        $('#cg_pro_phone').removeClass('error');
        $('#cg_pro_password').removeClass('error');
        $('#form_profile_success').hide();
        $('#form_profile_errors').hide();
        $('#form_profile_errors').html('');
        var form_errors = false;
        if (!$('#pro_password').val().match(/^[A-Za-z0-9_\-\$\!\@\#\%\^\&\[\]\{\}\*\+\=\.\,\'\"\|\<\>\?]{5,100}$/)) {
            $('#cg_pro_password').addClass('error');
            $('#form_profile_errors').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_password_single + "<br/>");
            form_errors = true;
        }
        if (!$('#pro_realname').val().match(/^.{0,80}$/)) {
            $('#cg_pro_realname').addClass('error');
            $('#form_profile_errors').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_realname + "<br/>");
            form_errors = true;
        }
        if (!$('#pro_phone').val().match(/^[0-9\-\(\)\s]{0,40}$/)) {
            $('#cg_pro_phone').addClass('error');
            $('#form_profile_errors').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_phone + "<br/>");
            form_errors = true;
        }
        if (form_errors) {
            $('#form_profile_errors').fadeIn(400);
            $('#form_profile_errors').alert();
            $(window).scrollTop($('#form_profile_errors').position().top);
        } else {
            $('#tab_profile_form').hide();
            $('#tab_profile_ajax').show();
            $.ajax({
                type: 'POST',
                url: '/user/account/profile/process',
                data: {
                    pro_realname: $('#pro_realname').val(),
                    pro_phone: $('#pro_phone').val(),
                    pro_password: $('#pro_password').val()
                },
                dataType: "json",
                success: function (data) {
                    if (data.status == 1) {
                        $('#tab_profile_form').show();
                        $('#tab_profile_ajax').hide();
                        $('#pro_password').val('');
                        $('#pro_realname').focus();
                        $('#overview_phone').html('+' + $('#pro_phone').val());
                        if ($('#pro_realname').val()) {
                            $('#overview_realname').html($('#pro_realname').val());
                        } else {
                            $('#overview_realname').html(js_auth_data_username);
                        }
                        $("#avatar_profile_img").attr("src", "/files/avatars/"+js_auth_data_username+".jpg?" + Math.random());
                        $("#avatar_overview_img").attr("src", "/files/avatars/"+js_auth_data_username+".jpg?" + Math.random());
                        $('#form_profile_success').show().delay(2000).fadeOut(400);
                    } else {
                        if (data.errors) {
                            for (var i = 0; i < data.errors.length; i++) {
                                $('#form_profile_errors').append("&nbsp;&#9632;&nbsp;&nbsp;" + data.errors[i] + "<br/>");
                            }
                        }
                        $('#form_profile_errors').fadeIn(400);
                        $(window).scrollTop($('#form_profile_errors').position().top);
                        $('#tab_profile_form').show();
                        $('#tab_profile_ajax').hide();
                        if (data.fields) {
                            for (var i = 0; i < data.fields.length; i++) {
                                $('#cg_pro_' + data.fields[i]).addClass('error');
                                if (i == 1) {
                                    $('#pro_' + data.fields[i]).focus();
                                }
                            }
                        }
                    }
                },
                error: function () {
                    $('#form_profile_errors').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_error_ajax + "<br/>");
                    $('#form_profile_errors').fadeIn(400);
                    $(window).scrollTop($('#form_profile_errors').position().top);
                    $('#tab_profile_form').show();
                    $('#tab_profile_ajax').hide();
                }
            });
        }
    }); // btn_submit_profile click
    $('#btn_submit_email').bind('click', function () {
        $('#cg_emc_new_email').removeClass('error');
        $('#cg_emc_password').removeClass('error');
        $('#form_email_errors').hide();
        $('#form_email_errors').html('');
        var form_errors = false;
        if ($('#emc_email').val() && !$('#emc_password').val().match(/^[A-Za-z0-9_\-\$\!\@\#\%\^\&\[\]\{\}\*\+\=\.\,\'\"\|\<\>\?]{5,100}$/)) {
            $('#cg_emc_password').addClass('error');
            $('#form_email_errors').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_password_single + "<br/>");
            form_errors = true;
        }
        if (!$('#emc_email').val() && (!$('#emc_new_password').val() || !$('#emc_new_password').val().match(/^[A-Za-z0-9_\-\$\!\@\#\%\^\&\[\]\{\}\*\+\=\.\,\'\"\|\<\>\?]{8,100}$/) || $('#emc_new_password').val() != $('#emc_new_password_repeat').val())) {
            $('#cg_emc_new_password').addClass('error');
            $('#form_email_errors').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_password_single + "<br/>");
            form_errors = true;
        }
        if ($('#emc_password').val() && !$('#emc_password').val().match(/^[A-Za-z0-9_\-\$\!\@\#\%\^\&\[\]\{\}\*\+\=\.\,\'\"\|\<\>\?]{5,100}$/)) {
            $('#cg_emc_password').addClass('error');
            $('#form_email_errors').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_password_multi + "<br/>");
            form_errors = true;
        }
        if (!$('#emc_new_email').val().match(/^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/) || $('#emc_new_email').val() != $('#emc_new_email_verify').val()) {
            $('#cg_emc_new_email').addClass('error');
            $('#form_email_errors').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_email_multi + "<br/>");
            form_errors = true;
        }
        if ($('#emc_email').val() && $('#emc_new_email').val() == $('#emc_email').val()) {
            $('#cg_emc_new_email').addClass('error');
            $('#form_email_errors').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_email_equals + "<br/>");
            form_errors = true;
        }
        if (form_errors) {
            $('#form_email_errors').fadeIn(400);
            $('#form_email_errors').alert();
            $(window).scrollTop($('#form_email_errors').position().top);
        } else {
            $('#tab_email_form').hide();
            $('#tab_email_ajax').show();
            $.ajax({
                type: 'POST',
                url: '/user/account/email/process',
                data: {
                    emc_new_email: $('#emc_new_email').val(),
                    emc_new_password: $('#emc_new_password').val(),
                    emc_password: $('#emc_password').val()
                },
                dataType: "json",
                success: function (data) {
                    if (data.status == 1) {
                        $('#account_tabs').hide();
                        $('#account_tabs_content').html(js_lang_user_account_email_saved);
                    } else {
                        if (data.errors) {
                            for (var i = 0; i < data.errors.length; i++) {
                                $('#form_email_errors').append("&nbsp;&#9632;&nbsp;&nbsp;" + data.errors[i] + "<br/>");
                            }
                        }
                        $('#form_email_errors').fadeIn(400);
                        $(window).scrollTop($('#form_email_errors').position().top);
                        $('#tab_email_form').show();
                        $('#tab_email_ajax').hide();
                        if (data.fields) {
                            for (var i = 0; i < data.fields.length; i++) {
                                $('#cg_emc_' + data.fields[i]).addClass('error');
                                if (i == 1) {
                                    $('#emc_' + data.fields[i]).focus();
                                }
                            }
                        }
                    }
                },
                error: function () {
                    $('#form_email_errors').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_error_ajax + "<br/>");
                    $('#form_email_errors').fadeIn(400);
                    $(window).scrollTop($('#form_email_errors').position().top);
                    $('#tab_email_form').show();
                    $('#tab_email_ajax').hide();
                }
            });
        }
    }); // btn_submit_email click
    $('#btn_submit_password').bind('click', function () {
        $('#cg_pwd_password').removeClass('error');
        $('#cg_pwd_old_password').removeClass('error');
        $('#form_password_errors').hide();
        $('#form_password_errors').html('');
        var form_errors = false;
        if (password_unset != 1 && !$('#pwd_old_password').val().match(/^[A-Za-z0-9_\-\$\!\@\#\%\^\&\[\]\{\}\*\+\=\.\,\'\"\|\<\>\?]{5,100}$/)) {
            $('#cg_pwd_old_password').addClass('error');
            $('#form_password_errors').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_password_single + "<br/>");
            form_errors = true;
        }
        if (password_unset != 1 && ($('#pwd_password').val().length > 0 && ($('#pwd_password').val() == $('#pwd_old_password').val()))) {
            $('#cg_pwd_new_password').addClass('error');
            $('#form_password_errors').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_password_equals + "<br/>");
            form_errors = true;
        }
        if (!$('#pwd_password').val().match(/^[A-Za-z0-9_\-\$\!\@\#\%\^\&\[\]\{\}\*\+\=\.\,\'\"\|\<\>\?]{8,100}$/) || $('#pwd_password').val() != $('#pwd_password_repeat').val()) {
            $('#cg_pwd_password').addClass('error');
            $('#form_password_errors').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_password_multi + "<br/>");
            form_errors = true;
        }
        if (form_errors) {
            $('#form_password_errors').fadeIn(400);
            $('#form_password_errors').alert();
            $(window).scrollTop($('#form_password_errors').position().top);
        } else {
            $('#tab_password_form').hide();
            $('#tab_password_ajax').show();
            $.ajax({
                type: 'POST',
                url: '/user/account/password/process',
                data: {
                    pwd_password: $('#pwd_password').val(),
                    pwd_old_password: $('#pwd_old_password').val()
                },
                dataType: "json",
                success: function (data) {
                    if (data.status == 1) {
                        $('#tab_password_form').show();
                        $('#tab_password_ajax').hide();
                        $('#pwd_password').val('');
                        $('#pwd_password_repeat').val('');
                        $('#pwd_old_password').val('');
                        $('#pwd_password').focus();
                        $('#form_password_success').show().delay(2000).fadeOut(400);
                        $('#cg_pwd_old_password').show();
                        password_unset = 0;
                    } else {
                        if (data.errors) {
                            for (var i = 0; i < data.errors.length; i++) {
                                $('#form_password_errors').append("&nbsp;&#9632;&nbsp;&nbsp;" + data.errors[i] + "<br/>");
                            }
                        }
                        $('#form_password_errors').fadeIn(400);
                        $(window).scrollTop($('#form_password_errors').position().top);
                        $('#tab_password_form').show();
                        $('#tab_password_ajax').hide();
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
                    $('#form_password_errors').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_error_ajax + "<br/>");
                    $('#form_password_errors').fadeIn(400);
                    $(window).scrollTop($('#form_password_errors').position().top);
                    $('#tab_password_form').show();
                    $('#tab_password_ajax').hide();
                }
            });
        }
    }); // btn_submit_password click
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
    $('#pro_realname,#pro_phone,#pro_password').bind('keypress', function (e) {
       if (submitOnEnter(e)) {
            $('#btn_submit_profile').click();
       }
    });
    $('#emc_email,#emc_new_email,#emc_new_email_verify,#emc_password').bind('keypress', function (e) {
       if (submitOnEnter(e)) {
            $('#btn_submit_email').click();
       }
    });
    $('#pwd_password,#pwd_password_repeat,#pwd_old_password').bind('keypress', function (e) {
       if (submitOnEnter(e)) {
            e.preventDefault();
            $('#btn_submit_password').click();
       }
    });
}); // document.ready