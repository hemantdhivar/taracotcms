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
    var row_id = 0;
    // Init data table
    $('#data_table').show();
    dtable = $('#data_table').dataTable({
        "sDom": "frtip",
        "bLengthChange": false,
        "bServerSide": true,
        "bProcessing": true,
        "sPaginationType": "bootstrap",
        "iDisplayLength": 10,
        "bAutoWidth": true,
        "sAjaxSource": "/admin/firewall/data/list",
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
        "aoColumnDefs": [
            {
                "bSortable": false,
                "aTargets": [3]
            }, 
            {
                "fnRender": function (oObj, sVal) {
                    return '<div style="text-align:center"><button type="button" class="btn btn-default btn-xs" onclick="editData(' + row_id + ')"><i style="cursor:pointer" class="glyphicon glyphicon-pencil"></i></button>&nbsp;<button type="button" class="btn btn-danger btn-xs" onclick="deleteData(' + row_id + ')"><i style="cursor:pointer" class="glyphicon glyphicon-trash"></i></button></div>';
                },
                "aTargets": [3]
            }, 
            {
                "fnRender": function (oObj, sVal) {
                    if (sVal == 0) {
                    pic = 'lamp_off.png';
                    }
                    if (sVal == 1) {
                    pic = 'lamp_on.png';
                    }
                    return '<div style="text-align:center;cursor:pointer" class="editable_select" onclick="selectStatus(' + row_id + ')" id="status_' + row_id + '"><span style="display:none" id="statusval_' + row_id + '">' + sVal + '</span><img src="/images/' + pic + '" width="16" height="16" alt="" /></div>';
                },
                "aTargets": [2]
            }, 
            {
                "fnRender": function (oObj, sVal) {
                    row_id = sVal;
                    return '<input type="checkbox" style="float:left" name="cbx_' + sVal + '" id="cbx_' + sVal + '">&nbsp;' + sVal;
                },
                "aTargets": [0]
            }, 
            {
                "fnRender": function (oObj, sVal) {
                    return '<div id="ipaddr_' + row_id + '" class="editable_text">' + sVal + '</div';
                },
                "aTargets": [1]
            }
        ],
        "fnDrawCallback": function () {
        $('.editable_text').editable(submitEdit, {
            placeholder: '—',
            tooltip: ''
        });
        }
    }); // dtable desktop
});

function selectStatus(row_id) {
    $('#status_select_ipaddr').html($('#ipaddr_' + row_id).html());
    $('#status_select').modal({
        keyboard: true
    });
    edit_id = row_id;
    if ($('#statusval_' + row_id).html() == 0) {
        $('#status_select_radio_status_disabled').prop('checked', true);
        $('#status_select_radio_status_disabled').focus();
    }
    if ($('#statusval_' + row_id).html() == 1) {
        $('#status_select_radio_status_normal').prop('checked', true);
        $('#status_select_radio_status_normal').focus();
    }
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
        url: '/admin/firewall/data/save/field',
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
    $('#form_error_msg').hide();
    $('#data_overview').hide();
    resetFormState();
    $('#data_edit').show();
    $('#h_data_actions').html(js_lang_add_record);
    $('#form_notice').html(js_lang_form_notice_add);
    $('#ipaddr').val('');
    $('#status_select_radio_status_disabled').prop('checked', true);    
    $('input:radio[name="status"]').filter('[value="0"]').prop('checked', true);
    $('#ipaddr').focus();
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
        url: '/admin/firewall/data/save/field',
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
                var pic = 'lamp_on.png';
                if (sVal == 0) {
                    pic = 'lamp_off.png';
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
    if (!$('#ipaddr').val().match(/^[A-Fa-f0-9\.\:]{1,45}$/)) {
        $('#cg_ipaddr').addClass('error');
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
        $.ajax({
            type: 'POST',
            url: '/admin/firewall/data/save',
            data: {
                id: edit_id,
                ipaddr: $('#ipaddr').val(),                
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
    $.history.push("edit_"+id);
    edit_id = id;
    $('#form_error_msg').hide();
    $('#data_overview').hide();
    resetFormState();
    $('#data_edit').show();
    $('#h_data_actions').html(js_lang_edit_record);
    $('#form_notice').html(js_lang_form_notice_edit);
    $('#ipaddr').val('');
    $('#data_edit_form').hide();
    $('#data_edit_form_buttons').hide();
    $('#ajax_loading_msg').html(js_lang_ajax_loading);
    $('#ajax_loading').show();
    $.ajax({
        type: 'POST',
        url: '/admin/firewall/data/load',
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
                if (data.ipaddr) {
                    $('#ipaddr').val(data.ipaddr);
                }
                if (data.status) {
                    if (data.status == 0) {
                        $('#status_select_radio_status_disabled').prop('checked', true);
                    }
                    if (data.status == 1) {
                        $('#status_select_radio_status_normal').prop('checked', true);
                    }
                    $('input:radio[name="status"]').filter('[value="' + data.status + '"]').prop('checked', true);
                }
                $('#ipaddr').focus();
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
        url: '/admin/firewall/data/delete',
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
        user_names.push($('#ipaddr_' + val).html())
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
    var ipaddr = $('#ipaddr_' + id).html();
    $('#delete_row_list').html(ipaddr);
    $('#delete_confirmation').modal({
        keyboard: false
    });
}
// Remove all "error" notification classes from form items
function resetFormState() {
    $('#cg_ipaddr').removeClass('error');
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
$.history.on('change', function(event, url, type) {
    if (url == '') {       
       $('#btn_edit_cancel').click(); 
    }
}).listen('hash');