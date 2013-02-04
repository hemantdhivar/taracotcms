var idata = new HashTable({});
var current_dir = '';
var tmp_old_name = '';
// begin: set popovers for buttons
$('.buttons-tooltip').tooltip();
// end: set popovers for buttons
function getDir() {
    $('#files').html('<img src="/images/blank.gif" width="25" height="11" alt="" /><img src="/images/well_loading.gif" width="16" height="11" alt="" /> js_lang_loading_folder');
    $.ajax({
        type: 'GET',
        url: '/admin/shop/data/images/dirdata',
        data: {
            dir: js_dir,
            rnd_num: new Date().getTime()
        },
        dataType: "json",
        success: function (data) {
            idata.clear();
            $('#files').html('');
            current_dir = data.current_dir;
            $.each(data.files, function (key, val) {
                var pic;
                var act = '';
                pic = '/files/images_shop/' + current_dir + '/.' + val.hash + '.jpg';
                var fp = 'blank.gif';
                var hp = '';
                if (val.fmt == 'j') {
                    fp = 'icon_jpeg_small.png';
                    hp = 'icon_jpeg.png';
                }
                if (val.fmt == 'g') {
                    fp = 'icon_gif_small.png';
                    hp = 'icon_gif.png';
                }
                if (val.fmt == 'p') {
                    fp = 'icon_png_small.png';
                    hp = 'icon_png.png';
                }
                if (hp.length == 0) {
                    hp = 'icon_generic.png';
                }
                if (val.hash == 'na') {
                    pic = '/images/' + hp;
                    fp = 'blank.gif';
                }
                idata.setItem('file_' + val.id, val.file);
                idata.setItem('type_' + val.id, val.type);
                var fn = val.file;
                fn = fn.substr(0, 17) + (fn.length > 17 ? '...' : '');
                $('#files').append('<li class="thumbnail browser_thumbnail node" ondblclick="' + act + '" id="' + val.id + '"><div style="background-image: url(' + pic + ')" class="browser_thumbnail_pic"><img src="/images/' + fp + '" width="32" height="16" alt="" class="browser_thumbnail_pic_type" /></div><div class="thumbnail_font">' + fn + '</div></li>');
            });
            $('.node').shifty({
                className: 'node_selected',
                select: function (el) {
                    var ns = $('.node').getSelected('node_selected');
                    if (ns.length > 0) {
                        enableClipButtons();
                    }
                },
                unselect: function (el) {
                    var ns = $('.node').getSelected('node_selected');
                    if (ns.length == 0) {
                        disableClipButtons();
                    }
                }
            });
        }, //success
        error: function () {
            alert(js_lang_error_ajax);
        }
    });
}

function enableClipButtons() {
    $('#btn_rename').removeClass('disabled');
    $('#btn_delete').removeClass('disabled');
}

