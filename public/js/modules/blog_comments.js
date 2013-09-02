var comment_id = 0;

$('#btn_comment').click(function() {	
    if (!$('#comment').val().match(/.{1,2048}$/)) {        
        return;
    }
    $('#comments_form').hide();
    $('#comments_ajax_notify').show();
    $.ajax({
        type: 'POST',
        url: '/blog/comment/put',
        data: {
            ctext: $('#comment').val(),
            cpid:  post_id,
            cmid:  comment_id
        },
        dataType: "json",
        success: function (data) {   
            if (data.status==1) {
                $('#comment').val('');
                if (data.html) {
                    var cid = comment_id;
                    if (data.last_child_id) {
                        cid = data.last_child_id;
                    }
                    if (cid > 0) {
                        $('#comment_'+cid).after(data.html);
                    } else {
                        $('#blog_comment_dock_0').html(data.html);
                    }
                }
                if (data.comments_count) {
                    $('#comment_count').html(data.comments_count);
                }
                $('#blog_comment_write').click();
                $('.comment_reply').click(comment_reply);
            } else {         
                $('#comment_error').modal();
                if (data.errmsg) {
                    $('#comment_error_msg').html(data.errmsg);
                } else {
                    $('#comment_error_msg').html('');
                }                
            }    
            $('#comments_form').show();
            $('#comments_ajax_notify').hide();        
        },
        error: function () {
            $('#comments_form').show();
            $('#comments_ajax_notify').hide();
            $('#comment_error_msg').html(js_lang_comment_error_db);
            $('#comment_error').modal();
        }
    });
});
var comment_reply = function() {
    $('#comment_reply_'+comment_id).show();
    var id = this.id.replace("comment_reply_","");
    var cfw = $('#comments_form_wrap').detach();
    $('#comment_reply_attach_'+id).html(cfw);
    $('#comment_reply_'+id).hide();
    $('#blog_comment_write').removeClass('hide');
    comment_id = id;   
    $('#comment').val('');
    $('#comment').focus();
};
$('.comment_reply').click(comment_reply);
$('#blog_comment_write').click(function() {
    $('#blog_comment_write').addClass('hide');
    var cfw = $('#comments_form_wrap').detach();
    $('#blog_comment_dock').html(cfw);
    $('#comment_reply_'+comment_id).show();
    comment_id = 0;
    $('#comment').val('');
    $('#comment').focus();
});
var delete_comment_id = 0;
function deleteComment(id) {
    delete_comment_id = id;
    $('#comment_delete_dialog').modal();
    $('#comment_delete_error').hide();
    $('#delete_comment_info').html(':<div style="height:16px"></div><div class="well">'+$('#comment_'+id+'_data').html()+'<div style="height:4px"></div>'+$('#comment_'+id+'_text').html()+'</div>');
    $('#delete_comment_ban_72').prop('checked', false);
    $('#delete_comment_ban_perm').prop('checked', false);
}
$('#btn_delete_comment').click(function() {
    $('#comment_delete_div').hide();
    $('#comment_delete_buttons').hide();
    $('#comment_delete_error').hide();
    $('#comment_delete_progress').show();
    $.ajax({
        type: 'POST',
        url: '/blog/comment/delete',
        data: {
            cid: delete_comment_id,
            ban72: $('#delete_comment_ban_72').is(':checked'),
            banperm: $('#delete_comment_ban_perm').is(':checked')
        },
        dataType: "json",
        success: function (data) {   
            if (data.status==1) {
                $('#comment_delete_div').show();
                $('#comment_delete_buttons').show();
                $('#comment_delete_progress').hide();
                $('#comment_delete_dialog').modal('hide');
                $('#comment_'+delete_comment_id+'_body').html('<span class="text-muted">'+js_lang_comment_deleted+'</span>')
            } else {         
                $('#comment_delete_div').show();
                $('#comment_delete_buttons').show();
                $('#comment_delete_error').show();
                $('#comment_delete_progress').hide();    
            }            
        },
        error: function () {
            $('#comment_delete_div').show();
            $('#comment_delete_buttons').show();
            $('#comment_delete_error').show();
            $('#comment_delete_progress').hide();
        }
    });       
});