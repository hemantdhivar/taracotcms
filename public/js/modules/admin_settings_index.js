// Init variables
var edit_id = 0;
var delete_data = new Array();
var dtable;
var edit_mode = 'ck';
var mobile_mode = $('#mobile_mode').is(":visible");
// Bind Enter key 
$('#language_select_lang').bind('keypress', function (e) {
    if (e.keyCode == 13) {
        $('#btn_language_select_save').click();
    }
});
$('#layout_select_layout').bind('keypress', function (e) {
    if (e.keyCode == 13) {
        $('#btn_layout_select_save').click();
    }
});
$('input:radio[name="status_select_status"]').bind('keypress', function (e) {
    if (e.keyCode == 13) {
        $('#btn_status_select_save').click();
    }
});
// Check all, uncheck all functions
jQuery.fn.checkAll = function (name) {
    var selector = ':checkbox' + (name ? '[@name=' + name + ']' : '');
    $(selector, this).attr('checked', true);
}
jQuery.fn.uncheckAll = function (name) {
    var selector = ':checkbox' + (name ? '[@name=' + name + ']' : '');
    $(selector, this).removeAttr('checked');
}
$(document).ready(function () {
    $().dropdown();
    var row_id = 0;
    // Init CkEditor
    $('#wysiwyg_editor').ckeditor({
        filebrowserBrowseUrl: '/admin/imgbrowser'
    });
    // Init nicEditor
    if (mobile_mode) {
        $('#plain_editor').css('width', ($('#data_table').width() - 50) + 'px');
        plain_editor = new nicEditor().panelInstance('plain_editor');
    }
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
            "sAjaxSource": "/admin/settings/data/list?mobile=true",
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
                    return '<div style="text-align:center"><span class="btn" onclick="editData(' + row_id + ')"><i style="cursor:pointer" class="icon-pencil"></i></span>&nbsp;<span class="btn btn-danger" onclick="deleteData(' + row_id + ')"><i style="cursor:pointer" class="icon-trash icon-white"></i></span></div>';
                },
                "aTargets": [3]
            }, {
                "fnRender": function (oObj, sVal) {
                    var lang_text = langs.getItem(sVal) || '&mdash;';
                    return '<div style="text-align:center;cursor:pointer" onclick="selectLanguage(' + row_id + ')" id="lang_' + row_id + '"><span style="display:none" id="langv_' + row_id + '">' + sVal + '</span><img src="/images/flags/' + sVal + '.png" width="16" height="11" alt="" />&nbsp;' + lang_text + '</div>';
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
                    return '<div id="s_name-' + row_id + '">' + sVal + '</div';
                },
                "aTargets": [1]
            }],
            "fnDrawCallback": function () {
                $('.editable_text').editable(submitEdit, {
                    placeholder: '—',
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
            "iDisplayLength": 10,
            "bAutoWidth": true,
            "sAjaxSource": "/admin/settings/data/list",
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
                "aTargets": [4]
            }, {
                "fnRender": function (oObj, sVal) {
                    return '<div style="text-align:center"><span class="btn" onclick="editData(' + row_id + ')"><i style="cursor:pointer" class="icon-pencil"></i></span>&nbsp;<span class="btn btn-danger" onclick="deleteData(' + row_id + ')"><i style="cursor:pointer" class="icon-trash icon-white"></i></span></div>';
                },
                "aTargets": [4]
            }, {
                "fnRender": function (oObj, sVal) {
                    var lang_text = langs.getItem(sVal) || '&mdash;';
                    return '<div style="text-align:center;cursor:pointer" onclick="selectLanguage(' + row_id + ')" id="lang_' + row_id + '"><span style="display:none" id="langv_' + row_id + '">' + sVal + '</span><img src="/images/flags/' + sVal + '.png" width="16" height="11" alt="" />&nbsp;' + lang_text + '</div>';
                },
                "aTargets": [3]
            }, {
                "fnRender": function (oObj, sVal) {
                    row_id = sVal;
                    return '<input type="checkbox" style="float:left" name="cbx_' + sVal + '" id="cbx_' + sVal + '">&nbsp;' + sVal;
                },
                "aTargets": [0]
            }, {
                "fnRender": function (oObj, sVal) {
                    return '<div id="s_name-' + row_id + '" class="editable_text">' + sVal + '</div';
                },
                "aTargets": [1]
            }, {
                "fnRender": function (oObj, sVal) {
                    return '<div id="s_value-' + row_id + '" class="editable_text">' + sVal + '</div';
                },
                "aTargets": [2]
            }],
            "fnDrawCallback": function () {
                $('.editable_text').editable(submitEdit, {
                    placeholder: '—',
                    tooltip: ''
                });
            }
        }); // dtable
    }
});