function disableClipButtons() {
    $('#btn_rename').addClass('disabled');
    $('#btn_delete').addClass('disabled');
}
getDir();
// Plupload setup
var uploader;
uploader = new plupload.Uploader({
    runtimes: 'html5,flash,silverlight,html4',
    browse_button: 'btn_upload_select',
    container: 'upload_container',
    max_file_size: '10mb',
    drop_element: "upload_container",
    url: '/admin/shop/data/images/upload',
    flash_swf_url: '/js/plupload/plupload.flash.swf',
    silverlight_xap_url: '/js/plupload/plupload.silverlight.xap',
    filters: [{
        title: js_lang_image_files,
        extensions: "jpg,jpeg,gif,png"
    }]
});
uploader.init();
uploader.bind('FilesAdded', function (up, files) {
    $.each(files, function (i, file) {
        $('#filelist').append('<div id="' + file.id + '">' + file.name + ' (' + plupload.formatSize(file.size) + ') <b></b>' + '</div>');
    });
    if (uploader.files.length > 0) {
        $('#btn_upload_clear').removeClass('disabled');
        $('#btn_upload_start').removeClass('disabled');
    }
    up.refresh();
});
uploader.bind('Error', function (up, err) {
    $('#filelist').append('<div id="' + err.file.id + '">' + err.file.name + ': ' + err.message + '</div>');
    up.refresh();
});
uploader.bind('UploadProgress', function (up, file) {
    $('#' + file.id + " b").html(file.percent + "%");
});
uploader.bind('FileUploaded', function (up, file) {
    $('#' + file.id + " b").html("100%");
});
uploader.bind('UploadComplete', function (up, file) {
    $('#btn_upload_back').removeClass('disabled');
    $('#uploading').hide();
});
$('#btn_upload_start').click(function (e) {
    if ($('#btn_upload_start').hasClass('disabled')) {
        return;
    }
    uploader.settings.multipart_params = {
        dir: js_dir
    };
    if (uploader.files.length > 0) {
        $('#btn_upload_back').addClass('disabled');
        $('#btn_group_upload').hide();
        $('#uploading').show();
        uploader.start();
    }
    e.preventDefault();
});
$('#btn_upload_clear').click(function (e) {
    if ($('#btn_upload_clear').hasClass('disabled')) {
        return;
    }
    uploader.splice(0);
    $('#filelist').html('');
    $('#btn_upload_start').addClass('disabled');
    $('#btn_upload_clear').addClass('disabled');
    e.preventDefault();
});
$('#btn_upload_back').click(function (e) {
    if ($('#btn_upload_back').hasClass('disabled')) {
        return;
    }
    uploader.splice(0);
    $('#filelist').html('');
    $('#btn_upload_start').addClass('disabled');
    $('#btn_upload_clear').addClass('disabled');
    $('#btn_upload_select').removeClass('disabled');
    $('#btn_upload_select').show();
    $('#btn_group_upload').show();
    $('#upload_form').hide();
    $('#img_browser').show();
    getDir();
    e.preventDefault();
});
// Plupload Setup End
$('#id_if').bind('keypress', function (e) {
    if (e.keyCode == 13) {
        $('#btn_id_save').click();
    }
});
// "Upload" button handler
$('#btn_upload').click(function () {
    if ($('#btn_upload').hasClass('disabled')) {
        return;
    }
    clipboard_mode = '';
    $('#btn_cut').removeClass('btn-info');
    $('#btn_copy').removeClass('btn-info');
    $('#btn_paste').addClass('disabled');
    $('#img_browser').hide();
    $('#upload_form').show();
});
// "Rename" button handler
$('#btn_rename').click(function () {
    if ($('#btn_rename').hasClass('disabled')) {
        return;
    }
    var cid = $('.node').getSelected('node_selected');
    tmp_old_name = idata.getItem('file_' + cid[0]);
    $('#id_title').html(js_lang_rename_title + " " + tmp_old_name);
    $('#id_msg').html(js_lang_rename_new + ":");
    $('#img_browser').hide();
    $('#input_dialog').fadeIn(200);
    $('#id_if').val(tmp_old_name);
    $('#id_if').focus();
    $('#id_if').select();
    $('#id_cg_msg').removeClass('error');
    id_mode = 'rename';
});
// "Delete" button handler
$('#btn_delete').click(function () {
    if ($('#btn_delete').hasClass('disabled')) {
        return;
    }
    var cid = $('.node').getSelected('node_selected');
    var names = [];
    for (id in cid) {
        names.push(idata.getItem('file_' + cid[id]));
    }
    var list = names.join(', ');
    if (confirm(js_lang_delete_confirm + "\n\n" + list)) {
        $.ajax({
            type: 'POST',
            url: "/admin/shop/data/images/delete",
            data: {
                dir: js_dir,
                data: names
            },
            dataType: "json",
            success: function (data) {
                if (data.status != 1 && data.reason) {
                    var msg = data.reason;
                    if (data.file) {
                        msg += '<br>' + data.file;
                    }
                    $.jmessage(js_lang_error, msg, 2500, 'jm_message_error');
                }
                getDir();
            },
            error: function () {
                alert(js_lang_error_ajax);
            }
        });
    }
});
// Input data modal dialog "Close" button handler
$('#btn_id_cancel').click(function () {
    $('#img_browser').show();
    $('#input_dialog').hide();
});
// Input data modal dialog "Save" button handler
$('#btn_id_save').click(function () {
    // rename: begin
    if (id_mode == 'rename') {
        if (!$('#id_if').val().match(/^[A-Za-z0-9_\-\.]{1,100}$/) || tmp_old_name == $('#id_if').val()) {
            $('#id_cg_msg').addClass('error');
            return;
        }
        $('#id_cg_msg').removeClass('error');
        $.ajax({
            type: 'POST',
            url: "/admin/shop/data/images/rename",
            data: {
                dir: js_dir,
                old_name: tmp_old_name,
                new_name: $('#id_if').val()
            },
            dataType: "json",
            success: function (data) {
                if (data.status != 1 && data.reason) {
                    var msg = data.reason;
                    if (data.file) {
                        msg += '<br>' + data.file;
                    }
                    $.jmessage(js_lang_error, msg, 2500, 'jm_message_error');
                }
                getDir();
            },
            error: function () {
                alert(js_lang_error_ajax);
            }
        });
    } // rename: end
    $('#img_browser').show();
    $('#input_dialog').hide(200);
});