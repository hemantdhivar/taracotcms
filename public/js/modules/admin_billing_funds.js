$("#trans_date").datepicker({
  format: js_lang_trans_datetime_picker_template,
  weekStart: js_lang_trans_datetime_picker_week_start
});

// Init variables
var dtable;
var history_edit_id=0;

$(document).ready(function() {
  $().dropdown();
  var row_id=0;
    $('#data_table').show();
    dtable=$('#data_table').dataTable( {
      "sDom": "frtip",      
      "bLengthChange": false,
      "bServerSide": true,
      "bProcessing": true,
      "aaSorting": [[ 3, "desc" ]],
      "sPaginationType": "bootstrap",
      "iDisplayLength": 10,
      "bAutoWidth": false,
      "sAjaxSource": "/admin/billing/funds/data/list?id="+js_user_id,
      "fnServerData": function ( sSource, aoData, fnCallback ) {
            $.getJSON( sSource, aoData, function (json) {
                if (json.history_ids) {
                  var trans_ids='<option value="">&mdash;</option>';
                  for (var i=0; i<json.history_ids.length; i++) {
                    trans_ids+='<option value="'+json.history_ids[0]+'">'+json.history_names[i]+'</option>';
                  }
                  $('#trans_id').html(trans_ids);
                }
                fnCallback(json);
            } );
      },
      "oLanguage": {
        "oPaginate": {
          "sPrevious":  js_lang_sPrevious,                                
          "sNext":  js_lang_sNext
        },
        "sLengthMenu": js_lang_sLengthMenu,
        "sZeroRecords": js_lang_sZeroRecords,
        "sInfo": js_lang_sInfo,
        "sInfoEmpty": js_lang_sInfoEmpty,
        "sInfoFiltered": js_lang_sInfoFiltered,
        "sSearch": js_lang_sSearch+":&nbsp;",
      },       
      "aoColumnDefs": [
       { "bSortable": false, "aTargets": [ 4 ] },
       { "bVisible": false, "aTargets": [ 0 ] },
       { "fnRender": function ( oObj, sVal ) {
           return '<div style="text-align:center"><span class="btn" onclick="editData('+row_id+')"><i style="cursor:pointer" class="icon-pencil"></i></span>&nbsp;<span class="btn btn-danger" onclick="deleteData('+row_id+')"><i style="cursor:pointer" class="icon-trash icon-white"></i></span></div>';
         },
         "aTargets": [ 4 ]
       },       
       { "fnRender": function ( oObj, sVal ) {
           row_id=sVal;
           return sVal;
         },
         "aTargets": [ 0 ]
       },
       { "fnRender": function ( oObj, sVal ) {
           return '<div id="reason_'+row_id+'">'+sVal+'</div';
         },
         "aTargets": [ 1 ]
       },
       { "fnRender": function ( oObj, sVal ) {
           var pic='/images/plus.png';
           if (sVal < 0) { 
            pic='/images/minus.png';
            sVal=-sVal;
           }

           return '<img src="'+pic+'" width="16" height="16" alt="" />&nbsp;<span id="amount_'+row_id+'">'+sVal+'</span>';
         },
         "aTargets": [ 2 ]
       },
       { "fnRender": function ( oObj, sVal ) {
           return '<div id="date_'+row_id+'">'+sVal+'</div';
         },
         "aTargets": [ 3 ]
       }
      ]
    }); // dtable desktop
} );

// Button "Close" handler (Dialog: "History edit")
$('#btn_history_dialog_close').click( function () {
   $('#history_edit_dialog').modal('hide');
});

// Add history account button event handler
$('#btn_add').click( function () {
  $('#cg_trans_id').removeClass('error');
  $('#cg_trans_objects').removeClass('error');
  $('#cg_trans_amount').removeClass('error');
  $('#cg_trans_date').removeClass('error');
  $('#history_edit_form_error').hide();
  $('#history_edit_ajax').hide();
  $('#history_edit_form').show();
  $('#history_edit_buttons').show();
  $('#trans_objects').val('');
  $('#trans_amount').val('');
  $('#trans_date').val('');
  $('select option:first-child').attr("selected", "selected");
  $('#history_edit_dialog_title').html(js_lang_add_history_record);
  $('#history_edit_dialog').modal({keyboard: true}); 
  $('#trans_id').focus();
  history_edit_id=0;
});

// Add/edit history record save button click event
$('#btn_history_dialog_save').click( function () {
  $('#cg_trans_id').removeClass('error');
  $('#cg_trans_objects').removeClass('error');
  $('#cg_trans_amount').removeClass('error');
  $('#cg_trans_date').removeClass('error');
  $('#history_edit_form_error').hide();
  var errors=false;
  if (!$('#trans_objects').val().match(/^.{0,250}$/)) { 
    $('#cg_trans_objects').addClass('error');
    errors=true;   
  }
  if (!$('#trans_amount').val().match(/^[0-9\.\-]{1,7}$/)) { 
    $('#cg_trans_amount').addClass('error');
    errors=true;   
  }
  if (!$('#trans_date').val().match(/^[0-9\.\/\-\: ]{1,20}$/)) { 
    $('#cg_trans_date').addClass('error');
    errors=true;   
  }
  if (errors) {
    $('#history_edit_form_error_text').html(js_lang_form_errors);
    $('#history_edit_form_error').fadeIn(400);
    $('#history_edit_form_error').alert();
    $('#history_name').focus();
  } else {
    $('#history_edit_ajax_msg').html(js_lang_ajax_saving);
    $('#history_edit_ajax').show();
    $('#history_edit_form').hide();
    $('#history_edit_buttons').hide();  
    $.ajax({
          type: 'POST',
          url: '/admin/billing/data/funds/history/save',
          data: { id: history_edit_id, user_id: js_user_id, trans_id: $('#trans_id').val(), trans_objects: $('#trans_objects').val(), trans_amount: $('#trans_amount').val(), trans_date: $('#trans_date').val()  },
          dataType: "json",
          success: function(data) {
            if (data.result == '0') {
              if (data.error) { // ERROR
               $('#history_edit_form_error_text').html(data.error);
               $('#history_edit_form_error').fadeIn(400);
               $('#history_edit_form_error').alert();
              }              
              $('#history_edit_ajax').hide();
              $('#history_edit_form').show();
              $('#history_edit_buttons').show(); 
              $('#ajax_loading').hide();
              if (data.field) {
               $('#cg_'+data.field).addClass('error');
               $('#'+data.field).focus();
              }
             } else { // OK
              $.jmessage(js_lang_success, js_lang_data_saved, 2500, 'jm_message_success');
              dtable.fnReloadAjax(); 
              $('#history_edit_dialog').modal('hide');
             }
          },
          error: function() {
            $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
            $('#history_edit_ajax').hide();
            $('#history_edit_form').show();
            $('#history_edit_buttons').show(); 
          }
      });     
    }  
});