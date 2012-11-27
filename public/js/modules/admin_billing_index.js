$('#domain_exp').datepicker({weekStart:js_lang_domain_date_picker_week_start});
// Init variables
var hosting_edit_id=0;
var domain_edit_id=0;
var dtable;

$(document).ready(function() {
  $().dropdown();
  var mobile_mode = $('#mobile_mode').is(":visible");
  var row_id=0;
  // Init data table
  if (mobile_mode) {
    $('#data_table_mobile').show();
    dtable=$('#data_table_mobile').dataTable( {
      "sDom": "rtip",
      "bLengthChange": true,
      "bServerSide": true,
      "bProcessing": true,
      "sPaginationType": "bootstrap",
      "iDisplayLength": 10,
      "bAutoWidth": false,
      "sAjaxSource": "/admin/billing/data/list?mobile=true",
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
       { "bSortable": false, "aTargets": [ 3 ] },
       { "fnRender": function ( oObj, sVal ) {
           return '<div style="text-align:center;width:92px"><span class="btn" onclick="editData('+row_id+')"><i style="cursor:pointer" class="icon-pencil"></i></span></div>';
         },
         "aTargets": [ 3 ]
       },
       { "fnRender": function ( oObj, sVal ) {
           if (!sVal) {
            sVal="&mdash;"
           }
           return '<div id="amount_'+row_id+'"" style="text-align:center">'+sVal+'</div';
         },
         "aTargets": [ 2 ]
       },
       { "fnRender": function ( oObj, sVal ) {
           row_id=sVal;
           return sVal;
         },
         "aTargets": [ 0 ]
       },
       { "fnRender": function ( oObj, sVal ) {
           return '<div id="username_'+row_id+'">'+sVal+'</div';
         },
         "aTargets": [ 1 ]
       }
      ]
    }); // dtable mobile
  } else {
    $('#data_table').show();
    dtable=$('#data_table').dataTable( {
      "sDom": "frtip",
      "bLengthChange": false,
      "bServerSide": true,
      "bProcessing": true,
      "sPaginationType": "bootstrap",
      "iDisplayLength": 10,
      "bAutoWidth": true,
      "sAjaxSource": "/admin/billing/data/list",
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
       { "bSortable": false, "aTargets": [ 5 ] },
       { "fnRender": function ( oObj, sVal ) {
           return '<div style="text-align:center"><span class="btn" onclick="editData('+row_id+')"><i style="cursor:pointer" class="icon-pencil"></i></span></div>';
         },
         "aTargets": [ 5 ]
       },       
       { "fnRender": function ( oObj, sVal ) {
           row_id=sVal;
           return sVal;
         },
         "aTargets": [ 0 ]
       },
       { "fnRender": function ( oObj, sVal ) {
           return '<div id="username_'+row_id+'">'+sVal+'</div';
         },
         "aTargets": [ 1 ]
       },
       { "fnRender": function ( oObj, sVal ) {
           return '<div id="realname_'+row_id+'">'+sVal+'</div';
         },
         "aTargets": [ 2 ]
       },
       { "fnRender": function ( oObj, sVal ) {
           return '<div id="email_'+row_id+'">'+sVal+'</div';
         },
         "aTargets": [ 3 ]
       },
       { "fnRender": function ( oObj, sVal ) {
           if (!sVal) {
            sVal="&mdash;"
           }
           return '<div id="amount_'+row_id+'"" style="text-align:center">'+sVal+'</div';
         },
         "aTargets": [ 4 ]
       }
      ]
    }); // dtable desktop
  }
} );

