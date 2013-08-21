// Init variables
var edit_id = 0;
var delete_data = new Array();
var dtable;
var mobile_mode = false;
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
// Bind keys
$('input:radio[name="status_select_status"]').bind('keypress', function (e) {
    if (submitOnEnter(e)) {
        $('#btn_status_select_save').click();
    }
});
$('.data-edit-field').bind('keypress', function (e) {
    if (e.keyCode == 13) {
        $('#btn_edit_save').click();
    }
    if (e.keyCode == 27) {
        $('#btn_edit_cancel').click();
    }
});

$(document).ready(function () {
    $().dropdown();
    mobile_mode = $('#mobile_mode').is(":visible");
    var row_id = 0;
    // Init data table
    if (mobile_mode) {
        $('#data_table_mobile').show();
        dtable = $('#data_table_mobile').dataTable({
            "sDom": "frtip",
            "bLengthChange": true,
            "bServerSide": true,
            "bProcessing": true,
            "sPaginationType": "bootstrap",
            "iDisplayLength": 10,
            "bAutoWidth": false,
            "sAjaxSource": "/admin/users/data/list?mobile=true",            
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
                "bSortable": false,
                "aTargets": [3]
            }, {
                "fnRender": function (oObj, sVal) {
                    return '<div style="text-align:center;width:92px"><button type="button" class="btn btn-default btn-sm" onclick="editData(' + row_id + ')"><i style="cursor:pointer" class="glyphicon glyphicon-pencil"></i></button>&nbsp;<button type="button" class="btn btn-danger btn-sm" onclick="deleteData(' + row_id + ')"><i style="cursor:pointer" class="glyphicon glyphicon-trash"></i></span></button>';
                },
                "aTargets": [3]
            }, {
                "fnRender": function (oObj, sVal) {
                    var pic = 'user.png';
                    if (sVal == 0) {
                        pic = 'user_disabled.png';
                    }
                    if (sVal == 2) {
                        pic = 'user_king.png';
                    }
                    return '<div style="text-align:center;cursor:pointer" class="editable_select" onclick="selectStatus(' + row_id + ')" id="status_' + row_id + '"><span style="display:none" id="statusval_' + row_id + '">' + sVal + '</span><img src="/images/' + pic + '" width="16" height="16" alt="" /></div>';
                },
                "aTargets": [2]
            }, {
                "fnRender": function (oObj, sVal) {
                    row_id = sVal;
                    return '<div style="width:100%;text-align:center"><input type="checkbox" name="cbx_' + sVal + '" id="cbx_' + sVal + '"></div>';
                },
                "aTargets": [0]
            }, {
                "fnRender": function (oObj, sVal) {
                    return '<div id="username_' + row_id + '">' + sVal + '</div';
                },
                "aTargets": [1]
            }],
            "fnDrawCallback": function () {
                $('.editable_text').editable(submitEdit, {
                    placeholder: '—',
                    cssclass : 'form-control',                    
                    tooltip: ''
                });
            }
        }); // dtable mobile
    } else {
        $('#data_table').show();
        dtable = $('#data_table').dataTable({
            "sDom": "frtip",
            "bLengthChange": false,
            "bServerSide": true,
            "bProcessing": true,
            "sPaginationType": "bootstrap",
            "iDisplayLength": 30,
            "bAutoWidth": true,
            "sAjaxSource": "/admin/users/data/list",
            "fnInitComplete": function() {
                $('#results tbody tr').each(function(){
                        $(this).find('td:eq(0)').attr('nowrap', 'nowrap');
                });
            },
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
                "bSortable": false,
                "aTargets": [5]
            }, {
                "fnRender": function (oObj, sVal) {
                    return '<div style="text-align:center"><button type="button" class="btn btn-default btn-xs" onclick="editData(' + row_id + ')"><i style="cursor:pointer" class="glyphicon glyphicon-pencil"></i></button>&nbsp;<button type="button" class="btn btn-danger btn-xs" onclick="deleteData(' + row_id + ')"><i style="cursor:pointer" class="glyphicon glyphicon-trash"></i></button></div>';
                },
                "aTargets": [6]
            }, {
                "fnRender": function (oObj, sVal) {
                    var pic = 'user.png';
                    if (sVal == 0) {
                        pic = 'user_disabled.png';
                    }
                    if (sVal == 2) {
                        pic = 'user_king.png';
                    }
                    return '<div style="text-align:center;cursor:pointer" class="editable_select" onclick="selectStatus(' + row_id + ')" id="status_' + row_id + '"><span style="display:none" id="statusval_' + row_id + '">' + sVal + '</span><img src="/images/' + pic + '" width="16" height="16" alt="" /></div>';
                },
                "aTargets": [5]
            }, {
                "fnRender": function (oObj, sVal) {
                    row_id = sVal;
                    return '<input type="checkbox" style="float:left" name="cbx_' + sVal + '" id="cbx_' + sVal + '">&nbsp;' + sVal;
                },
                "aTargets": [0]
            }, {
                "fnRender": function (oObj, sVal) {
                    return '<div id="username_' + row_id + '" class="editable_text">' + sVal + '</div';
                },
                "aTargets": [1]
            }, {
                "fnRender": function (oObj, sVal) {
                    return '<div id="realname_' + row_id + '" class="editable_text">' + sVal + '</div';
                },
                "aTargets": [2]
            }, {
                "fnRender": function (oObj, sVal) {
                    return '<div id="email_' + row_id + '" class="editable_text">' + sVal + '</div';
                },
                "aTargets": [3]
            }, {
                "fnRender": function (oObj, sVal) {
                    return '<div id="phone_' + row_id + '" class="editable_text">' + sVal + '</div';
                },
                "aTargets": [4]
            }],
            "fnDrawCallback": function () {
                $('.editable_text').editable(submitEdit, {
                    placeholder: '—',
                    tooltip: ''
                });
            }
        }); // dtable desktop
    }
    $.fn.dataTableExt.oJUIClasses["sFilter"] = "form-control";
});

