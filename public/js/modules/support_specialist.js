var dtable;
var row_status;
var current_id = 0;
$(document).ready(function () {
	var wbbOpt={
    imgupload:false,buttons:"bold,italic,underline,strike,sup,sub,|,img,video,link,|,bullist,numlist,|,fontcolor,fontsize,fontfamily,|,justifyleft,justifycenter,justifyright,|,quote,code,offtop,table,removeFormat,cutpage",
  allButtons:{cutpage:{title:'[== $lang->{btn_cut} =]',buttonText:'CUT',transform: {'<div class="blog-post-cut"></div>':'[cut]'}}}
  	};
  	if (lng != 'ru'){wbbOpt['lang']=lng}  
    $('#wbbeditor').wysibb(wbbOpt);
    $('#wbbeditor2').wysibb(wbbOpt);
	var row_id = 0;
	dtable = $('#data_table').dataTable({
            "sDom": "rtip",
            "bLengthChange": true,
            "bServerSide": true,
            "bProcessing": true,
            "sPaginationType": "bootstrap",
            "iDisplayLength": 10,
            "bAutoWidth": false,
            "sAjaxSource": "/support/data/list_specialist",            
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
            },
            "aaSorting": [[ 3, "desc" ]],
            "aoColumnDefs": [{
                "bSortable": true,
                "aTargets": [0,1,2,3,4,5]
            }, 

            {
                "fnRender": function (oObj, sVal) {
                	var row_status = sVal;
                	if (sVal == 0) {
                		sVal = js_lang_status_0;
                	}
                	if (sVal == 1) {
                		sVal = js_lang_status_1;
                	}
                	if (sVal == 2) {
                		sVal = js_lang_status_2;
                	}
                    return '<div style="text-align:center">'+sVal+'</div>';
                },
                "aTargets": [5]
            }, {
                "fnRender": function (oObj, sVal) {
                    return sVal;
                },
                "aTargets": [4]
            }, {
                "fnRender": function (oObj, sVal) {
                    return sVal;
                },
                "aTargets": [3]
            }, {
                "fnRender": function (oObj, sVal) {
                    return sVal;
                },
                "aTargets": [2]
            }, {
                "fnRender": function (oObj, sVal) {
                	row_id = sVal;
                    return sVal;
                },
                "aTargets": [0]
            }, {
                "fnRender": function (oObj, sVal) {
                    return sVal;
                },
                "aTargets": [1]
            }],
            "fnDrawCallback": function () {                
            },
            "fnRowCallback": function( nRow, aData, iDisplayIndex ) {
            	var row_status = aData[5];
            	nRow.className = 'support-table-tr';
            	if (row_status.indexOf(js_lang_status_2) > 0) {            		
            		nRow.className += ' success';
            	}
            	if (aData[6] == 1) {
            		nRow.className += ' warning';
            	}
                if (row_status.indexOf(js_lang_status_1) > 0) {
                    nRow.className += ' active';
                }
            	$(nRow).on('click', function() {
      				supportRowClicked(aData[0]);
    			});                
				return nRow;
			}
    }); // dtable init
}); // document.ready

function supportRowClicked(clicked_id) {
    $.history.push("ticket_"+clicked_id);
	$('#support_table').hide();
	$('#support_ticket').show();
	$('#support_ticket_ajax').show();
	$('#support_ticket_error').hide();
	$('#support_ticket_data').hide();
	$('#support_answers').html('');
	$('#support_buttons').hide();
	$('#btn_post_reply').hide();
    $('#btn_solved').hide();
	$('#wbbeditor').bbcode('');
	$('#wbbeditor').htmlcode('');
    $('#support_answer_error').hide();
    $('#ans_error_exists').hide();
    $('#ans_error_db').hide();
	$.ajax({
        type: 'POST',
        url: '/support/ticket/specialist/load',
        data: {
        	tid: clicked_id
        },
        dataType: "json",
        success: function (data) {              	
        	$('#support_buttons').show();
            if (data.status == 1) {
                current_id = clicked_id;
            	$('#support_ticket_ajax').hide();
				$('#support_ticket_data').show(); 
				$('#btn_post_reply').show();
                $('#btn_solved').show();
				if (data.stopic) {
					$('#support_ticket_topic').html(data.stopic);
				}
				if (data.stopic_id) {
					$('#support_ticket_topic_id').html(data.stopic_id);
				}
				if (data.smsg) {
					$('#support_ticket_msg').html(data.smsg);
				}				
				if (data.susername && data.sdate) {
					$('#support_ticket_head').html('<b>'+data.susername+'</b>&nbsp;<small>['+data.sdate+']</small>');
				}
				if (data.ans && data.ans.length > 0) {					
					for (var i = 0; i < data.ans.length; i++) {
						var cl = 'panel-default';
						if (data.ans[i].reply && data.ans[i].reply==1) {
							cl='panel-warning';
						}
						$('#support_answers').append('<div class="panel '+cl+'"><div class="panel-heading"><b>'+data.ans[i].susername+'</b>&nbsp;<small>['+data.ans[i].sdate+']</small></div><div class="panel-body">'+data.ans[i].smsg+'</div></div>');
					}
				}
           	} else {           	
           		$('#support_ticket_ajax').hide();
				$('#support_ticket_error').show();
           }
        },
        error: function () {
        	$('#support_buttons').show();
        	$('#support_ticket_ajax').hide();
			$('#support_ticket_error').show();
        }
    });
}