function editData(id) {
   edit_id=id; 
   $('#data_edit').show();
   $('#data_overview').hide();
   $('#data_form').hide();
   $('#data_form_buttons').hide();
   $('#ajax_loading').show();
   $('#ajax_loading_msg').html(js_lang_ajax_loading);
   $.ajax({
        type: 'POST',
        url: '/admin/billing/data/load',
        data: { id: edit_id },
        dataType: "json",
        success: function(data) {
          if (data.result == '0') {
             $('#data_form_buttons').show();
             $('#ajax_loading').hide();
             $('#data_form').html("<br/><br/>js_lang_load_error");
             $('#data_form').show();
           } else {
             $('#data_form').show();
             $('#username').html('<img src="'+data.avatar+'" width="50" height="50" alt="" class="taracot-avatar" />&nbsp;'+data.username);
             $('#funds').html(data.amount);
             $('#ajax_loading').hide();             
             $('#data_form_buttons').show();    
             // Show hosting accounts
             if (data.hosting) {               
               var tdata;
               tdata='<br/><table class="table" id="hosting_table"><tbody>';               
               for (var i = 0; i < data.hosting.length; i++) {
                tdata+="<tr id=\"hosting_row_"+data.hosting[i].id+"\"><td><span id=\"hosting_account_name_"+data.hosting[i].id+"\">"+data.hosting[i].account+"</span></td><td>"+data.hosting[i].plan_name+" <small style=\"color:#666\">("+data.hosting[i].plan_cost+"/"+js_lang_hac_per_month+")</small></td><td width=\"60\"><i class=\" icon-time\"></i>&nbsp;"+data.hosting[i].days+"</td><td style=\"width:30px\" nowrap=\"nowrap\"><span class=\"btn btn-mini\" onclick=\"editHosting('"+data.hosting[i].id+"')\"><i class=\"icon-pencil\"></i></span>&nbsp;<span class=\"btn btn-mini btn-danger\" onclick=\"deleteHosting('"+data.hosting[i].id+"')\"><i class=\"icon-trash icon-white\"></i></span></td></tr>";
               }
               tdata+="</tbody></table>";
               $('#data_accounts').html(tdata);
               var hplans='';
               if (data.hosting_plans) {
                for (var i = 0; i < data.hosting_plans.length; i++) {
                  var name = data.hosting_plans[i].name || '';
                  var id = data.hosting_plans[i].id || '';
                  var cost = data.hosting_plans[i].cost || 0;
                  hplans+="<option value=\""+id+"\">"+name+" ("+cost+"/"+js_lang_hac_per_month+")</option>";
                }
               }
               $('#hplan').html(hplans);
             } else {
              $('#data_accounts').html("<br/>js_lang_no_hosting_accounts");              
             }
             // Show domains
             if (data.domains) {               
               var ddata;
               ddata='<br/><table class="table" id="domain_table"><tbody>';               
               for (var i = 0; i < data.domains.length; i++) {
                ddata+="<tr id=\"domain_row_"+data.domains[i].id+"\"><td><span id=\"domain_name_"+data.domains[i].id+"\">"+data.domains[i].domain_name+"</span></td><td width=\"100\"><i class=\" icon-calendar\"></i>&nbsp;"+data.domains[i].exp_date+"</td><td style=\"width:30px\" nowrap=\"nowrap\"><span class=\"btn btn-mini\" onclick=\"editDomain('"+data.domains[i].id+"')\"><i class=\"icon-pencil\"></i></span>&nbsp;<span class=\"btn btn-mini btn-danger\" onclick=\"deleteDomain('"+data.domains[i].id+"')\"><i class=\"icon-trash icon-white\"></i></span></td></tr>";
               }
               ddata+="</tbody></table>";
               $('#data_domains').html(ddata);               
             } else {
              $('#data_domains').html("<br/>js_lang_no_domains");              
             }
           }
        },
        error: function() {
          $('#data_form_buttons').show();
          $('#ajax_loading').hide();
          $('#data_form').html("<br/><br/>js_lang_load_error");
          $('#data_form').show();                
        }
   });  //ajax
}

// Button "Close" handler (Dialog: "Hosting account")
$('#btn_hosting_dialog_close').click( function () {
   $('#hosting_edit_dialog').modal('hide');
});

// Button "Close" handler (Dialog: "Domain")
$('#btn_domain_dialog_close').click( function () {
   $('#domain_edit_dialog').modal('hide');
});

// Button "Return to list" hanlder
$('#btn_return_to_list').click( function() {
  $('#data_edit').hide();
  $('#data_overview').show();
});

// Add hosting account button event handler
$('#btn_add_hosting').click( function () {
  $('#cg_haccount').removeClass('error');
  $('#cg_hplan').removeClass('error');
  $('#cg_hdays').removeClass('error');
  $('#hosting_edit_form_error').hide();
  $('#hosting_edit_ajax').hide();
  $('#hosting_edit_form').show();
  $('#hosting_edit_buttons').show();
  $('#haccount').val('');
  $('#hdays').val('');
  $('#hosting_edit_dialog_title').html(js_lang_add_account);
  $('select option:first-child').attr("selected", "selected");
  $('#hosting_edit_dialog').modal({keyboard: true}); 
  $('#haccount').focus();
  hosting_edit_id=0;
});

