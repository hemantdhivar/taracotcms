// Init variables
var dtable;
var history_edit_id = 0;
$(document).ready(function () {
    $().dropdown();
    var row_id = 0;
    $('#data_table').show();
    dtable = $('#data_table').dataTable({
        "sDom": "frtip",
        "bLengthChange": false,
        "bServerSide": true,
        "bProcessing": true,
        "aaSorting": [
            [3, "desc"]
        ],
        "sPaginationType": "bootstrap",
        "iDisplayLength": 30,
        "bAutoWidth": false,
        "sAjaxSource": "/admin/billing/funds/data/list?id=" + js_user_id,
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
        "fnServerData": function (sSource, aoData, fnCallback) {
            $.getJSON(sSource, aoData, function (json) {
                if (json.history_ids) {
                    var trans_ids = '<option value="">&mdash;</option>';
                    for (var i = 0; i < json.history_ids.length; i++) {
                        trans_ids += '<option value="' + json.history_ids[i] + '">' + json.history_names[i] + '</option>';
                    }
                    $('#trans_id').html(trans_ids);
                }
                fnCallback(json);
            });
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
            "aTargets": [4]
        }, {
            "bVisible": false,
            "aTargets": [0]
        }, {
            "fnRender": function (oObj, sVal) {
                return '<div style="text-align:center"><span class="btn btn-sm btn-default" onclick="editData(' + row_id + ')"><i style="cursor:pointer" class="glyphicon glyphicon-pencil"></i></span>&nbsp;<span class="btn btn-sm btn-danger" onclick="deleteData(' + row_id + ')"><i style="cursor:pointer" class="glyphicon glyphicon-trash"></i></span></div>';
            },
            "aTargets": [4]
        }, {
            "fnRender": function (oObj, sVal) {
                row_id = sVal;
                return sVal;
            },
            "aTargets": [0]
        }, {
            "fnRender": function (oObj, sVal) {
                return '<div id="reason_' + row_id + '">' + sVal + '</div';
            },
            "aTargets": [1]
        }, {
            "fnRender": function (oObj, sVal) {
                var pic = '/images/plus.png';
                if (sVal < 0) {
                    pic = '/images/minus.png';
                    sVal = -sVal;
                }
                return '<div style="text-align:center"><img src="' + pic + '" width="16" height="16" alt="" />&nbsp;<span id="amount_' + row_id + '">' + sVal + '</span></div>';
            },
            "aTargets": [2]
        }, {
            "fnRender": function (oObj, sVal) {
                return '<div id="date_' + row_id + '" style="text-align:center">' + sVal + '</div';
            },
            "aTargets": [3]
        }]
    }); // dtable desktop
});
// Button "Close" handler (Dialog: "History edit")
$('#btn_history_dialog_close').click(function () {
    $('#history_edit_dialog').modal('hide');
});
// Add history account button event handler
$('#btn_add').click(function () {
    $('#cg_trans_id').removeClass('has-error');
    $('#cg_trans_objects').removeClass('has-error');
    $('#cg_trans_amount').removeClass('has-error');
    $('#cg_trans_date').removeClass('has-error');
    $('#cg_trans_time').removeClass('has-error');
    $('#history_edit_form_error').hide();
    $('#history_edit_ajax').hide();
    $('#history_edit_form').show();
    $('#history_edit_buttons').show();
    $('#trans_objects').val('');
    $('#trans_amount').val('');
    $('#trans_date').val('');
    $('#trans_time').val('');
    $('select option:first-child').attr("selected", "selected");
    $('#history_edit_dialog_title').html(js_lang_add_history_record);
    $('#history_edit_dialog').modal({
        keyboard: true
    });
    $('#trans_id').focus();
    history_edit_id = 0;
});
// Edit history
function editData(id) {
    $('#cg_trans_id').removeClass('has-error');
    $('#cg_trans_objects').removeClass('has-error');
    $('#cg_trans_amount').removeClass('has-error');
    $('#cg_trans_date').removeClass('has-error');
    $('#cg_trans_time').removeClass('has-error');
    $('#history_edit_form_error').hide();
    $('#history_edit_form').hide();
    $('#history_edit_buttons').hide();
    $('#trans_objects').val('');
    $('#trans_amount').val('');
    $('#trans_date').val('');
    $('#trans_time').val('');
    $('select option:first-child').attr("selected", "selected");
    $('#history_edit_dialog_title').html(js_lang_btn_edit_history_record);
    $('#history_edit_ajax_msg').html(js_lang_ajax_loading);
    $('#history_edit_ajax').show();
    $('#history_edit_dialog').modal({
        keyboard: true
    });
    history_edit_id = id;
    $.ajax({
        type: 'POST',
        url: '/admin/billing/data/funds/history/load',
        data: {
            id: history_edit_id
        },
        dataType: "json",
        success: function (data) {
            if (data.result == '0') {
                $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
                $('#history_edit_dialog').modal('hide');
            } else { // OK
                if (data.trans_id) {
                    $("#trans_id option[value='" + data.trans_id + "']").attr("selected", true);
                }
                if (data.trans_objects) {
                    $('#trans_objects').val(data.trans_objects);
                }
                if (data.trans_amount) {
                    $('#trans_amount').val(data.trans_amount);
                }
                if (data.trans_date) {
                    $('#trans_date').val(data.trans_date);
                }
                if (data.trans_time) {
                    $('#trans_time').val(data.trans_time);
                }
                $('#history_edit_ajax').hide();
                $('#history_edit_form').show();
                $('#history_edit_buttons').show();
                $('#ajax_loading').hide();
                $('#trans_id').focus();
            }
        },
        error: function () {
            $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
            $('#history_edit_dialog').modal('hide');
        }
    });
};
// Add/edit history record save button click event
$('#btn_history_dialog_save').click(function () {
    $('#cg_trans_id').removeClass('has-error');
    $('#cg_trans_objects').removeClass('has-error');
    $('#cg_trans_amount').removeClass('has-error');
    $('#cg_trans_date').removeClass('has-error');
    $('#cg_trans_time').removeClass('has-error');
    $('#history_edit_form_error').hide();
    var errors = false;
    if (!$('#trans_objects').val().match(/^.{0,250}$/)) {
        $('#cg_trans_objects').addClass('has-error');
        errors = true;
    }
    if (!$('#trans_amount').val().match(/^[0-9\.\-]{1,7}$/)) {
        $('#cg_trans_amount').addClass('has-error');
        errors = true;
    }
    if (!$('#trans_date').val().match(/^[0-9\.\/\-]{1,20}$/)) {
        $('#cg_trans_date').addClass('has-error');
        errors = true;
    }
    if (!$('#trans_time').val().match(/^[0-9APM\.\: ]{1,11}$/)) {
        $('#cg_trans_time').addClass('has-error');
        errors = true;
    }
    if (errors) {
        $('#history_edit_form_error_text').html(js_lang_form_errors);
        $('#history_edit_form_error').fadeIn(400);
        $('#history_edit_form_error').alert();
        $('#history_name').focus();
    } else {
        $('#history_edit_ajax_msg').html(js_lang_ajax_saving);
        $('#history_edit_ajax').show();
        $('#history_edit_form').hide();
        $('#history_edit_buttons').hide();
        $.ajax({
            type: 'POST',
            url: '/admin/billing/data/funds/history/save',
            data: {
                id: history_edit_id,
                user_id: js_user_id,
                trans_id: $('#trans_id').val(),
                trans_objects: $('#trans_objects').val(),
                trans_amount: $('#trans_amount').val(),
                trans_date: $('#trans_date').val() + ' ' + $('#trans_time').val()
            },
            dataType: "json",
            success: function (data) {
                if (data.result == '0') {
                    if (data.error) { // ERROR
                        $('#history_edit_form_error_text').html(data.error);
                        $('#history_edit_form_error').fadeIn(400);
                        $('#history_edit_form_error').alert();
                    }
                    $('#history_edit_ajax').hide();
                    $('#history_edit_form').show();
                    $('#history_edit_buttons').show();
                    $('#ajax_loading').hide();
                    if (data.field) {
                        $('#cg_' + data.field).addClass('has-error');
                        $('#' + data.field).focus();
                    }
                } else { // OK
                    $.jmessage(js_lang_success, js_lang_data_saved, 2500, 'jm_message_success');
                    dtable.fnReloadAjax();
                    $('#history_edit_dialog').modal('hide');
                }
            },
            error: function () {
                $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
                $('#history_edit_ajax').hide();
                $('#history_edit_form').show();
                $('#history_edit_buttons').show();
            }
        });
    }
});

