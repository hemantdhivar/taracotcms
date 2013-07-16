// Init variables
var edit_id = 0;
var edit_mode = 'ck';
var delete_data = new Array();
var dtable;
var mobile_mode = $('#mobile_mode').is(":visible");
// Init CodeMirror
var plain_editor;
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
// Bind Enter key 
$('#language_select_lang').bind('keypress', function (e) {
    if (e.keyCode == 13) {
        $('#btn_language_select_save').click();
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
    $('#plain_editor').css('width', ($('#data_table').width() - 50) + 'px');
    // Init CkEditor
    $('#wysiwyg_editor').ckeditor({
        filebrowserBrowseUrl: '/admin/imgbrowser'
    });
    // Init dropdown
    $().dropdown();
    // Init data table
    var row_id = 0;
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
            "sAjaxSource": "/admin/pages/data/list?mobile=true",
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
                    return '<div style="text-align:center;width:92px"><button type="button" class="btn" onclick="editData(' + row_id + ')"><i style="cursor:pointer" class="icon-pencil"></i></button>&nbsp;<button type="button" class="btn btn-danger" onclick="deleteData(' + row_id + ')"><i style="cursor:pointer" class="icon-trash icon-white"></i></button></div>';
                },
                "aTargets": [3]
            }, {
                "fnRender": function (oObj, sVal) {
                    return '<div style="text-align:center;cursor:pointer" onclick="selectLanguage(' + row_id + ')" id="lang_' + row_id + '"><span style="display:none" id="langv_' + row_id + '">' + sVal + '</span><img src="/images/flags/' + sVal + '.png" width="16" height="11" alt="" />&nbsp;' + langs.getItem(sVal) + '</div>';
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
                    return '<div id="pagetitle_' + row_id + '">' + sVal + '</div';
                },
                "aTargets": [1]
            }],
            "fnDrawCallback": function () {
                $('.editable_text').editable(submitEdit, {
                    placeholder: '—',
                    tooltip: ''
                });
            }
        }); //dtable mobile
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
            "sAjaxSource": "/admin/pages/data/list",
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
                "aTargets": [6]
            }, {
                "fnRender": function (oObj, sVal) {
                    return '<div style="text-align:center"><button type="button" class="btn" onclick="editData(' + row_id + ')"><i style="cursor:pointer" class="icon-pencil"></i></button>&nbsp;<button type="button" class="btn btn-danger" onclick="deleteData(' + row_id + ')"><i style="cursor:pointer" class="icon-trash icon-white"></i></button></div>';
                },
                "aTargets": [6]
            }, {
                "fnRender": function (oObj, sVal) {
                    var pic = 'lamp_on.png';
                    if (sVal == 0) {
                        pic = 'lamp_off.png';
                    }
                    if (sVal == 2) {
                        pic = 'under_construction.png';
                    }
                    return '<div style="text-align:center;cursor:pointer" class="editable_select" onclick="selectStatus(' + row_id + ')" id="status_' + row_id + '"><span style="display:none" id="rowstatus_' + row_id + '">' + sVal + '</span><img src="/images/' + pic + '" width="16" height="16" alt="" /></div>';
                },
                "aTargets": [5]
            }, {
                "fnRender": function (oObj, sVal) {
                    return '<div style="text-align:center;cursor:pointer" onclick="selectLanguage(' + row_id + ')" id="lang_' + row_id + '"><span style="display:none" id="langv_' + row_id + '">' + sVal + '</span><img src="/images/flags/' + sVal + '.png" width="16" height="11" alt="" />&nbsp;' + langs.getItem(sVal) + '</div>';
                },
                "aTargets": [3]
            }, {
                "fnRender": function (oObj, sVal) {
                    return '<div style="text-align:center;cursor:pointer" id="layout_' + row_id + '" onclick="selectLayout(' + row_id + ')">' + sVal + '</div>';
                },
                "aTargets": [4]
            }, {
                "fnRender": function (oObj, sVal) {
                    row_id = sVal;
                    return '<input type="checkbox" style="float:left" name="cbx_' + sVal + '" id="cbx_' + sVal + '">&nbsp;' + sVal;
                },
                "aTargets": [0]
            }, {
                "fnRender": function (oObj, sVal) {
                    return '<div id="pagetitle_' + row_id + '" class="editable_text">' + sVal + '</div';
                },
                "aTargets": [1]
            }, {
                "fnRender": function (oObj, sVal) {
                    return '<div id="filename_' + row_id + '" class="editable_text">' + sVal + '</div';
                },
                "aTargets": [2]
            }],
            "fnDrawCallback": function () {
                $('.editable_text').editable(submitEdit, {
                    placeholder: '–',
                    tooltip: ''
                });
            }
        }); //dtable 
    }
});
$('#filename').change(function () {
    var host = window.location.hostname;
    var re = new RegExp(js_current_lang + "\\.", "");
    host = host.replace(re, '');
    var path = $('#filename').val().replace(/^\//, '');
    var lang = $('#lang').val();
    lang += '.';
    path = path.replace(/[^a-z0-9\-_\.\/]/g, '');
    var url = 'http://' + lang + host + '/' + path;
    url = url.replace(re, '');
    $('#url_help').html('<a href="' + url + '" target="blank">' + url + '</a>');
});
$('#pagetitle').change(function () {
    if (!$('#filename').val() && $('#pagetitle').val().length > 0) {
        generateURL();
    }
});
$('#lang').change(function () {
    $('#filename').change();
});

function generateURL() {
    if ($('#pagetitle').val().length < 1) {
        $.jmessage(js_lang_error, js_lang_get_url_error_blank, 2500, 'jm_message_error');
        return;
    }
    $('#get_url').hide();
    $('#filename').hide();
    $('#unidecode_progress').show();
    $.ajax({
        type: 'POST',
        url: '/admin/pages/data/unidecode',
        data: {
            val: $('#pagetitle').val()
        },
        dataType: "json",
        success: function (data) {
            if (data.result == 0) {
                $.jmessage(js_lang_error, js_lang_get_url_error_blank, 2500, 'jm_message_error');
            } else {
                $('#filename').val(data.data);
            }
            $('#filename').change();
            $('#unidecode_progress').hide();
            $('#get_url').show();
            $('#filename').show();
            $('#filename').select();
            $('#filename').focus();
        },
        error: function () {
            $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
        }
    });
}

function selectLanguage(row_id) {
    $('#language_select_pagetitle').html($('#pagetitle_' + row_id).html());
    $('#language_select').modal({
        keyboard: true
    });
    edit_id = row_id;
    $('#language_select_lang').val($('#langv_' + edit_id).html());
    $('#language_select_lang').focus();
}

function selectLayout(row_id) {
    $('#layout_select_pagetitle').html($('#pagetitle_' + row_id).html());
    $('#layout_select').modal({
        keyboard: true
    });
    edit_id = row_id;
    $('#layout_select_layout').val($('#layout_' + edit_id).html());
    $('#layout_select_layout').focus();
}

function selectStatus(row_id) {
    $('#status_select_pagetitle').html($('#pagetitle_' + row_id).html());
    $('#status_select').modal({
        keyboard: true
    });
    edit_id = row_id;
    $('input:radio[name="status_select_status"]').filter('[value="' + $('#rowstatus_' + row_id).html() + '"]').attr('checked', true);
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
        url: '/admin/pages/data/save/field',
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
    $('#eb_imgbrowser').hide();
    edit_mode = 'ck';
    $('#data_edit').show();
    $('#filename').change();
    $('#h_data_actions').html(js_lang_add_page);
    $('#form_notice').html(js_lang_form_notice_add);
    $('#pagetitle').val('');
    $('#filename').val('');
    $('#keywords').val('');
    $('#description').val('');
    if (mobile_mode) {
        $('#wysiwyg_editor_wrap').hide();
        $('#editor_buttons').show();
        $('#plain_editor_wrap').show();
        $('#data_edit_form').show();
        $('#form_controls').show();
        $('#data_edit_form_buttons').show();
        edit_mode = 'mobile';
        $('#eb_imgbrowser').show();
        $('#plain_editor').val('');
    } else {
        CKEDITOR.instances.wysiwyg_editor.setData('');
    }
    $('input:radio[name="status"]').filter('[value="1"]').attr('checked', true);
    $("#lang").val($("#lang option:first").val());
    $("#layout").val($("#layout option:first").val());
    $('#pagetitle').focus();
    $('#url_help').html('');
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
        url: '/admin/pages/data/save/field',
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
// "Save" button handler (layout select dialog mode)
$('#btn_layout_select_save').click(function () {
    $.ajax({
        type: 'POST',
        url: '/admin/pages/data/save/field',
        data: {
            field_name: "layout",
            field_id: edit_id,
            field_value: $('#layout_select_layout').val()
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
                $('#layout_' + edit_id).html($('#layout_select_layout').val());
            }
        },
        error: function () {
            $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
        }
    });
    $('#layout_select').modal('hide');
});
// "Save" button handler (status select dialog mode)
$('#btn_status_select_save').click(function () {
    $.ajax({
        type: 'POST',
        url: '/admin/pages/data/save/field',
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
                if (sVal == 2) {
                    pic = 'under_construction.png';
                }
                $('#status_' + edit_id).html('<span style="display:none" id="status_' + edit_id + '">' + sVal + '</span><img src="/images/' + pic + '" width="16" height="16" alt="" />');
            }
        },
        error: function () {
            $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
        }
    });
    $('#status_select').modal('hide');
});
// "Save" button handler (form mode)
$('#btn_edit_save').click(function () {
    $('#form_error_msg').hide();
    resetFormState();
    var errors = false;
    if (!$('#pagetitle').val().match(/^.{1,254}$/)) {
        $('#cg_pagetitle').addClass('error');
        errors = true;
    }
    if (!$('#filename').val().match(/^.{1,254}$/)) {
        $('#cg_filename').addClass('error');
        errors = true;
    }
    if (!$('#keywords').val().match(/^.{0,254}$/)) {
        $('#cg_keywords').addClass('error');
        errors = true;
    }
    if (!$('#description').val().match(/^.{0,254}$/)) {
        $('#cg_description').addClass('error');
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
            tmp_content = $('#plain_editor').val();
        } else {
            tmp_content = CKEDITOR.instances.wysiwyg_editor.getData();
        }
        $('#wysiwyg_editor_wrap').hide();
        $('#editor_buttons').hide();
        $.ajax({
            type: 'POST',
            url: '/admin/pages/data/save',
            data: {
                id: edit_id,
                pagetitle: $('#pagetitle').val(),
                filename: $('#filename').val(),
                keywords: $('#keywords').val(),
                description: $('#description').val(),
                status: $("input[name='status']:checked").val(),
                content: tmp_content,
                lang: $('#lang').val(),
                layout: $('#layout').val()
            },
            dataType: "json",
            success: function (data) {
                $('#wysiwyg_editor_wrap').show();
                $('#editor_buttons').show();
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
                    edit_mode = 'ck';
                    $('#eb_imgbrowser').hide();
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
    edit_mode = 'ck';
    $('#eb_imgbrowser').hide();
    $('#data_edit').hide();
    $('#data_overview').show();
});
// Edit record
function editData(id) {
    edit_id = id;
    $('#form_error_msg').hide();
    $('#data_overview').hide();
    resetFormState();
    edit_mode = 'ck';
    $('#eb_imgbrowser').hide();
    $('#data_edit').show();
    $('#filename').change();
    $('#h_data_actions').html(js_lang_edit_page);
    $('#form_notice').html(js_lang_form_notice_edit);
    $('#pagetitle').val('');
    $('#password').val('');
    $('#password_repeat').val('');
    $('#filename').val('');
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
        edit_mode = 'mobile';
        $('#eb_imgbrowser').show();
        $('#plain_editor').val('');
    } else {
        CKEDITOR.instances.wysiwyg_editor.setData('');
    }
    $.ajax({
        type: 'POST',
        url: '/admin/pages/data/load',
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
                $('#wysiwyg_editor_wrap').hide();
                $('#editor_buttons').hide();
            } else { // OK
                $('#ajax_loading').hide();
                $('#data_edit_form').show();
                $('#form_controls').show();
                $('#data_edit_form_buttons').show();
                if (data.pagetitle) {
                    $('#pagetitle').val(data.pagetitle);
                }
                if (data.filename) {
                    $('#filename').val(data.filename);
                }
                if (data.keywords) {
                    $('#keywords').val(data.keywords);
                }
                if (data.description) {
                    $('#description').val(data.description);
                }
                if (data.content) {
                    if (mobile_mode) {
                        $('#plain_editor').val(data.content);
                    } else {
                        CKEDITOR.instances.wysiwyg_editor.setData(data.content);
                    }
                }
                if (data.status) {
                    $('input:radio[name="status"]').filter('[value="' + data.status + '"]').attr('checked', true);
                }
                if (data.lang) {
                    $('#lang').val(data.lang);
                }
                if (data.layout) {
                    $('#layout').val(data.layout);
                }
                $('#filename').change();
                $('#pagetitle').focus();
            }
        },
        error: function () {
            $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
            $('#ajax_loading').hide();
            $('#data_edit_form').show();
            $('#form_controls').hide();
            $('#btn_abort').show();
            $('#wysiwyg_editor_wrap').hide();
            $('#editor_buttons').hide();
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
        url: '/admin/pages/data/delete',
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
$('#eb_imgbrowser').click(

function () {
    var features, w = screen.width - 100,
        h = screen.height - 200;
    var top = (screen.height - h) / 2 - 50,
        left = (screen.width - w) / 2;
    if (top < 0) top = 0;
    if (left < 0) left = 0;
    features = 'top=' + top + ',left=' + left;
    features += ',height=' + h + ',width=' + w + ',resizable=no';
    imgbrowser = open('/admin/imgbrowser?mode=' + edit_mode, 'displayWindow', features);
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
    var page_names = new Array();
    for (var key in delete_data) {
        var val = delete_data[key];
        page_names.push($('#pagetitle_' + val).html())
    }
    $('#delete_row_list').html(page_names.join(', '));
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
// Button "Close" in "Layout select" dialog
$('#btn_layout_select_close').click(function () {
    $('#layout_select').modal('hide');
});
// Button "Close" in "Status select" dialog
$('#btn_status_select_close').click(function () {
    $('#status_select').modal('hide');
});
// Open "Delete" dialog window
function deleteData(id) {
    delete_data = [id];
    var pagetitle = $('#pagetitle_' + id).html();
    $('#delete_row_list').html(pagetitle);
    $('#delete_confirmation').modal({
        keyboard: false
    });
}
// Remove all "error" notification classes from form items
function resetFormState() {
    $('#cg_pagetitle').removeClass('error');
    $('#cg_keywords').removeClass('error');
    $('#cg_description').removeClass('error');
    $('#cg_filename').removeClass('error');
    $('#password_hint').html(js_lang_password_hint);
    $('#eb_switch_cm').removeClass('disabled');
    $('#wysiwyg_editor_wrap').show();
    $('#editor_buttons').show();
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