// Add domain button event handler
$('#btn_add_domain').click( function () {
  $('#cg_domain_name').removeClass('error');
  $('#cg_domain_exp').removeClass('error');
  $('#domain_edit_form_error').hide();
  $('#domain_edit_ajax').hide();
  $('#domain_edit_form').show();
  $('#domain_edit_buttons').show();
  $('#domain_name').val('');
  $('#domain_exp').val('');
  $('#domain_edit_dialog_title').html(js_lang_add_domain);
  $('#domain_edit_dialog').modal({keyboard: true}); 
  $('#domain_name').focus();
  domain_edit_id=0;
});

// Add/edit hosting account save button click event
$('#btn_hosting_dialog_save').click( function () {
  $('#cg_haccount').removeClass('error');
  $('#cg_hplan').removeClass('error');
  $('#cg_hdays').removeClass('error');
  $('#hosting_edit_form_error').hide();
  var errors=false;
  if (!$('#haccount').val().match(/^[A-Za-z0-9_\-]{1,100}$/)) { 
    $('#cg_haccount').addClass('error');
    errors=true;   
  }
  if (!$('#hdays').val().match(/^[0-9]{1,4}$/)) { 
    $('#cg_hdays').addClass('error');
    errors=true;   
  }
  if (errors) {
    $('#hosting_edit_form_error_text').html(js_lang_form_errors);
    $('#hosting_edit_form_error').fadeIn(400);
    $('#hosting_edit_form_error').alert();
    $('#haccount').focus();
  } else {
    $('#hosting_edit_ajax_msg').html(js_lang_ajax_saving);
    $('#hosting_edit_ajax').show();
    $('#hosting_edit_form').hide();
    $('#hosting_edit_buttons').hide();  
    $.ajax({
          type: 'POST',
          url: '/admin/billing/data/hosting/save',
          data: { id: hosting_edit_id, haccount: $('#haccount').val(), hplan: $('#hplan').val(), hdays: $('#hdays').val() },
          dataType: "json",
          success: function(data) {
            if (data.result == '0') {
              if (data.error) { // ERROR
               $('#hosting_edit_form_error_text').html(data.error);
               $('#hosting_edit_form_error').fadeIn(400);
               $('#hosting_edit_form_error').alert();
              }              
              $('#hosting_edit_ajax').hide();
              $('#hosting_edit_form').show();
              $('#hosting_edit_buttons').show(); 
              $('#ajax_loading').hide();
              if (data.field) {
               $('#cg_'+data.field).addClass('error');
               $('#'+data.field).focus();
              }
             } else { // OK
              $.jmessage(js_lang_success, js_lang_data_saved, 2500, 'jm_message_success');
              if (!hosting_edit_id) {
                var tdata;
                tdata+="<tr id=\"hosting_row_"+data.id+"\"><td><span id=\"hosting_account_name_"+data.id+"\">"+data.haccount+"</span></td><td>"+data.hplan_name+" <small style=\"color:#666\">("+data.hplan_cost+"/js_lang_hac_per_month)</small></td><td width=\"60\"><i class=\" icon-time\"></i>&nbsp;"+data.hdays+"</td><td style=\"width:30px\" nowrap=\"nowrap\"><span class=\"btn btn-mini\"><i class=\"icon-pencil\" onclick=\"editHosting('"+data.id+"')\"></i></span>&nbsp;<span class=\"btn btn-mini btn-danger\"  onclick=\"deleteHosting('"+data.id+"')\"><i class=\"icon-trash icon-white\"></i></span></td></tr>";
                $('#hosting_table tr:last').after(tdata);
              } else {
                $("#hosting_row_"+data.id).html("<td><span id=\"hosting_account_name_"+data.id+"\">"+data.haccount+"</span></td><td>"+data.hplan_name+" <small style=\"color:#666\">("+data.hplan_cost+"/js_lang_hac_per_month)</small></td><td width=\"60\"><i class=\" icon-time\"></i>&nbsp;"+data.hdays+"</td><td style=\"width:30px\" nowrap=\"nowrap\"><span class=\"btn btn-mini\"><i class=\"icon-pencil\" onclick=\"editHosting('"+data.id+"')\"></i></span>&nbsp;<span class=\"btn btn-mini btn-danger\"  onclick=\"deleteHosting('"+data.id+"')\"><i class=\"icon-trash icon-white\"></i></span></td>")
              }
              $('#hosting_edit_dialog').modal('hide');
             }
          },
          error: function() {
            $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
            $('#hosting_edit_ajax').hide();
            $('#hosting_edit_form').show();
            $('#hosting_edit_buttons').show(); 
          }
      });     
    }  
});

