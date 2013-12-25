var dtable;
$(document).ready(function () {
    dtable = $('#posts_table').dataTable({
            "sDom": "frtip",
            "bLengthChange": false,
            "bServerSide": true,
            "bProcessing": true,
            "sPaginationType": "bootstrap",
            "iDisplayLength": 30,
            "bAutoWidth": false,
            "sAjaxSource": "/user/posts/data/list",
            "fnServerData": function ( sSource, aoData, fnCallback ) {
                $.ajax( {
                    "dataType": 'json',
                    "type": "GET",
                    "url": sSource,
                    "data": aoData,
                    "success": fnCallback,
                    "timeout": 15000,
                    "error": handleDTAjaxError
                } );
            },
            "oLanguage": {
                "oPaginate": {
                    "sPrevious": js_lang_sPrevious,
                    "sNext": js_lang_sNext
                },
                "sLengthMenu": js_lang_sLengthMenu,
                "sZeroRecords": js_lang_sZeroRecords,
                "sInfo": js_lang_sInfo,
                "sInfoEmpty": js_lang_sInfoEmpty,
                "sInfoFiltered": js_lang_sInfoFiltered,
                "sSearch": js_lang_sSearch + ":&nbsp;",
            },
            "aoColumnDefs": [{
                "fnRender": function (oObj, sVal) {
                    row_id = sVal;
                    return sVal;
                },
                "aTargets": [0]
            }, {
                "fnRender": function (oObj, sVal) {
                    return sVal;
                },
                "aTargets": [1]
            }, {
                "fnRender": function (oObj, sVal) {
                    return '<img src="/images/flags/' + sVal + '.png" width="16" height="11" alt="" />&nbsp;' + langs.getItem(sVal);
                },
                "aTargets": [2]
            }, {
                "fnRender": function (oObj, sVal) {
                    var _dt = sVal * 1000;
                    var _sv = moment.unix(sVal).format(js_lang_datetime_format);
                    return '<div style="text-align:center">'+_sv+'</div>';
                },
                "aTargets": [3]
            }, {
                "fnRender": function (oObj, sVal) {
                    return statuses.getItem(sVal);
                },
                "aTargets": [4]
            }],
            "fnRowCallback": function( nRow, aData, iDisplayIndex ) {
                $(nRow).on('click', function() {
                    // alert(aData[0]);
                });    
                nRow.className = 'blog-posts-table-tr';                            
                return nRow;
            }

    }); // dtable desktop
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
    if (password_unset == "1") {
        $('#cg_pwd_old_password').hide();
    }
    var uploader;
    $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
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
        $('#cg_pro_realname').removeClass('has-error');
        $('#cg_pro_phone').removeClass('has-error');
        $('#cg_pro_password').removeClass('has-error');
        $('#form_profile_success').hide();
        $('#form_profile_errors').hide();
        $('#form_profile_errors').html('');
        var form_errors = false;
        if (!$('#pro_password').val().match(/^[A-Za-z0-9_\-\$\!\@\#\%\^\&\[\]\{\}\*\+\=\.\,\'\"\|\<\>\?]{5,100}$/)) {
            $('#cg_pro_password').addClass('has-error');
            $('#form_profile_errors').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_password_single + "<br/>");
            form_errors = true;
            $('#pro_password').focus();
        }
        if (!$('#pro_realname').val().match(/^.{0,80}$/)) {
            $('#cg_pro_realname').addClass('has-error');
            $('#form_profile_errors').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_realname + "<br/>");
            if (!form_errors) {
                $('#pro_realname').focus();
            }
            form_errors = true;
        }
        if (!$('#pro_phone').val().match(/^[0-9\-\(\)\s]{0,40}$/)) {
            $('#cg_pro_phone').addClass('has-error');
            $('#form_profile_errors').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_phone + "<br/>");
            if (!form_errors) {
                $('#pro_phone').focus();
            }
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
                        if ($('#pro_phone').val() != '') {
                            $('#overview_phone').html('+' + $('#pro_phone').val());
                        } else {
                            $('#overview_phone').html('—');
                        }
                        if ($('#pro_realname').val()) {
                            $('#overview_realname').html($('#pro_realname').val());
                        } else {
                            $('#overview_realname').html(js_auth_data_username);
                        }
                        if (data.avatar_changed == 1) {
                            $("#avatar_profile_img").attr("src", "/files/avatars/"+js_auth_data_username+".jpg?" + Math.random());
                            $("#avatar_overview_img").attr("src", "/files/avatars/"+js_auth_data_username+".jpg?" + Math.random());
                        }
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
                                $('#cg_pro_' + data.fields[i]).addClass('has-error');
                                if (i == 0) {
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
    $('#btn_submit_email').click(function () {
        $('#cg_emc_new_email').removeClass('has-error');
        $('#cg_emc_password').removeClass('has-error');
        $('#form_email_errors').hide();
        $('#form_email_errors').html('');
        var form_errors = false;        
        if (!$('#emc_email').val() && (!$('#emc_new_password').val() || !$('#emc_new_password').val().match(/^[A-Za-z0-9_\-\$\!\@\#\%\^\&\[\]\{\}\*\+\=\.\,\'\"\|\<\>\?]{8,100}$/) || $('#emc_new_password').val() != $('#emc_new_password_repeat').val())) {            
            $('#cg_emc_new_password').addClass('has-error');
            $('#form_email_errors').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_password_single + "<br/>");
            if (!form_errors) {
                $('#emc_new_password').focus();
            }
            form_errors = true;
        }
        if ($('#emc_password').val() && !$('#emc_password').val().match(/^[A-Za-z0-9_\-\$\!\@\#\%\^\&\[\]\{\}\*\+\=\.\,\'\"\|\<\>\?]{5,100}$/)) {
            $('#cg_emc_password').addClass('has-error');
            $('#form_email_errors').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_password_multi + "<br/>");
            if (!form_errors) {
                $('#emc_password').focus();
            }
            form_errors = true;
        }
        if (!$('#emc_new_email').val().match(/^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/) || $('#emc_new_email').val() != $('#emc_new_email_verify').val()) {
            $('#cg_emc_new_email').addClass('has-error');
            $('#form_email_errors').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_email_multi + "<br/>");            
            $('#emc_new_email').focus();
            form_errors = true;
        }
        if ($('#emc_email').val() && $('#emc_new_email').val() == $('#emc_email').val()) {
            $('#cg_emc_new_email').addClass('has-error');
            $('#form_email_errors').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_email_equals + "<br/>");
            if (!form_errors) {
                $('#emc_email').focus();
            }
            form_errors = true;
        }
        if ($('#emc_email').val() && !$('#emc_password').val().match(/^[A-Za-z0-9_\-\$\!\@\#\%\^\&\[\]\{\}\*\+\=\.\,\'\"\|\<\>\?]{5,100}$/)) {
            $('#cg_emc_password').addClass('has-error');
            $('#form_email_errors').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_password_single + "<br/>");
            if (!form_errors) {
                $('#emc_password').focus();
            }
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
                                $('#cg_emc_' + data.fields[i]).addClass('has-error');
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
        $('#cg_pwd_password').removeClass('has-error');
        $('#cg_pwd_old_password').removeClass('has-error');
        $('#form_password_errors').hide();
        $('#form_password_errors').html('');
        var form_errors = false;
        if (!$('#pwd_password').val().match(/^.{8,100}$/) || $('#pwd_password').val() != $('#pwd_password_repeat').val()) {
            $('#cg_pwd_password').addClass('has-error');
            $('#form_password_errors').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_password_multi + "<br/>");
            if (!form_errors) {
                $('#pwd_password').focus();
            }
            form_errors = true;
        }
        if (password_unset != 1 && !$('#pwd_old_password').val().match(/^.{5,100}$/)) {
            $('#cg_pwd_old_password').addClass('has-error');
            $('#form_password_errors').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_password_single + "<br/>");
            if (!form_errors) {
                $('#pwd_old_password').focus();
            }
            form_errors = true;
        }
        if (password_unset != 1 && ($('#pwd_password').val().length > 0 && ($('#pwd_password').val() == $('#pwd_old_password').val()))) {
            $('#cg_pwd_new_password').addClass('has-error');
            $('#form_password_errors').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_user_register_error_password_equals + "<br/>");
            if (!form_errors) {
                $('#pwd_new_password').focus();
            }
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
                                $('#cg_pwd_' + data.fields[i]).addClass('has-error');
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
    $('#emc_new_email_verify').bind('copy paste', function (e) {
       e.preventDefault();
    });
    function handleDTAjaxError( xhr, textStatus, error ) {
        //$.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');   
        dtable.fnProcessingIndicator( false );
    }      
}); // document.ready
jQuery.fn.dataTableExt.oApi.fnProcessingIndicator = function ( oSettings, onoff ) {
        if ( typeof( onoff ) == 'undefined' ) {
            onoff = true;
        }
        this.oApi._fnProcessingDisplay( oSettings, onoff );
};