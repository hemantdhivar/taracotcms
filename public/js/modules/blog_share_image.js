var img_urls = [];
var _save_cmd = undefined;
var _save_context = undefined;
var share_image_dialog = function(_cmd,opt,queryState) {
    $('#share_image').modal();
    $('#btn_clear_res').click();
    _save_cmd = _cmd;
    _save_context = this;
    if (queryState) {
        this.wbbRemoveCallback(cmd,true);
    }
};
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
         $('#filelist').empty();
         $.each(files, function (i, file) {
             $('#filelist').append('<div id="_si_fn_'+file.id+'">'+file.name + ' (' + plupload.formatSize(file.size) + ')</div>' + '<div id="_si_pg_'+file.id+'" class="progress progress-striped active"><div class="progress-bar" id="_si_pb_'+file.id+'" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100" style="width: 0%"></div></div>');
         });
         $('#btn_upload_select').hide();         
         uploader.start();
     });
     uploader.bind('Error', function (up, err) {
         $('#_si_fn_'+err.file.id).append('&nbsp;<span class="label label-danger">' + err.message + '</span><br/><br/>');    
         $('#_si_pg_'+err.file.id).hide();
     });
     uploader.bind('UploadProgress', function (up, file) {
         $('#_si_pb_'+file.id).animate({ width: file.percent + "%" }, 50);
     });
     uploader.bind('FileUploaded', function (up, file, info) {
         $('#_si_pb_'+file.id).animate({ width: "100%" }, 50);
         $('#_si_pg_'+file.id).removeClass('active');
         $('#_si_pb_'+file.id).addClass('progress-bar-success');
         var _rsp = jQuery.parseJSON(info.response);
         $('#result_gallery_row').append('<div class="col-lg-2 col-md-2 col-sm-2" id="result_gallery_col"><div class="thumbnail" style="width:170px"><div style="text-align:center;height:100px"><img src="' + _rsp.tn + '" alt=""></div><div class="caption"><input type="text" style="width:100%" class="share_image_link" value="' + _rsp.fn + '"></div></div></div>');
         img_urls.push(_rsp.fn);
         $('.share_image_link').click(function() { this.select(); } );
     });
     uploader.bind('UploadComplete', function (up, file) {
         $('#btn_upload_select').show();
     });   
     $('#btn_clear_res').click(function() {
        $('#result_gallery_row').empty();
        $('#filelist').empty();
        img_urls = [];        
     });
     $('#share_image_push').click(function() {
        for (var i=0; i<img_urls.length; i++) {
            _save_context.wbbInsertCallback(_save_cmd,{src:img_urls[i]});
        }
     });
 });