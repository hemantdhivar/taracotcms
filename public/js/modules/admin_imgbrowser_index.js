$(document).ready(function () {
    var idata = new HashTable({});
    var current_dir = '';
    var up_dir = '';
    var id_mode = '';
    var clipboard_data = '';
    var clipboard_dir = '';
    var clipboard_mode = '';
    var tmp_old_name = '';
    var return_mode = getUrlParam('mode') || 'ck';
    // begin: set popovers for buttons
    $('.buttons-tooltip').tooltip();
    // end: set popovers for buttons
    openDir('');

    function getDir() {
        $('#files').html('<img src="/images/blank.gif" width="25" height="11" alt="" /><img src="/images/well_loading.gif" width="16" height="11" alt="" /> js_lang_loading_folder');
        $.ajax({
            type: 'GET',
            url: '/admin/imgbrowser/dirdata',
            data: {
                dir: current_dir,
                rnd_num: new Date().getTime()
            },
            dataType: "json",
            success: function (data) {
                idata.clear();
                $('#files').html('');
                disableClipButtons();
                current_dir = data.current_dir;
                up_dir = data.up_dir;
                if (current_dir != up_dir) {
                    $('#btn_up').removeClass('disabled');
                } else {
                    $('#btn_up').addClass('disabled');
                }
                $('#btn_chdir').addClass('disabled');
                var current_dir_disp = current_dir;
                if (!current_dir) {
                    current_dir_disp = '/';
                }
                $('#cd').html(js_lang_current_dir + ": " + current_dir_disp);
                $.each(data.files, function (key, val) {
                    var pic;
                    var act = '';
                    if (val.type == 'd') {
                        pic = '/images/folder.png';
                        act = "openDir('" + val.file + "')";
                    } else {
                        pic = '/files/images' + current_dir + '/.' + val.hash + '.jpg';
                    }
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
                    $('#files').append('<div class="col-sm-2 col-sm-2" style="width:140px;text-align:center"><span class="thumbnail browser_thumbnail node" ondblclick="' + act + '" id="' + val.id + '"><div style="background-image: url(' + pic + ')" class="browser_thumbnail_pic"><img src="/images/' + fp + '" width="32" height="16" alt="" class="browser_thumbnail_pic_type" /></div><div class="thumbnail_font">' + fn + '</div></span></div>');
                });
                $('.node').shifty({
                    className: 'node_selected',
                    select: function (el) {
                        var ns = $('.node').getSelected('node_selected');
                        if (ns.length > 0) {
                            enableClipButtons();
                        }
                        if (ns.length === 1) {
                            if (idata.getItem('type_' + ns[0]) == 'd') {
                                $('#btn_chdir').removeClass('disabled');
                            } else {
                                $('#btn_chdir').addClass('disabled');
                            }
                        } else {
                            $('#btn_chdir').addClass('disabled');
                        }
                    },
                    unselect: function (el) {
                        var ns = $('.node').getSelected('node_selected');
                        if (ns.length == 0) {
                            disableClipButtons();
                        }
                        if (ns.length == 1) {
                            if (idata.getItem('type_' + ns[0]) == 'd') {
                                $('#btn_chdir').removeClass('disabled');
                            } else {
                                $('#btn_chdir').addClass('disabled');
                            }
                        }
                    }
                });
            },
            error: function () {
                alert(js_lang_error_ajax);
            }
        });
    } // getDir
    function openDir(dir) {
        if (!current_dir.match("\/$")) {
            current_dir += '/';
        }
        current_dir += dir;
        if (current_dir != '/') {
            current_dir += '/';
        }
        getDir();
    } // openDir
    function upDir() {
        if (current_dir == up_dir) {
            return;
        }
        current_dir = up_dir;
        getDir();
    }

    function enableClipButtons() {
        $('#btn_cut').removeClass('disabled');
        $('#btn_copy').removeClass('disabled');
        var ns = $('.node').getSelected('node_selected');
        if (ns.length === 1) {
            $('#btn_rename').removeClass('disabled');
        } else {
            $('#btn_rename').addClass('disabled');
        }
        if (ns.length === 1 && idata.getItem('type_' + ns[0]) != 'd') {
            $('#btn_select').removeClass('disabled');
        } else {
            $('#btn_select').addClass('disabled');
        }
        $('#btn_delete').removeClass('disabled');
    }

    function disableClipButtons() {
        $('#btn_cut').addClass('disabled');
        $('#btn_copy').addClass('disabled');
        $('#btn_rename').addClass('disabled');
        $('#btn_select').addClass('disabled');
        $('#btn_delete').addClass('disabled');
    }
    // Plupload setup
    var uploader;
    uploader = new plupload.Uploader({
        runtimes: 'html5,flash,silverlight,html4',
        browse_button: 'btn_upload_select',
        container: 'upload_container',
        max_file_size: '10mb',
        drop_element: "upload_container",
        url: '/admin/imgbrowser/upload',
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
            dir: current_dir
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
    // Helper function to get parameters from the query string
    function getUrlParam(paramName) {
        var reParam = new RegExp('(?:[\?&]|&amp;)' + paramName + '=([^&]+)', 'i');
        var match = window.location.search.match(reParam);
        return (match && match.length > 1) ? match[1] : '';
    }
    $('#id_if').bind('keypress', function (e) {
        if (e.keyCode == 13) {
            $('#btn_id_save').click();
        }
    });
    // "Up" button handler
    $('#btn_up').click(function () {
        if ($('#btn_up').hasClass('disabled')) {
            return;
        }
        upDir();
    });
    // "Chdir" button handler
    $('#btn_chdir').click(function () {
        if ($('#btn_chdir').hasClass('disabled')) {
            return;
        }
        var ns = $('.node').getSelected('node_selected');
        if (ns.length == 0) {
            return;
        }
        openDir(idata.getItem('file_' + ns[0]));
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
    // "Copy" button handler
    $('#btn_copy').click(function () {
        if ($('#btn_copy').hasClass('disabled')) {
            return;
        }
        var ns = $('.node').getSelected('node_selected');
        clipboard_data = ns;
        clipboard_dir = current_dir;
        clipboard_mode = 'copy';
        $('#btn_copy').addClass('btn-info');
        $('#btn_cut').removeClass('btn-info');
        $('#btn_paste').removeClass('disabled');
    });
    // "Cut" button handler
    $('#btn_cut').click(function () {
        if ($('#btn_cut').hasClass('disabled')) {
            return;
        }
        var ns = $('.node').getSelected('node_selected');
        clipboard_data = ns;
        clipboard_dir = current_dir;
        clipboard_mode = 'cut';
        $('#btn_cut').addClass('btn-info');
        $('#btn_copy').removeClass('btn-info');
        $('#btn_paste').removeClass('disabled');
    });
    // "Paste" button handler
    $('#btn_paste').click(function () {
        if ($('#btn_paste').hasClass('disabled') || clipboard_mode == '' || clipboard_data.length == 0 || current_dir == clipboard_dir) {
            return;
        }
        $('#files').html('<img src="/images/blank.gif" width="25" height="11" alt="" /><img src="/images/well_loading.gif" width="16" height="11" alt="" /> js_lang_loading_folder');
        disableClipButtons();
        $('#btn_upload').addClass('disabled');
        $('#btn_paste').addClass('disabled');
        $('#btn_copy').removeClass('btn-info');
        $('#btn_cut').removeClass('btn-info');
        $('#btn_group_dir').hide();
        $.ajax({
            type: 'POST',
            url: '/admin/imgbrowser/paste',
            data: {
                dir_from: clipboard_dir,
                dir_to: current_dir,
                mode: clipboard_mode,
                data: clipboard_data
            },
            dataType: "json",
            success: function (data) {
                clipboard_dir = '';
                clipboard_data = '';
                clipboard_mode = '';
                $('#btn_upload').removeClass('disabled');
                $('#btn_group_dir').show();
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
    });
    // "New dir" button handler
    $('#btn_newdir').click(function () {
        $('#id_title').html(js_lang_newdir_title);
        $('#id_msg').html(js_lang_newdir_name + ":");
        $('#img_browser').hide();
        $('#input_dialog').fadeIn(200);
        $('#id_if').val('');
        $('#id_if').focus();
        $('#id_cg_msg').removeClass('error');
        id_mode = 'newdir';
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
    // "Select" button handler
    $('#btn_select').click(function () {
        if ($('#btn_select').hasClass('disabled')) {
            return;
        }
        var cid = $('.node').getSelected('node_selected');
        var fn = cid[0];
        if (!fn.match('^/')) {
            fn = '/' + fn;
        }
        if (return_mode == 'ck') {
            window.opener.CKEDITOR.tools.callFunction(getUrlParam('CKEditorFuncNum'), '/files/images' + fn);
            window.close();
            return;
        }
        if (return_mode == 'mobile') {
            var instance = window.opener.document.getElementById('plain_editor');
            var myValue = '<img src="/files/images' + fn + '" alt="" />';

            if (instance.selection) {
                    instance.focus();
                    sel = instance.selection.createRange();
                    sel.text = myValue;
                    instance.focus();
            }
            else if (instance.selectionStart || instance.selectionStart == '0') {
                var startPos = instance.selectionStart;
                var endPos = instance.selectionEnd;
                var scrollTop = instance.scrollTop;
                instance.value = instance.value.substring(0, startPos)+myValue+instance.value.substring(endPos,instance.value.length);
                instance.focus();
                instance.selectionStart = startPos + myValue.length;
                instance.selectionEnd = startPos + myValue.length;
                instance.scrollTop = scrollTop;
            } else {
                instance.value += myValue;
                instance.focus();
            }

            window.close();
            return;
        }
        window.close();
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
                url: '/admin/imgbrowser/delete',
                data: {
                    dir: current_dir,
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
        // newdir: begin
        if (id_mode == 'newdir') {
            if (!$('#id_if').val().match(/^[A-Za-z0-9_\-\.]{1,100}$/)) {
                $('#id_cg_msg').addClass('error');
                return;
            }
            $('#id_cg_msg').removeClass('error');
            $.ajax({
                type: 'POST',
                url: '/admin/imgbrowser/newdir',
                data: {
                    dir: current_dir,
                    new_dir: $('#id_if').val()
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
        } // newdir: end
        // rename: begin
        if (id_mode == 'rename') {
            if (!$('#id_if').val().match(/^[A-Za-z0-9_\-\.]{1,100}$/) || tmp_old_name == $('#id_if').val()) {
                $('#id_cg_msg').addClass('error');
                return;
            }
            $('#id_cg_msg').removeClass('error');
            $.ajax({
                type: 'POST',
                url: '/admin/imgbrowser/rename',
                data: {
                    dir: current_dir,
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
});