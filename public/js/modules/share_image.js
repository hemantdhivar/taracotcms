 $(document).ready(function () {
     var uploader;
     uploader = new plupload.Uploader({
         runtimes: 'html5,flash,silverlight,html4',
         browse_button: 'btn_upload_select',
         container: 'upload_container',
         filters : {
          max_file_size : '10mb',
          mime_types: [
            {title : "Image files", extensions : "jpg,jpeg,gif,png"},
          ]
         },
         drop_element: "upload_container",
         url: '/share/image/upload',
         flash_swf_url: '/js/plupload/plupload.flash.swf',
         silverlight_xap_url: '/js/plupload/plupload.silverlight.xap',
     });
     uploader.init();
     uploader.bind('FilesAdded', function (up, files) {
         $.each(files, function (i, file) {
             $('#filelist').html(file.name + ' (' + plupload.formatSize(file.size) + ')');
         });
         $('#btn_upload_select').hide();
         uploader.start();
     });
     uploader.bind('Error', function (up, err) {
         $('#filelist').html(err.file.name + ': ' + err.message);    
         $('#btn_upload_select').show();
         $('#progress-bar').css('width', "0%");
     });
     uploader.bind('UploadProgress', function (up, file) {
         $('#progress-bar').width(file.percent + "%");
     });
     uploader.bind('FileUploaded', function (up, file) {
         $('#progress-bar').css('width', "100%");
     });
     uploader.bind('UploadComplete', function (up, file) {
         $('#btn_upload_select').show();
     });
 });
 