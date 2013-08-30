var dtable;
var row_status;
$(document).ready(function () {
	var wbbOpt={
    imgupload:false,buttons:"bold,italic,underline,strike,sup,sub,|,img,video,link,|,bullist,numlist,|,fontcolor,fontsize,fontfamily,|,justifyleft,justifycenter,justifyright,|,quote,code,offtop,table,removeFormat,cutpage",
  allButtons:{cutpage:{title:'[== $lang->{btn_cut} =]',buttonText:'CUT',transform: {'<div class="blog-post-cut"></div>':'[cut]'}}}
  	};
  	if (lng != 'ru'){wbbOpt['lang']=lng}  
    $('#wbbeditor').wysibb(wbbOpt);	
	var row_id = 0;
	dtable = $('#data_table').dataTable({
            "sDom": "rtip",
            "bLengthChange": true,
            "bServerSide": true,
            "bProcessing": true,
            "sPaginationType": "bootstrap",
            "iDisplayLength": 10,
            "bAutoWidth": false,
            "sAjaxSource": "/support/data/list",            
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
            "aoColumnDefs": [{
                "bSortable": true,
                "aTargets": [0,1,2,3,4,5]
            }, {
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
            	$(nRow).on('click', function() {
      				supportRowClicked(aData[0]);
    			});
				return nRow;
			}
    }); // dtable init
}); // document.ready

function supportRowClicked(clicked_id) {
	$('#support_table').hide();
	$('#support_ticket').show();
	$('#support_ticket_ajax').show();
	$('#support_ticket_error').hide();
	$('#support_ticket_data').hide();
	$('#support_answers').html('');
	$('#support_buttons').hide();
	$('#btn_post_reply').hide();
	$('#wbbeditor').bbcode(' ');
	$('#wbbeditor').htmlcode(' ');	
	$.ajax({
        type: 'POST',
        url: '/support/ticket/load',
        data: {
        	tid: clicked_id
        },
        dataType: "json",
        success: function (data) {              	
        	$('#support_buttons').show();
            if (data.status == 1) {                 	   
            	$('#support_ticket_ajax').hide();
				$('#support_ticket_data').show(); 
				$('#btn_post_reply').show();
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

$('#btn_return_list').click(function() {
	$('#support_ticket').hide();
	$('#support_table').show();
	dtable.fnReloadAjax();	
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