function selectStatus(row_id) {
    $('#status_select_username').html($('#username_' + row_id).html());
    $('#status_select').modal({
        keyboard: true
    });
    edit_id = row_id;
    $('input:radio[name="status_select_status"]').filter('[value="' + $('#statusval_' + row_id).html() + '"]').attr('checked', true);
    $("input[name='status_select_status']:checked").focus();
}

function submitEdit(value, settings) {
    var value_old = this.revert;
    var edit_id = this.id;
    if (value_old == value) {
        return (value);
    }
    value = value.replace(/\</g, '&lt;');
    value = value.replace(/\>/g, '&gt;');
    value = value.replace(/\"/g, '&quot;');
    var arr = this.id.split('_');
    $.ajax({
        type: 'POST',
        url: '/admin/users/data/save/field',
        data: {
            field_name: arr[0],
            field_id: arr[1],
            field_value: value
        },
        dataType: "json",
        success: function (data) {
            if (data.result != '1') {
                $('#' + edit_id).html(value_old);
                if (data.error) {
                    $('#error_dialog_msg').html(data.error);
                    $('#error_dialog').modal({
                        keyboard: true
                    });
                }
            }
        },
        error: function () {
            $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
        }
    });
    return (value);
}
// "Add" button handler (form mode)
$('#btn_add').click(function () {
    edit_id = 0;
    $('#label_password').html(js_lang_password + "&nbsp;<span class=required_field>*</span>");
    $('#form_error_msg').hide();
    $('#data_overview').hide();
    resetFormState();
    $('#data_edit').show();
    $('#h_data_actions').html(js_lang_add_user);
    $('#form_notice').html(js_lang_form_notice_add);
    $('#username').val('');
    $('#password').val('');
    $('#password_repeat').val('');
    $('#realname').val('');
    $('#groups').val('');
    $('#email').val('');
    $('#phone').val('');
    $('input:radio[name="status"]').filter('[value="1"]').attr('checked', true);
    $('#username').focus();
});
// "Cancel" button handler (form mode)
$('#btn_edit_cancel').click(function () {
    $('#data_overview').show();
    $('#data_edit').hide();
});
// "Save" button handler (status select dialog mode)
$('#btn_status_select_save').click(function () {
    $.ajax({
        type: 'POST',
        url: '/admin/users/data/save/field',
        data: {
            field_name: "status",
            field_id: edit_id,
            field_value: $("input[name='status_select_status']:checked").val()
        },
        dataType: "json",
        success: function (data) {
            if (data.result != '1') {
                if (data.error) {
                    $('#error_dialog_msg').html(data.error);
                    $('#error_dialog').modal({
                        keyboard: true
                    });
                }
            } else {
                var sVal = $("input[name='status_select_status']:checked").val();
                var pic = 'user.png';
                if (sVal == 0) {
                    pic = 'user_disabled.png';
                }
                if (sVal == 2) {
                    pic = 'user_king.png';
                }
                $('#status_' + edit_id).html('<span style="display:none" id="statusval_' + edit_id + '">' + sVal + '</span><img src="/images/' + pic + '" width="16" height="16" alt="" />');
            }
        },
        error: function () {
            $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
        }
    });
    $('#status_select').modal('hide');
});
// "Abort" button handler (form mode)
$('#btn_edit_save').click(function () {
    $('#form_error_msg').hide();
    resetFormState();
    var errors = false;
    if (!$('#username').val().match(/^[A-Za-z0-9_\-\.]{1,100}$/)) {
        $('#cg_username').addClass('error');
        errors = true;
    }
    if ($('#password').val() != $('#password_repeat').val()) {
        $('#cg_password').addClass('error');
        errors = true;
        $('#password_hint').html(js_lang_password_mismatch);
    } else {
        if ((edit_id != 0 && $('#password').val().length > 0) || edit_id == 0) {
            if (!$('#password').val().match(/^[A-Za-z0-9_\-\$\!\@\#\%\^\&\[\]\{\}\*\+\=\.\,\'\"\|\<\>\?]{6,100}$/) || !$('#password_repeat').val().match(/^[A-Za-z0-9_\-\$\!\@\#\%\^\&\[\]\{\}\*\+\=\.\,\'\"\|\<\>\?]{6,100}$/)) {
                $('#cg_password').addClass('error');
                errors = true;
            }
        }
    }
    if ($('#email').val() && !$('#email').val().match(/^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/)) {
        $('#cg_email').addClass('error');
        errors = true;
    }
    if (!$('#phone').val().match(/^[0-9]{0,40}$/)) {
        $('#cg_phone').addClass('error');
        errors = true;
    }
    if (!$('#realname').val().match(/^.{0,80}$/)) {
        $('#cg_realname').addClass('error');
        errors = true;
    }
    if (!$('#groups').val().match(/^[A-Za-z0-9_\-\.\, ]{0,254}$/)) {
        $('#cg_groups').addClass('error');
        errors = true;
    }
    if (errors) {
        $('#form_error_msg_text').html(js_lang_form_errors);
        $('#form_error_msg').fadeIn(400);
        $('#form_error_msg').alert();
    } else {
        $('#data_edit_form').hide();
        $('#data_edit_form_buttons').hide();
        $('#ajax_loading_msg').html(js_lang_ajax_saving);
        $('#ajax_loading').show();
        return;
        $.ajax({
            type: 'POST',
            url: '/admin/users/data/save',
            data: {
                id: edit_id,
                username: $('#username').val(),
                password: $('#password').val(),
                email: $('#email').val(),
                phone: $('#phone').val(),
                realname: $('#realname').val(),
                groups: $('#groups').val(),
                banned: $('#banned').is(':checked'),
                status: $("input[name='status']:checked").val()
            },
            dataType: "json",
            success: function (data) {
                if (data.result == '0') {
                    if (data.error) { // ERROR
                        $('#form_error_msg_text').html(data.error);
                        $('#form_error_msg').fadeIn(400);
                        $('#form_error_msg').alert();
                    }
                    $('#data_edit_form').show();
                    $('#data_edit_form_buttons').show();
                    $('#ajax_loading').hide();
                    if (data.field) {
                        $('#cg_' + data.field).addClass('error');
                        $('#' + data.field).focus();
                    }
                } else { // OK
                    $('#data_edit_form').show();
                    $('#data_edit_form_buttons').show();
                    $('#ajax_loading').hide();
                    resetFormState();
                    $('#data_edit').hide();
                    $('#data_overview').show();
                    if (edit_id == 0) {
                        $.jmessage(js_lang_success, js_lang_add_success_notify, 2500, 'jm_message_success');
                    } else {
                        $.jmessage(js_lang_success, js_lang_edit_success_notify, 2500, 'jm_message_success');
                    }
                    dtable.fnReloadAjax();
                }
            },
            error: function () {
                $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
                $('#data_edit_form').show();
                $('#data_edit_form_buttons').show();
                $('#ajax_loading').hide();
            }
        });
    }
});
// "Abort" button handler
$('#btn_abort').click(function () {
    $('#btn_abort').hide();
    $('#data_edit_form').show();
    $('#data_edit_form_buttons').show();
    $('#ajax_loading').hide();
    $('#form_controls').show();
    resetFormState();
    $('#data_edit').hide();
    $('#data_overview').show();
});
// Edit record
function editData(id) {
    edit_id = id;
    $('#label_password').html(js_lang_password);
    $('#form_error_msg').hide();
    $('#data_overview').hide();
    resetFormState();
    $('#data_edit').show();
    $('#h_data_actions').html(js_lang_edit_user);
    $('#form_notice').html(js_lang_form_notice_edit);
    $('#username').val('');
    $('#password').val('');
    $('#password_repeat').val('');
    $('#realname').val('');
    $('#groups').val('');
    $('#email').val('');
    $('#phone').val('');
    $('input:radio[name="status"]').filter('[value="1"]').attr('checked', true);
    $('#data_edit_form').hide();
    $('#data_edit_form_buttons').hide();
    $('#ajax_loading_msg').html(js_lang_ajax_loading);
    $('#ajax_loading').show();
    $.ajax({
        type: 'POST',
        url: '/admin/users/data/load',
        data: {
            id: edit_id
        },
        dataType: "json",
        success: function (data) {
            if (data.result == '0') {
                $('#form_error_msg_text').html(js_lang_data_loading_error);
                $('#form_error_msg').fadeIn(400);
                $('#form_error_msg').alert();
                $('#ajax_loading').hide();
                $('#data_edit_form').show();
                $('#form_controls').hide();
                $('#btn_abort').show();
            } else { // OK
                $('#ajax_loading').hide();
                $('#data_edit_form').show();
                $('#form_controls').show();
                $('#data_edit_form_buttons').show();
                $('#password_hint').html(js_lang_password_hint_edit);
                if (data.username) {
                    $('#username').val(data.username);
                }
                if (data.email) {
                    $('#email').val(data.email);
                }
                if (data.phone) {
                    $('#phone').val(data.phone);
                }
                if (data.realname) {
                    $('#realname').val(data.realname);
                }
                if (data.groups) {
                    $('#groups').val(data.groups);
                }
                if (data.status) {
                    $('input:radio[name="status"]').filter('[value="' + data.status + '"]').attr('checked', true);
                }
                if (data.banned && data.banned != 0) {
                    $('#banned_till').html(data.banned);
                    $('#banned').attr('checked', true);
                } else {
                    $('#banned_till').html('');
                    $('#banned').attr('checked', false);
                }
                $('#username').focus();
            }
        },
        error: function () {
            $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
            $('#ajax_loading').hide();
            $('#data_edit_form').show();
            $('#form_controls').hide();
            $('#btn_abort').show();
        }
    });
}
// Button "Cancel" handler (Dialog: "Delete")
$('#btn_delete_cancel').click(function () {
    $('#delete_confirmation').modal('hide');
});
// Button "Close" handler (Dialog: "Error")
$('#btn_error_dialog_close').click(function () {
    $('#error_dialog').modal('hide');
});
// Button "Delete" handler (Dialog: "Delete")
$('#btn_delete').click(function () {
    $('#delete_confirmation').modal('hide');
    $.ajax({
        type: 'POST',
        url: '/admin/users/data/delete',
        data: {
            'delete_data': delete_data
        },
        dataType: "json",
        success: function (data) {
            if (data.result == '0') {
                $('#error_dialog_msg').html(js_lang_delete_error_notify);
                $('#error_dialog').modal({
                    keyboard: true
                });
            } else { // OK
                $.jmessage(js_lang_success, js_lang_delete_success_notify, 2500, 'jm_message_success');
            }
            dtable.fnReloadAjax();
        },
        error: function () {
            $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
        }
    });
});
// Button "Delete selected" handler
$('#btn_delete_all').click(function () {
    delete_data = [];
    if (mobile_mode) {
        $('#data_table_mobile input:checked').each(function () {
            var cbx = $(this).attr('name');
            cbx = cbx.replace('cbx_', '');
            delete_data.push(cbx);
        });
    } else {
        $('#data_table input:checked').each(function () {
            var cbx = $(this).attr('name');
            cbx = cbx.replace('cbx_', '');
            delete_data.push(cbx);
        });
    }
    if (delete_data.length == 0) {
        $('#none_selected').modal({
            keyboard: false
        });
        return;
    }
    var user_names = new Array();
    for (var key in delete_data) {
        var val = delete_data[key];
        user_names.push($('#username_' + val).html())
    }
    $('#delete_row_list').html(user_names.join(', '));
    $('#delete_confirmation').modal({
        keyboard: false
    });
});
// Button "Close" in "None selected" dialog
$('#btn_none_selected_close').click(function () {
    $('#none_selected').modal('hide');
});
// Button "Close" in "Status select" dialog
$('#btn_status_select_close').click(function () {
    $('#status_select').modal('hide');
});
// Open "Delete" dialog window
function deleteData(id) {
    delete_data = [id];
    var username = $('#username_' + id).html();
    $('#delete_row_list').html(username);
    $('#delete_confirmation').modal({
        keyboard: false
    });
}
// Remove all "error" notification classes from form items
function resetFormState() {
    $('#cg_username').removeClass('error');
    $('#cg_password').removeClass('error');
    $('#cg_email').removeClass('error');
    $('#cg_phone').removeClass('error');
    $('#cg_realname').removeClass('error');
    $('#cg_groups').removeClass('error');
    $('#password_hint').html(js_lang_password_hint);
}
// dataTable ajax fix
jQuery.fn.dataTableExt.oApi.fnProcessingIndicator = function ( oSettings, onoff ) {
    if ( typeof( onoff ) == 'undefined' ) {
        onoff = true;
    }
    this.oApi._fnProcessingDisplay( oSettings, onoff );
};
function handleDTAjaxError( xhr, textStatus, error ) {
    $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');   
    dtable.fnProcessingIndicator( false );
}