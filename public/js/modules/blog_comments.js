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
                    $('#comment_'+cid).after(data.html);
                }
                $('#blog_comment_write').click();
                $('.comment_reply').click(comment_reply);
            } else {                
            }
            $('#comments_form').show();
            $('#comments_ajax_notify').hide();            
        },
        error: function () {
            $('#comments_form').show();
            $('#comments_ajax_notify').hide();
        }
    });
});
var comment_reply = function() {
    $('#comment_reply_'+comment_id).show();
    var id = this.id.replace("comment_reply_","");
    var cfw = $('#comments_form_wrap').detach();
    $('#comment_reply_attach_'+id).html(cfw);
    $('#comment_reply_'+id).hide();
    $('#blog_comment_write').show();
    comment_id = id;   
    $('#comment').val('');
    $('#comment').focus();
};
$('.comment_reply').click(comment_reply);
$('#blog_comment_write').click(function() {
    $('#blog_comment_write').hide();
    var cfw = $('#comments_form_wrap').detach();
    $('#blog_comment_dock').html(cfw);
    $('#comment_reply_'+comment_id).show();
    comment_id = 0;
    $('#comment').val('');
    $('#comment').focus();
});