// Add/edit domain save button click event
$('#btn_domain_dialog_save').click( function () {
  $('#cg_domain_name').removeClass('error');
  $('#cg_domain_exp').removeClass('error');
  $('#domain_edit_form_error').hide();
  var errors=false;
  if (!$('#domain_name').val().match(/^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,6}$/)) { 
    $('#cg_domain_name').addClass('error');
    errors=true;   
  }
  if (!$('#domain_exp').val().match(/^[0-9\.\/\-]{1,12}$/)) { 
    $('#cg_domain_exp').addClass('error');
    errors=true;   
  }
  if (errors) {
    $('#domain_edit_form_error_text').html(js_lang_form_errors);
    $('#domain_edit_form_error').fadeIn(400);
    $('#domain_edit_form_error').alert();
    $('#domain_name').focus();
  } else {
    $('#domain_edit_ajax_msg').html(js_lang_ajax_saving);
    $('#domain_edit_ajax').show();
    $('#domain_edit_form').hide();
    $('#domain_edit_buttons').hide();  
    $.ajax({
          type: 'POST',
          url: '/admin/billing/data/domain/save',
          data: { id: domain_edit_id, domain_name: $('#domain_name').val(), domain_exp: $('#domain_exp').val() },
          dataType: "json",
          success: function(data) {
            if (data.result == '0') {
              if (data.error) { // ERROR
               $('#domain_edit_form_error_text').html(data.error);
               $('#domain_edit_form_error').fadeIn(400);
               $('#domain_edit_form_error').alert();
              }              
              $('#domain_edit_ajax').hide();
              $('#domain_edit_form').show();
              $('#domain_edit_buttons').show(); 
              $('#ajax_loading').hide();
              if (data.field) {
               $('#cg_'+data.field).addClass('error');
               $('#'+data.field).focus();
              }
             } else { // OK
              $.jmessage(js_lang_success, js_lang_data_saved, 2500, 'jm_message_success');
              if (!domain_edit_id) {
                var ddata;
                ddata+="<tr id=\"domain_row_"+data.id+"\"><td><span id=\"domain_name_"+data.id+"\">"+data.domain_name+"</span></td><td width=\"100\"><i class=\" icon-calendar\"></i>&nbsp;"+data.domain_exp+"</td><td style=\"width:30px\" nowrap=\"nowrap\"><span class=\"btn btn-mini\" onclick=\"editDomain('"+data.id+"')\"><i class=\"icon-pencil\"></i></span>&nbsp;<span class=\"btn btn-mini btn-danger\" onclick=\"deleteDomain('"+data.id+"')\"><i class=\"icon-trash icon-white\"></i></span></td></tr>";
                $('#domain_table tr:last').after(ddata);
              } else {
                $("#domain_row_"+data.id).html("<td><span id=\"domain_name_"+data.id+"\">"+data.domain_name+"</span></td><td width=\"100\"><i class=\" icon-calendar\"></i>&nbsp;"+data.domain_exp+"</td><td style=\"width:30px\" nowrap=\"nowrap\"><span class=\"btn btn-mini\" onclick=\"editDomain('"+data.id+"')\"><i class=\"icon-pencil\"></i></span>&nbsp;<span class=\"btn btn-mini btn-danger\" onclick=\"deleteDomain('"+data.id+"')\"><i class=\"icon-trash icon-white\"></i></span></td>");
              }
              $('#domain_edit_dialog').modal('hide');
             }
          },
          error: function() {
            $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
            $('#domain_edit_ajax').hide();
            $('#domain_edit_form').show();
            $('#domain_edit_buttons').show(); 
          }
      });     
    }  
});