function deleteData(id) {
    if (!confirm(js_lang_data_delete_confirm + ":\n\n" + $('#reason_' + id).html())) {
        return false;
    }
    $('#data_table_cover').css('left', $('#data_table').position().left+'px');
    $('#data_table_cover').css('top', $('#data_table').position().top+'px');
    $('#data_table_cover').css('width', $('#data_table').width()+'px');
    $('#data_table_cover').css('height', $('#data_table').height()+2+'px');
    $('#data_table_cover').fadeIn(300);
    dtable.fnProcessingIndicator();
    $.ajax({
        type: 'POST',
        url: '/admin/billing/data/funds/history/delete',
        data: {
            id: id
        },
        dataType: "json",
        success: function (data) {
            $('#data_table_cover').fadeOut(300);
            dtable.fnProcessingIndicator('off');
            if (data.result == '0') {
                $.jmessage(js_lang_error, js_lang_data_delete_error, 2500, 'jm_message_error');
            } else { // OK         
                $.jmessage(js_lang_success, js_lang_data_delete_ok, 2500, 'jm_message_success');
                dtable.fnReloadAjax();
            }
        },
        error: function () {
            $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
            $('#data_table_cover').fadeOut(300);
            dtable.fnProcessingIndicator('off');
        }
    });
}

// dataTable extensions
jQuery.fn.dataTableExt.oApi.fnProcessingIndicator = function ( oSettings, onoff ) {
    if ( typeof( onoff ) == 'undefined' ) {
        onoff = true;
    }
    this.oApi._fnProcessingDisplay( oSettings, onoff );
};
jQuery.fn.dataTableExt.oApi.fnProcessingIndicator = function ( oSettings, onoff )
{
    if( typeof(onoff) == 'undefined' )
    {
        onoff=true;
    }
    this.oApi._fnProcessingDisplay( oSettings, onoff );
};
function handleDTAjaxError( xhr, textStatus, error ) {
    $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');   
    dtable.fnProcessingIndicator( false );
}