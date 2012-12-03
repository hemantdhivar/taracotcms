 function loadDir() {
     $('#ajax_loading').show();
     $.ajax({
         type: 'POST',
         url: '/admin/files/storage/list',
         data: {},
         dataType: "json",
         success: function (data) {
             $('#ajax_loading').hide();
             if (data.length > 0) {
                 var output = '<table class="table table-striped">';
                 for (var t = 0; t < data.length; t++) {
                     output += '<tr><td width="20"><i class="filetypes-i-' + data[t].type + '"></i></td><td><a href="/files/storage/' + data[t].name + '" target="_blank">/files/storage/' + data[t].name + '</a></td><td width="100" style="text-align:center">' + data[t].size + '</td><td width="30" style="text-align:right"><span class="btn btn-mini btn-danger" onclick="' + "deleteFile('" + data[t].name + "');" + '"><i style="cursor:pointer" class="icon-trash icon-white"></i></span></td></tr>';
                 }
                 output += '</table>'
                 $('#file_list').html(output);
             } else {
                 $('#file_list').html('<span class="label label-important">' + js_lang_no_files + '</span>');
             }
         },
         error: function () {
             $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
             $('#file_list').html('<span class="label label-important">' + js_lang_no_files + '</span>');
         }
     });
 }

 function deleteFile(file_name) {
     if (!confirm(js_lang_confirm_delete + ":\n\n" + file_name)) {
         return;
     }
     $.ajax({
         type: 'POST',
         url: '/admin/files/storage/delete',
         data: {
             filename: file_name
         },
         dataType: "json",
         success: function (data) {
             if (data.result > 0) {
                 $.jmessage(js_lang_success, js_lang_success_delete, 2500, 'jm_message_success');
                 loadDir();
             } else {
                 $.jmessage(js_lang_error, js_lang_error_delete, 2500, 'jm_message_error');
             }
         },
         error: function () {
             $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
         }
     });
 }
 $(document).ready(function () {
     loadDir();
     var uploader;
     uploader = new plupload.Uploader({
         runtimes: 'html5,flash,silverlight,html4',
         browse_button: 'btn_upload_select',
         container: 'upload_container',
         max_file_size: '10mb',
         drop_element: "upload_container",
         url: '/admin/files/storage/upload',
         flash_swf_url: '/js/plupload/plupload.flash.swf',
         silverlight_xap_url: '/js/plupload/plupload.silverlight.xap',
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
         $('#files_upload').hide();
         $('#files_table').show();
         loadDir();
         e.preventDefault();
     });
     $('#btn_upload').click(function (e) {
         $('#files_table').hide();
         $('#files_upload').show();
         uploader.splice(0);
     });
 });