function editHosting(id) {
  $('#hosting_edit_dialog_title').html(js_lang_edit_account);  
  $('#cg_haccount').removeClass('error');
  $('#cg_hplan').removeClass('error');
  $('#cg_hdays').removeClass('error');
  $('#hosting_edit_form_error').hide();
  hosting_edit_id=id;
  $('#hosting_edit_dialog').modal({keyboard: true}); 
  $('#hosting_edit_ajax_msg').html(js_lang_ajax_loading);
  $('#hosting_edit_ajax').show();
  $('#hosting_edit_form').hide();
  $('#hosting_edit_buttons').hide();  
  $.ajax({
          type: 'POST',
          url: '/admin/billing/data/hosting/load',
          data: { id: hosting_edit_id },
          dataType: "json",
          success: function(data) {
            if (data.result == '0') {
              $('#hosting_edit_dialog').modal('hide'); 
              $.jmessage(js_lang_error, js_lang_data_loading_error, 2500, 'jm_message_error');
             } else { // OK
              var haccount = data.haccount || '';
              var hplan = data.hplan || '';
              var hdays = data.hdays || '0';
              $('#haccount').val(haccount);
              $('#hplan').val(hplan);
              $('#hdays').val(hdays);
              $('#hosting_edit_ajax').hide();
              $('#hosting_edit_form').show();
              $('#hosting_edit_buttons').show(); 
             }
          },
          error: function() {
            $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
            $('#hosting_edit_ajax').hide();
            $('#hosting_edit_form').show();
            $('#hosting_edit_buttons').show(); 
          }
  });  
}

function editDomain(id) {
  $('#domain_edit_dialog_title').html(js_lang_edit_domain);  
  $('#cg_domain_name').removeClass('error');
  $('#cg_domain_exp').removeClass('error');
  $('#domain_edit_form_error').hide();
  domain_edit_id=id;
  $('#domain_edit_dialog').modal({keyboard: true}); 
  $('#domain_edit_ajax_msg').html(js_lang_ajax_loading);
  $('#domain_edit_ajax').show();
  $('#domain_edit_form').hide();
  $('#domain_edit_buttons').hide();  
  $.ajax({
          type: 'POST',
          url: '/admin/billing/data/domain/load',
          data: { id: domain_edit_id },
          dataType: "json",
          success: function(data) {
            if (data.result == '0') {
              $('#domain_edit_dialog').modal('hide'); 
              $.jmessage(js_lang_error, js_lang_data_loading_error, 2500, 'jm_message_error');
             } else { // OK
              var domain_name = data.domain_name || '';
              var domain_exp = data.domain_exp || '';
              $('#domain_name').val(domain_name);
              $('#domain_exp').val(domain_exp);
              $('#domain_edit_ajax').hide();
              $('#domain_edit_form').show();
              $('#domain_edit_buttons').show(); 
             }
          },
          error: function() {
            $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
            $('#domain_edit_ajax').hide();
            $('#domain_edit_form').show();
            $('#domain_edit_buttons').show(); 
          }
  });  
}

function deleteHosting(id) {
  if (!confirm("js_lang_data_delete_confirm:\n\n"+$('#hosting_account_name_'+id).html())) {
    return false;
  } 
  $("#hosting_row_"+id).fadeOut(400);
  $.ajax({
          type: 'POST',
          url: '/admin/billing/data/hosting/delete',
          data: { id: id },
          dataType: "json",
          success: function(data) {
            if (data.result == '0') {
              $('#hosting_edit_dialog').modal('hide'); 
              $.jmessage(js_lang_error, js_lang_data_delete_error, 2500, 'jm_message_error');
              $("#hosting_row_"+id).fadeIn(400);
             } else { // OK         
              $("#hosting_row_"+id).html('');
              $.jmessage(js_lang_success, js_lang_data_delete_ok, 2500, 'jm_message_success');
             }
          },
          error: function() {
            $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
            $("#hosting_row_"+id).fadeIn(400);
          }
  });  
}

function deleteDomain(id) {
  if (!confirm("js_lang_data_delete_confirm:\n\n"+$('#domain_name_'+id).html())) {
    return false;
  } 
  $("#domain_row_"+id).fadeOut(400);
  $.ajax({
          type: 'POST',
          url: '/admin/billing/data/domain/delete',
          data: { id: id },
          dataType: "json",
          success: function(data) {
            if (data.result == '0') {
              $('#domain_edit_dialog').modal('hide'); 
              $.jmessage(js_lang_error, js_lang_data_delete_error, 2500, 'jm_message_error');
              $("#domain_row_"+id).fadeIn(400);
             } else { // OK         
              $("#domain_row_"+id).html('');
              $.jmessage(js_lang_success, js_lang_data_delete_ok, 2500, 'jm_message_success');
             }
          },
          error: function() {
            $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
            $("#domain_row_"+id).fadeIn(400);
          }
  });  
}