function selectLanguage(row_id) {
    $('#language_select_s_name').html($('#s_name_' + row_id).html());
    $('#language_select').modal({
        keyboard: true
    });
    edit_id = row_id;
    $('#language_select_lang').val($('#langv_' + edit_id).html());
    $('#language_select_lang').focus();
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
    var arr = this.id.split('-');
    $.ajax({
        type: 'POST',
        url: '/admin/settings/data/save/field',
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
            } else {
                if (data.value) {
                    $('#' + edit_id).html(data.value);
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
    $('#h_data_actions').html(js_lang_add_option);
    $('#form_notice').html(js_lang_form_notice_add);
    $('#s_name').val('');
    $('#s_value').val('');
    $("#lang").val($("#lang option:first").val());
    $('#s_name').focus();
    if (mobile_mode) {
        $('#wysiwyg_editor_wrap').hide();
        $('#editor_buttons').show();
        $('#plain_editor_wrap').show();
        $('#data_edit_form').show();
        $('#form_controls').show();
        $('#data_edit_form_buttons').show();
        $('#eb_switch_cm').hide();
        $('#eb_switch_ck').hide();
        edit_mode = 'mobile';
        $('#eb_imgbrowser').show();
        nicEditors.findEditor('plain_editor').setContent('');
    } else {
        CKEDITOR.instances.wysiwyg_editor.setData('');
    }
});
// "Cancel" button handler (form mode)
$('#btn_edit_cancel').click(function () {
    $('#data_overview').show();
    $('#data_edit').hide();
});
// "Save" button handler (language select dialog mode)
$('#btn_language_select_save').click(function () {
    $.ajax({
        type: 'POST',
        url: '/admin/settings/data/save/field',
        data: {
            field_name: "lang",
            field_id: edit_id,
            field_value: $('#language_select_lang').val()
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
                $('#lang_' + edit_id).html('<span style="display:none" id="langv_' + edit_id + '">' + $('#language_select_lang').val() + '</span><img src="/images/flags/' + $('#language_select_lang').val() + '.png" width="16" height="11" alt="" />&nbsp;' + langs.getItem($('#language_select_lang').val()));
            }
        },
        error: function () {
            $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
        }
    });
    $('#language_select').modal('hide');
});
// "Save" button handler (form mode)
$('#btn_edit_save').click(function () {
    $('#form_error_msg').hide();
    resetFormState();
    var errors = false;
    if (!$('#s_name').val().match(/^[A-Za-z0-9_\-]{1,254}$/)) {
        $('#cg_s_name').addClass('error');
        errors = true;
    }
    if (!$('#s_value').val().match(/^.{0,254}$/)) {
        $('#cg_s_value').addClass('error');
        errors = true;
    }
    if (errors) {
        $('#form_error_msg_text').html(js_lang_form_errors);
        $('#form_error_msg').fadeIn(400);
        $('#form_error_msg').alert();
        $("html, body").animate({
            scrollTop: 0
        }, "fast");
    } else {
        $('#data_edit_form').hide();
        $('#data_edit_form_buttons').hide();
        $('#ajax_loading_msg').html(js_lang_ajax_saving);
        $('#ajax_loading').show();
        var tmp_content = '';
        if (mobile_mode) {
            tmp_content = nicEditors.findEditor('plain_editor').getContent();
        } else {
            tmp_content = CKEDITOR.instances.wysiwyg_editor.getData();
        }
        $.ajax({
            type: 'POST',
            url: '/admin/settings/data/save',
            data: {
                id: edit_id,
                s_name: $('#s_name').val(),
                s_value: $('#s_value').val(),
                s_value_html: tmp_content,
                lang: $('#lang').val()
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
                    $("html, body").animate({
                        scrollTop: 0
                    }, "fast");
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
    $('#form_error_msg').hide();
    $('#data_overview').hide();
    resetFormState();
    $('#data_edit').show();
    $('#h_data_actions').html(js_lang_edit_option);
    $('#form_notice').html(js_lang_form_notice_edit);
    $('#s_name').val('');
    $('#s_value').val('');
    $('input:radio[name="status"]').filter('[value="1"]').attr('checked', true);
    $('#data_edit_form').hide();
    $('#data_edit_form_buttons').hide();
    $('#ajax_loading_msg').html(js_lang_ajax_loading);
    $('#ajax_loading').show();
    if (mobile_mode) {
        $('#wysiwyg_editor_wrap').hide();
        $('#editor_buttons').show();
        $('#plain_editor_wrap').show();
        $('#data_edit_form').show();
        $('#form_controls').show();
        $('#data_edit_form_buttons').show();
        $('#eb_switch_cm').hide();
        $('#eb_switch_ck').hide();
        edit_mode = 'mobile';
        $('#eb_imgbrowser').show();
        nicEditors.findEditor('plain_editor').setContent('');
    } else {
        CKEDITOR.instances.wysiwyg_editor.setData('');
    }
    $.ajax({
        type: 'POST',
        url: '/admin/settings/data/load',
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
                if (data.s_name) {
                    $('#s_name').val(data.s_name);
                }
                if (data.s_value) {
                    $('#s_value').val(data.s_value);
                }
                if (data.s_value_html) {
                    if (mobile_mode) {
                        nicEditors.findEditor('plain_editor').setContent(data.s_value_html);
                    } else {
                        CKEDITOR.instances.wysiwyg_editor.setData(data.s_value_html);
                    }
                }
                if (data.lang) {
                    $('#lang').val(data.lang);
                }
                $('#s_name').focus();
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
        url: '/admin/settings/data/delete',
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
    var setting_names = new Array();
    for (var key in delete_data) {
        var val = delete_data[key];
        setting_names.push($('#s_name-' + val).html())
    }
    $('#delete_row_list').html(setting_names.join(', '));
    $('#delete_confirmation').modal({
        keyboard: false
    });
});
// Button "Close" in "None selected" dialog
$('#btn_none_selected_close').click(function () {
    $('#none_selected').modal('hide');
});
// Button "Close" in "Language select" dialog
$('#btn_language_select_close').click(function () {
    $('#language_select').modal('hide');
});
// Open "Delete" dialog window
function deleteData(id) {
    delete_data = [id];
    var s_name = $('#s_name-' + id).html();
    $('#delete_row_list').html(s_name);
    $('#delete_confirmation').modal({
        keyboard: false
    });
}
// Remove all "error" notification classes from form items
function resetFormState() {
    $('#cg_s_name').removeClass('error');
    $('#cg_s_value').removeClass('error');
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