var returnToList = function() {
    $('#support_ticket').hide();
    $('#support_table').show();
    $('#support_ticket_create').hide();
    dtable.fnReloadAjax();
}

$('#btn_return_list').click(returnToList);
$('#btn_return_list2').click(returnToList);
$('#btn_return_list3').click(returnToList);

$('#btn_post_reply').click(function() {
    if (!$("#wbbeditor").bbcode()) {
        return;
    }
    $('#support_reply_form').hide();
    $('#support_reply_ajax').show();
    $('#support_buttons').hide();
    $('#support_answer_error').hide();
    $('#ans_error_exists').hide();
    $('#ans_error_db').hide();
    $.ajax({
        type: 'POST',
        url: '/support/answer/specialist/save',
        data: {
            tid: current_id,
            ans: $("#wbbeditor").bbcode()
        },
        dataType: "json",
        success: function (data) {                  
            $('#support_buttons').show();
            $('#support_reply_form').show();
            $('#support_reply_ajax').hide();
            if (data.status == 1) {
                if (data.username && data.sdate && data.ans) {
                    $('#support_answers').append('<div class="panel panel-default"><div class="panel-heading"><b>'+data.username+'</b>&nbsp;<small>['+data.sdate+']</small></div><div class="panel-body">'+data.ans+'</div></div>');
                }
                $('#wbbeditor').bbcode('');
                $('#wbbeditor').htmlcode('');
            } else {            
                if (data.status == -1) {
                    $('#support_answer_error').show();
                    $('#ans_error_exists').show();
                } else {
                    $('#support_answer_error').show();
                    $('#ans_error_db').show();
                }
            }
        },
        error: function () {
            $('#support_buttons').show();
            $('#support_reply_form').show();
            $('#support_reply_ajax').hide();
            $('#support_answer_error').show();
            $('#ans_error_db').show();
        }
    });
});

$('#btn_solved').click(function() {
    if (!confirm(js_lang_confirm_solved)) {
         return;
     }
    $('#support_reply_form').hide();
    $('#support_reply_ajax').show();
    $('#support_buttons').hide();
    $('#support_answer_error').hide();
    $('#ans_error_exists').hide();
    $('#ans_error_db').hide();
    $.ajax({
        type: 'POST',
        url: '/support/answer/specialist/solved',
        data: {
            tid: current_id
        },
        dataType: "json",
        success: function (data) {          
            $('#support_reply_form').show();
            $('#support_reply_ajax').hide();
            if (data.status == 1) {
                $('#btn_return_list').click();                
            } else {
                $('#support_answer_error').show();
                $('#ans_error_db').show();   
            }
        },
        error: function () {
            $('#support_buttons').show();
            $('#support_reply_form').show();
            $('#support_reply_ajax').hide();
            $('#support_answer_error').show();
            $('#ans_error_db').show();
        }
    });
});

// dataTable ajax fix
jQuery.fn.dataTableExt.oApi.fnProcessingIndicator = function ( oSettings, onoff ) {
    if ( typeof( onoff ) == 'undefined' ) {
        onoff = true;
    }
    this.oApi._fnProcessingDisplay( oSettings, onoff );
};
function handleDTAjaxError( xhr, textStatus, error ) {
    dtable.fnProcessingIndicator( false );
}
$.history.on('change', function(event, url, type) {
    if (url == '') {       
       $('#btn_return_list').click(); 
    }
}).listen('hash');