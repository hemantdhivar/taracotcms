$('#moderator_wrench').click(function() {
    $('#moderator_dialog').modal();
    //$('#editpost').attr('checked', false);
    //$('#ban72').attr('checked', false);
    //$('#banperm').attr('checked', false);
    //$('#delpost').attr('checked', false);
});
$('#btn_moderate').click(function() {
	$('#moderator_dialog_progress').show();
	$('#moderator_dialog_error').hide();
	$('#moderator_dialog_div').hide();
	$('#moderator_dialog_buttons').hide();
	$.ajax({
        type: 'POST',
        url: '/blog/moderate/process',
        data: {
        	pid: post_id,
            modreq: $('#modreq').is(':checked'),
            editpost: $('#editpost').is(':checked'),
            ban72: $('#ban72').is(':checked'),
            banperm: $('#banperm').is(':checked'),
            delpost: $('#delpost').is(':checked')
        },
        dataType: "json",
        success: function (data) {        	
            if (data.status == 1) {
            	if (data.redirect) {
            		location.href = data.redirect;
            	}
           } else {
           		$('#moderator_dialog_error').show();
           		$('#moderator_dialog_progress').hide();			
				$('#moderator_dialog_div').show();
				$('#moderator_dialog_buttons').show();
           }
        },
        error: function () {
        	$('#moderator_dialog_error').show();
           	$('#moderator_dialog_progress').hide();			
			$('#moderator_dialog_div').show();
			$('#moderator_dialog_buttons').show();
        }
    });
});