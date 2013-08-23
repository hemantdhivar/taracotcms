$('#domain_exp').datepicker({
    weekStart: js_lang_domain_date_picker_week_start
}).on('changeDate', function(ev){
    $("#domain_exp").datepicker('hide');
});
$('#birth_date').datepicker({
    weekStart: js_lang_domain_date_picker_week_start
}).on('changeDate', function(ev){
    $("#birth_date").datepicker('hide');
});
// Populate countries list
var cntrs = js_lang_countries.split('=');
for (var i=0; i<cntrs.length; i++) {
    var cntr = cntrs[i].split(',');
    $('#country').append('<option value="'+cntr[0]+'">'+cntr[1]+'</option>');
}
// Init variables
var hosting_edit_id = 0;
var domain_edit_id = 0;
var service_edit_id = 0;
var hosting_count = 0;
var domains_count = 0;
var services_count = 0;
var dtable;
$(document).ready(function () {
    $().dropdown();
    var mobile_mode = $('#mobile_mode').is(":visible");
    var row_id = 0;
    // Init data table
    if (mobile_mode) {
        $('#data_table_mobile').show();
        dtable = $('#data_table_mobile').dataTable({
            "sDom": "frtip",
            "bLengthChange": true,
            "bServerSide": true,
            "bProcessing": true,
            "sPaginationType": "bootstrap",
            "iDisplayLength": 10,
            "bAutoWidth": false,
            "sAjaxSource": "/admin/billing/data/list?mobile=true",
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
                "sSearch": js_lang_sSearch + ":&nbsp;",
            },
            "aoColumnDefs": [{
                "bSortable": false,
                "aTargets": [3]
            }, {
                "fnRender": function (oObj, sVal) {
                    return '<div style="text-align:center;width:92px"><span class="btn btn-default btn-sm" onclick="editData(' + row_id + ')"><i style="cursor:pointer" class="glyphicon glyphicon-pencil"></i></span></div>';
                },
                "aTargets": [3]
            }, {
                "fnRender": function (oObj, sVal) {
                    if (!sVal) {
                        sVal = "&mdash;"
                    }
                    return '<div id="amount_' + row_id + '"" style="text-align:center">' + sVal + '</div';
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
                    return '<div id="username_' + row_id + '">' + sVal + '</div';
                },
                "aTargets": [1]
            }]
        }); // dtable mobile
    } else {
        $('#data_table').show();
        dtable = $('#data_table').dataTable({
            "sDom": "frtip",
            "bLengthChange": false,
            "bServerSide": true,
            "bProcessing": true,
            "sPaginationType": "bootstrap",
            "iDisplayLength": 30,
            "bAutoWidth": true,
            "sAjaxSource": "/admin/billing/data/list",
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
                "sSearch": js_lang_sSearch + ":&nbsp;",
            },
            "aoColumnDefs": [{
                "bSortable": false,
                "aTargets": [5]
            }, {
                "fnRender": function (oObj, sVal) {
                    return '<div style="text-align:center"><span class="btn btn-default btn-sm" onclick="editData(' + row_id + ')"><i style="cursor:pointer" class="glyphicon glyphicon-pencil"></i></span></div>';
                },
                "aTargets": [5]
            }, {
                "fnRender": function (oObj, sVal) {
                    row_id = sVal;
                    return sVal;
                },
                "aTargets": [0]
            }, {
                "fnRender": function (oObj, sVal) {
                    return '<div id="username_' + row_id + '">' + sVal + '</div';
                },
                "aTargets": [1]
            }, {
                "fnRender": function (oObj, sVal) {
                    return '<div id="realname_' + row_id + '">' + sVal + '</div';
                },
                "aTargets": [2]
            }, {
                "fnRender": function (oObj, sVal) {
                    return '<div id="email_' + row_id + '">' + sVal + '</div';
                },
                "aTargets": [3]
            }, {
                "fnRender": function (oObj, sVal) {
                    if (!sVal) {
                        sVal = "&mdash;"
                    }
                    return '<div id="amount_' + row_id + '"" style="text-align:center">' + sVal + '</div';
                },
                "aTargets": [4]
            }]
        }); // dtable desktop
    }
});

function editData(id) {
    edit_id = id;
    $('#data_edit').show();
    $('#data_overview').hide();
    $('#data_form').hide();
    $('#data_form_buttons').hide();
    $('#ajax_loading').show();
    $('#ajax_loading_msg').html(js_lang_ajax_loading);
    $.ajax({
        type: 'POST',
        url: '/admin/billing/data/load',
        data: {
            id: edit_id
        },
        dataType: "json",
        success: function (data) {
            if (data.result == '0') {
                $('#data_form_buttons').show();
                $('#ajax_loading').hide();
                $('#data_form').html("<br/><br/>"+js_lang_load_error);
                $('#data_form').show();
            } else {
                $('#data_form').show();
                $('#username').html('<img src="' + data.avatar + '" width="50" height="50" alt="" class="taracot-avatar" />&nbsp;' + data.username);
                $('#funds').html(data.amount);
                $('#ajax_loading').hide();
                $('#data_form_buttons').show();
                // Show hosting accounts
                hosting_count = 0;
                if (data.hosting && data.hosting.length > 0) {
                    hosting_count = data.hosting.length;
                    var tdata='';
                    tdata = '<br/><table class="table table-hover taracot-billing-table" id="hosting_table"><tbody>';
                    for (var i = 0; i < data.hosting.length; i++) {
                        tdata += "<tr id=\"hosting_row_" + data.hosting[i].id + "\"><td><span id=\"hosting_account_name_" + data.hosting[i].id + "\">" + data.hosting[i].account + "</span></td><td>" + data.hosting[i].plan_name + " <small style=\"color:#666\">(" + data.hosting[i].plan_cost + "/" + js_lang_hac_per_month + ")</small></td><td width=\"60\"><i class=\" glyphicon glyphicon-time\"></i>&nbsp;" + data.hosting[i].days + "</td><td style=\"width:30px\" nowrap=\"nowrap\"><span class=\"btn btn-default btn-xs\" onclick=\"editHosting('" + data.hosting[i].id + "')\"><i class=\"glyphicon glyphicon-pencil\"></i></span>&nbsp;<span class=\"btn btn-default btn-xs btn-danger\" onclick=\"deleteHosting('" + data.hosting[i].id + "')\"><i class=\"glyphicon glyphicon-trash\"></i></span></td></tr>";
                    }
                    tdata += "</tbody></table>";
                    $('#data_accounts').html(tdata);                    
                } else {
                    $('#data_accounts').html('<br/>'+js_lang_no_hosting_accounts);
                }
                var hplans = '';                
                if (data.hosting_plans) {                    
                    for (var i = 0; i < data.hosting_plans.length; i++) {
                        var name = data.hosting_plans[i].name || '';
                        var id = data.hosting_plans[i].id || '';
                        var cost = data.hosting_plans[i].cost || 0;
                        hplans += "<option value=\"" + id + "\">" + name + " (" + cost + "/" + js_lang_hac_per_month + ")</option>";
                    }
                }
                $('#hplan').html(hplans);
                // Show domains
                domains_count = 0;
                if (data.domains && data.domains.length > 0) {
                    domains_count = data.domains.length;
                    var ddata='';
                    ddata = '<br/><table class="table table-hover taracot-billing-table" id="domain_table"><tbody>';
                    for (var i = 0; i < data.domains.length; i++) {
                        ddata += "<tr id=\"domain_row_" + data.domains[i].id + "\"><td><span id=\"domain_name_" + data.domains[i].id + "\">" + data.domains[i].domain_name + "</span></td><td width=\"100\"><i class=\" glyphicon glyphicon-calendar\"></i>&nbsp;" + data.domains[i].exp_date + "</td><td style=\"width:30px\" nowrap=\"nowrap\"><span class=\"btn btn-default btn-xs\" onclick=\"editDomain('" + data.domains[i].id + "')\"><i class=\"glyphicon glyphicon-pencil\"></i></span>&nbsp;<span class=\"btn btn-default btn-xs btn-danger\" onclick=\"deleteDomain('" + data.domains[i].id + "')\"><i class=\"glyphicon glyphicon-trash\"></i></span></td></tr>";
                    }
                    ddata += "</tbody></table>";
                    $('#data_domains').html(ddata);
                } else {
                    $('#data_domains').html("<br/>"+js_lang_no_domains);
                }
                // Show services
                services_count = 0;
                if (data.services && data.services.length > 0) {
                    services_count = data.services.length;
                    var sdata='';
                    sdata = '<br/><table class="table table-hover taracot-billing-table" id="services_table"><tbody>';
                    for (var i = 0; i < data.services.length; i++) {
                        sdata += "<tr id=\"service_row_" + data.services[i].id + "\"><td><span id=\"service_name_" + data.services[i].id + "\">" + data.services[i].service_name + " <small style=\"color:#666\">(" + data.services[i].service_cost + "/" + js_lang_hac_per_month + ")</small></span></td><td width=\"100\"><i class=\" glyphicon glyphicon-time\"></i>&nbsp;" + data.services[i].service_days_remaining + "</td><td style=\"width:30px\" nowrap=\"nowrap\"><span class=\"btn btn-default btn-xs\" onclick=\"editService('" + data.services[i].id + "')\"><i class=\"glyphicon glyphicon-pencil\"></i></span>&nbsp;<span class=\"btn btn-default btn-xs btn-danger\" onclick=\"deleteService('" + data.services[i].id + "')\"><i class=\"glyphicon glyphicon-trash\"></i></span></td></tr>";
                    }
                    sdata += "</tbody></table>";
                    $('#data_services').html(sdata);
                } else {
                    $('#data_services').html("<br/>"+js_lang_no_services);
                }
                var sid = '';
                if (data.service_plans) {
                    for (var i = 0; i < data.service_plans.length; i++) {
                        var name = data.service_plans[i].name || '';
                        var id = data.service_plans[i].id || '';
                        var cost = data.service_plans[i].cost || 0;
                        sid += "<option value=\"" + id + "\">" + name + " (" + cost + "/" + js_lang_hac_per_month + ")</option>";
                    }
                }
                $('#sid').html(sid);
            }
        },
        error: function () {
            $('#data_form_buttons').show();
            $('#ajax_loading').hide();
            $('#data_form').html("<br/><br/>"+js_lang_load_error);
            $('#data_form').show();
        }
    }); //ajax
}
// Button "Close" handler (Dialog: "Hosting account")
$('#btn_hosting_dialog_close').click(function () {
    $('#hosting_edit_dialog').modal('hide');
});
// Button "Close" handler (Dialog: "Domain")
$('#btn_domain_dialog_close').click(function () {
    $('#domain_edit_dialog').modal('hide');
});
// Button "Close" handler (Dialog: "Services")
$('#btn_service_dialog_close').click(function () {
    $('#service_edit_dialog').modal('hide');
});
// Button "Close" handler (Dialog: "Profile")
$('#btn_profile_dialog_close').click(function () {
    $('#profile_edit_dialog').modal('hide');
});
// Button "Return to list" hanlder
$('#btn_return_to_list').click(function () {
    $('#data_edit').hide();
    $('#data_overview').show();
});
// Add hosting account button event handler
$('#btn_add_hosting').click(function () {
    $('#cg_haccount').removeClass('has-error');
    $('#cg_hplan').removeClass('has-error');
    $('#cg_hdays').removeClass('has-error');
    $('#hosting_edit_form_error').hide();
    $('#hosting_edit_ajax').hide();
    $('#hosting_edit_form').show();
    $('#hosting_edit_buttons').show();
    $('#haccount').val('');
    $('#hdays').val('');
    $('#h_queue').removeAttr('checked');
    $('#hosting_edit_dialog_title').html(js_lang_add_account);
    $('select option:first-child').attr("selected", "selected");
    $('#hosting_edit_dialog').modal({
        keyboard: true
    });
    $('#haccount').focus();
    hosting_edit_id = 0;
});
// Add domain button event handler
$('#btn_add_domain').click(function () {
    $('#cg_domain_name').removeClass('has-error');
    $('#cg_domain_exp').removeClass('has-error');
    $('#cg_ns1').removeClass('has-error');
    $('#cg_ns2').removeClass('has-error');
    $('#cg_ns3').removeClass('has-error');
    $('#cg_ns4').removeClass('has-error');
    $('#cg_ns1_ip').removeClass('has-error');
    $('#cg_ns2_ip').removeClass('has-error');
    $('#cg_ns3_ip').removeClass('has-error');
    $('#cg_ns4_ip').removeClass('has-error');
    $('#domain_edit_form_error').hide();
    $('#domain_edit_ajax').hide();
    $('#domain_edit_form').show();
    $('#domain_edit_buttons').show();
    $('#domain_name').val('');
    $('#domain_exp').val('');
    $('#d_queue').removeAttr('checked');
    $('#ns1').val('');
    $('#ns2').val('');
    $('#ns3').val('');
    $('#ns4').val('');
    $('#ns1_ip').val('');
    $('#ns2_ip').val('');
    $('#ns3_ip').val('');
    $('#ns4_ip').val('');
    $('#domain_edit_dialog_title').html(js_lang_add_domain);
    $('#domain_edit_dialog').modal({
        keyboard: true
    });
    $('#domain_modal_body').scrollTop(0);
    $('#domain_name').focus();
    domain_edit_id = 0;
});
// Add service button event handler
$('#btn_add_service').click(function () {
    $('#cg_sid').removeClass('has-error');
    $('#cg_sdays').removeClass('has-error');
    $('#service_edit_form_error').hide();
    $('#service_edit_ajax').hide();
    $('#service_edit_form').show();
    $('#service_edit_buttons').show();
    $('select option:first-child').attr("selected", "selected");
    $('#sdays').val('');
    $('#service_edit_dialog_title').html(js_lang_add_service);
    $('#service_edit_dialog').modal({
        keyboard: true
    });
    $('#service_name').focus();
    service_edit_id = 0;
});
// Add/edit hosting account save button click event
$('#btn_hosting_dialog_save').click(function () {
    $('#cg_haccount').removeClass('has-error');
    $('#cg_hplan').removeClass('has-error');
    $('#cg_hdays').removeClass('has-error');
    $('#hosting_edit_form_error').hide();
    var errors = false;
    if (!$('#haccount').val().match(/^[A-Za-z0-9_\-]{1,100}$/)) {
        $('#cg_haccount').addClass('has-error');
        errors = true;
    }
    if (!$('#hdays').val().match(/^[0-9]{1,4}$/)) {
        $('#cg_hdays').addClass('has-error');
        errors = true;
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
        var h_queue = 0;
        if ($('input[name=h_queue]').is(':checked')) {
            h_queue = 1;
        }
        $.ajax({
            type: 'POST',
            url: '/admin/billing/data/hosting/save',
            data: {
                id: hosting_edit_id,
                user_id: edit_id,
                haccount: $('#haccount').val(),
                hplan: $('#hplan').val(),
                hdays: $('#hdays').val(),
                h_queue: h_queue
            },
            dataType: "json",
            success: function (data) {
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
                        $('#cg_' + data.field).addClass('has-error');
                        $('#' + data.field).focus();
                    }
                } else { // OK
                    $.jmessage(js_lang_success, js_lang_data_saved, 2500, 'jm_message_success');
                    if (!hosting_edit_id) {
                        hosting_count++;
                        var tdata='';
                        tdata += "<tr id=\"hosting_row_" + data.id + "\"><td><span id=\"hosting_account_name_" + data.id + "\">" + data.haccount + "</span></td><td>" + data.hplan_name + " <small style=\"color:#666\">(" + data.hplan_cost + "/" + js_lang_hac_per_month + ")</small></td><td width=\"60\"><i class=\" glyphicon glyphicon-time\"></i>&nbsp;" + data.hdays + "</td><td style=\"width:30px\" nowrap=\"nowrap\"><span class=\"btn btn-default btn-xs\"><i class=\"glyphicon glyphicon-pencil\" onclick=\"editHosting('" + data.id + "')\"></i></span>&nbsp;<span class=\"btn btn-default btn-xs btn-danger\"  onclick=\"deleteHosting('" + data.id + "')\"><i class=\"glyphicon glyphicon-trash\"></i></span></td></tr>";
                        if ($('#hosting_table tr:last').size() > 0) {
                            $('#hosting_table tr:last').after(tdata);
                        } else {
                            var ndata = '<br/><table class="table table-hover taracot-billing-table" id="hosting_table"><tbody>'+tdata+"</tbody></table>";
                            $('#data_accounts').html(ndata);
                        }
                    } else {
                        $("#hosting_row_" + data.id).html("<td><span id=\"hosting_account_name_" + data.id + "\">" + data.haccount + "</span></td><td>" + data.hplan_name + " <small style=\"color:#666\">(" + data.hplan_cost + "/" +js_lang_hac_per_month +")</small></td><td width=\"60\"><i class=\" glyphicon glyphicon-time\"></i>&nbsp;" + data.hdays + "</td><td style=\"width:30px\" nowrap=\"nowrap\"><span class=\"btn btn-default btn-xs\"><i class=\"glyphicon glyphicon-pencil\" onclick=\"editHosting('" + data.id + "')\"></i></span>&nbsp;<span class=\"btn btn-default btn-xs btn-danger\"  onclick=\"deleteHosting('" + data.id + "')\"><i class=\"glyphicon glyphicon-trash\"></i></span></td>")
                    }
                    $('#hosting_edit_dialog').modal('hide');
                }
            },
            error: function () {
                $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
                $('#hosting_edit_ajax').hide();
                $('#hosting_edit_form').show();
                $('#hosting_edit_buttons').show();
            }
        });
    }
});
// Add/edit domain save button click event
$('#btn_domain_dialog_save').click(function () {
    $('#cg_domain_name').removeClass('has-error');
    $('#cg_domain_exp').removeClass('has-error');
    $('#cg_ns1').removeClass('has-error');
    $('#cg_ns2').removeClass('has-error');
    $('#cg_ns3').removeClass('has-error');
    $('#cg_ns4').removeClass('has-error');
    $('#cg_ns1_ip').removeClass('has-error');
    $('#cg_ns2_ip').removeClass('has-error');
    $('#cg_ns3_ip').removeClass('has-error');
    $('#cg_ns4_ip').removeClass('has-error');
    $('#domain_edit_form_error').hide();
    var errors = false;
    if (!$('#domain_name').val().match(/^[A-Za-z0-9\-]{2,100}$/)) {
        $('#cg_domain_name').addClass('has-error');
        errors = true;
    }
    if (!$('#domain_exp').val().match(/^[0-9\.\/\-]{1,12}$/)) {
        $('#cg_domain_exp').addClass('has-error');
        errors = true;
    }
    if (!$('#ns1').val().match(/^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/)) {
        $('#cg_ns1').addClass('has-error');
        errors = true;
    }
    if (!$('#ns2').val().match(/^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/)) {
        $('#cg_ns2').addClass('has-error');
        errors = true;
    }
    if ($('#ns3').val() && !$('#ns3').val().match(/^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/)) {
        $('#cg_ns3').addClass('has-error');
        errors = true;
    }
    if ($('#ns4').val() && !$('#ns4').val().match(/^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/)) {
        $('#cg_ns4').addClass('has-error');
        errors = true;
    }
    if ($('#ns1_ip').val() && !$('#ns1_ip').val().match(/^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/)) {
        $('#cg_ns1_ip').addClass('has-error');
        errors = true;
    }
    if ($('#ns2_ip').val() && !$('#ns2_ip').val().match(/^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/)) {
        $('#cg_ns2_ip').addClass('has-error');
        errors = true;
    }
    if ($('#ns3_ip').val() && !$('#ns3_ip').val().match(/^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/)) {
        $('#cg_ns3_ip').addClass('has-error');
        errors = true;
    }
    if ($('#ns4_ip').val() && !$('#ns4_ip').val().match(/^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/)) {
        $('#cg_ns4_ip').addClass('has-error');
        errors = true;
    }
    if (errors) {
        $('#domain_edit_form_error_text').html(js_lang_form_errors);
        $('#domain_edit_form_error').fadeIn(400);
        $('#domain_edit_form_error').alert();
        $('#domain_modal_body').scrollTop(0);
        $('#domain_name').focus();
    } else {
        $('#domain_edit_ajax_msg').html(js_lang_ajax_saving);
        $('#domain_edit_ajax').show();
        $('#domain_edit_form').hide();
        $('#domain_edit_buttons').hide();
        var d_queue = 0;
        if ($('input[name=d_queue]').is(':checked')) {
            d_queue = 1;
        }
        $.ajax({
            type: 'POST',
            url: '/admin/billing/data/domain/save',
            data: {
                id: domain_edit_id,
                user_id: edit_id,
                domain_name: $('#domain_name').val(),
                domain_exp: $('#domain_exp').val(),
                ns1: $('#ns1').val(),
                ns2: $('#ns2').val(),
                ns3: $('#ns3').val(),
                ns4: $('#ns4').val(),
                ns1_ip: $('#ns1_ip').val(),
                ns2_ip: $('#ns2_ip').val(),
                ns3_ip: $('#ns3_ip').val(),
                ns4_ip: $('#ns4_ip').val(),
                d_queue: d_queue
            },
            dataType: "json",
            success: function (data) {
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
                        $('#cg_' + data.field).addClass('has-error');
                        $('#' + data.field).focus();
                    }
                } else { // OK
                    $.jmessage(js_lang_success, js_lang_data_saved, 2500, 'jm_message_success');
                    if (!domain_edit_id) {
                        domains_count++;
                        var ddata='';
                        ddata += "<tr id=\"domain_row_" + data.id + "\"><td><span id=\"domain_name_" + data.id + "\">" + data.domain_name + "</span></td><td width=\"100\"><i class=\" glyphicon glyphicon-calendar\"></i>&nbsp;" + data.domain_exp + "</td><td style=\"width:30px\" nowrap=\"nowrap\"><span class=\"btn btn-default btn-xs\" onclick=\"editDomain('" + data.id + "')\"><i class=\"glyphicon glyphicon-pencil\"></i></span>&nbsp;<span class=\"btn btn-default btn-xs btn-danger\" onclick=\"deleteDomain('" + data.id + "')\"><i class=\"glyphicon glyphicon-trash\"></i></span></td></tr>";
                        if ($('#domain_table tr:last').size() > 0) {
                            $('#domain_table tr:last').after(ddata);
                        } else {
                            var ndata = '<br/><table class="table table-hover taracot-billing-table" id="domain_table"><tbody>'+ddata+"</tbody></table>";
                            $('#data_domains').html(ndata);
                        }
                    } else {
                        $("#domain_row_" + data.id).html("<td><span id=\"domain_name_" + data.id + "\">" + data.domain_name + "</span></td><td width=\"100\"><i class=\" glyphicon glyphicon-calendar\"></i>&nbsp;" + data.domain_exp + "</td><td style=\"width:30px\" nowrap=\"nowrap\"><span class=\"btn btn-default btn-xs\" onclick=\"editDomain('" + data.id + "')\"><i class=\"glyphicon glyphicon-pencil\"></i></span>&nbsp;<span class=\"btn btn-default btn-xs btn-danger\" onclick=\"deleteDomain('" + data.id + "')\"><i class=\"glyphicon glyphicon-trash\"></i></span></td>");
                    }
                    $('#domain_edit_dialog').modal('hide');
                }
            },
            error: function () {
                $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
                $('#domain_edit_ajax').hide();
                $('#domain_edit_form').show();
                $('#domain_edit_buttons').show();
            }
        });
    }
});
// Add/edit service save button click event
$('#btn_service_dialog_save').click(function () {
    $('#cg_sid').removeClass('has-error');
    $('#cg_sdays').removeClass('has-error');
    $('#service_edit_form_error').hide();
    var errors = false;
    if (!$('#sdays').val().match(/^[0-9]{1,5}$/)) {
        $('#cg_sdays').addClass('has-error');
        errors = true;
    }
    if (errors) {
        $('#service_edit_form_error_text').html(js_lang_form_errors);
        $('#service_edit_form_error').fadeIn(400);
        $('#service_edit_form_error').alert();
        $('#service_name').focus();
    } else {
        $('#service_edit_ajax_msg').html(js_lang_ajax_saving);
        $('#service_edit_ajax').show();
        $('#service_edit_form').hide();
        $('#service_edit_buttons').hide();
        $.ajax({
            type: 'POST',
            url: '/admin/billing/data/service/save',
            data: {
                id: service_edit_id,
                user_id: edit_id,
                sid: $('#sid').val(),
                sdays: $('#sdays').val()
            },
            dataType: "json",
            success: function (data) {
                if (data.result == '0') {
                    if (data.error) { // ERROR
                        $('#service_edit_form_error_text').html(data.error);
                        $('#service_edit_form_error').fadeIn(400);
                        $('#service_edit_form_error').alert();
                    }
                    $('#service_edit_ajax').hide();
                    $('#service_edit_form').show();
                    $('#service_edit_buttons').show();
                    $('#ajax_loading').hide();
                    if (data.field) {
                        $('#cg_' + data.field).addClass('has-error');
                        $('#' + data.field).focus();
                    }
                } else { // OK
                    $.jmessage(js_lang_success, js_lang_data_saved, 2500, 'jm_message_success');
                    if (!service_edit_id) {
                        services_count++;
                        var ddata='';                        
                        ddata += "<tr id=\"service_row_" + data.id + "\"><td><span id=\"service_name_" + data.id + "\">" + data.service_name + " <small style=\"color:#666\">(" + data.service_cost + "/" + js_lang_hac_per_month + ")</small></span></td><td width=\"100\"><i class=\" glyphicon glyphicon-time\"></i>&nbsp;" + data.service_days_remaining + "</td><td style=\"width:30px\" nowrap=\"nowrap\"><span class=\"btn btn-default btn-xs\" onclick=\"editService('" + data.id + "')\"><i class=\"glyphicon glyphicon-pencil\"></i></span>&nbsp;<span class=\"btn btn-default btn-xs btn-danger\" onclick=\"deleteService('" + data.id + "')\"><i class=\"glyphicon glyphicon-trash\"></i></span></td></tr>";
                        if ($('#services_table tr:last').size() > 0) {
                            $('#services_table tr:last').after(ddata);
                        } else {
                            var ndata = '<br/><table class="table table-hover taracot-billing-table" id="services_table"><tbody>'+ddata+"</tbody></table>";
                            $('#data_services').html(ndata);
                        }
                    } else {
                        $("#service_row_" + data.id).html("<td><span id=\"service_name_" + data.id + "\">" + data.service_name + " <small style=\"color:#666\">(" + data.service_cost + "/" + js_lang_hac_per_month + ")</small></span></td><td width=\"100\"><i class=\" glyphicon glyphicon-time\"></i>&nbsp;" + data.service_days_remaining + "</td><td style=\"width:30px\" nowrap=\"nowrap\"><span class=\"btn btn-default btn-xs\" onclick=\"editService('" + data.id + "')\"><i class=\"glyphicon glyphicon-pencil\"></i></span>&nbsp;<span class=\"btn btn-default btn-xs btn-danger\" onclick=\"deleteService('" + data.id + "')\"><i class=\"glyphicon glyphicon-trash\"></i></span></td>");
                    }
                    $('#service_edit_dialog').modal('hide');
                }
            },
            error: function () {
                $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
                $('#service_edit_ajax').hide();
                $('#service_edit_form').show();
                $('#service_edit_buttons').show();
            }
        });
    }
});
// Add/edit profile save button click event
$('#btn_profile_dialog_save').click(function () {
    $(".prcg").each(function() {
        $(this).removeClass('has-error');
    });
    $('#profile_edit_form_error').hide();
    var errors = false;
    if ($('#n1r').val() || $('#n2r').val() || $('#n3r').val() || $('#passport').val() || $('#addr_ru').val()) {
        if (!$('#n1r').val().match(/^[А-Яа-я\-]{1,19}$/)) {
            $('#cg_n1r').addClass('has-error');
            errors = true;
        }
        if (!$('#n2r').val().match(/^[А-Яа-я\-]{1,19}$/)) {
            $('#cg_n2r').addClass('has-error');
            errors = true;
        }
        if (!$('#n3r').val().match(/^[А-Яа-я\-]{1,24}$/)) {
            $('#cg_n3r').addClass('has-error');
            errors = true;
        }
        if (!$('#passport').val().match(/^([0-9]{2})(\s)([0-9]{2})(\s)([0-9]{6})(\s)(.*)([0-9]{2})(\.)([0-9]{2})(\.)([0-9]{4})$/)) {
            $('#cg_passport').addClass('has-error');
            errors = true;
        }
        if (!$('#addr_ru').val().match(/^([0-9]{6}),(\s)(.*)$/)) {
            $('#cg_addr_ru').addClass('has-error');
            errors = true;
        }
    }
    if (!$('#n1e').val().match(/^[A-Za-z\-]{1,30}$/)) {
        $('#cg_n1e').addClass('has-error');
        errors = true;
    }
    if (!$('#n2e').val().match(/^[A-Za-z\-]{1,30}$/)) {
        $('#cg_n2e').addClass('has-error');
        errors = true;
    }
    if (!$('#n3e').val().match(/^[A-Z]{1}$/)) {
        $('#cg_n3e').addClass('has-error');
        errors = true;
    }
    if (!$('#email').val().match(/^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/)) {
        $('#cg_email').addClass('has-error');
        errors = true;
    }
    if (!$('#phone').val().match(/^(\+)([0-9]{1,5})(\s)([0-9]{1,6})(\s)([0-9]{1,10})$/)) {
        $('#cg_phone').addClass('has-error');
        errors = true;
    }
    if ($('#fax').val() && !$('#fax').val().match(/^(\+)([0-9]{1,5})(\s)([0-9]{1,6})(\s)([0-9]{1,10})$/)) {
        $('#cg_fax').addClass('has-error');
        errors = true;
    }    
    if (!$('#birth_date').val().match(/^([0-9]{2})(\.)([0-9]{2})(\.)([0-9]{4})$/)) {
        $('#cg_birth_date').addClass('has-error');
        errors = true;
    }        
    if (!$('#postcode').val().match(/^([0-9]{5,6})$/)) {
        $('#cg_postcode').addClass('has-error');
        errors = true;
    }
    if ($('#org_r').val() || $('#org').val() || $('#code').val() || $('#kpp').val()) {
        if (!$('#org_r').val().match(/^(.{1,80})$/)) {
            $('#cg_org_r').addClass('has-error');
            errors = true;
        }
        if (!$('#org').val().match(/^(.{1,80})$/)) {
            $('#cg_org').addClass('has-error');
            errors = true;
        }
        if (!$('#code').val().match(/^([0-9]{10})$/)) {
            $('#cg_code').addClass('has-error');
            errors = true;
        }
        if (!$('#kpp').val().match(/^([0-9]{9})$/)) {
            $('#cg_kpp').addClass('has-error');
            errors = true;
        }
    }   
    if (!$('#city').val().match(/^([A-Za-z\-\. ]{2,64})$/)) {
        $('#cg_city').addClass('has-error');
        errors = true;
    }
    if (!$('#state').val().match(/^([A-Za-z\-\. ]{2,40})$/)) {
        $('#cg_state').addClass('has-error');
        errors = true;
    }
    if (!$('#addr').val().match(/^(.{2,80})$/)) {
        $('#cg_addr').addClass('has-error');
        errors = true;
    }
    if (errors) {
        $('#profile_edit_form_error_text').html(js_lang_form_errors);
        $('#profile_edit_form_error').fadeIn(400);
        $('#profile_edit_form_error').alert();
        $('#profile_modal_body').scrollTop(0);
        $('#n1r').focus();
    } else {
        $('#profile_edit_ajax_msg').html(js_lang_ajax_saving);
        $('#profile_edit_ajax').show();
        $('#profile_edit_form').hide();
        $('#profile_edit_buttons').hide();
        var private_flag = 0;
        if ($('input[name=private]').is(':checked')) {
            private_flag = 1;
        }
        $.ajax({
            type: 'POST',
            url: '/admin/billing/data/profile/save',
            data: {
                id: edit_id,
                n1r: $('#n1r').val(),
                n1e: $('#n1e').val(),
                n2r: $('#n2r').val(),
                n2e: $('#n2e').val(),
                n3r: $('#n3r').val(),
                n3e: $('#n3e').val(),
                email: $('#email').val(),
                phone: $('#phone').val(),
                fax: $('#fax').val(),
                country: $('#country').val(),
                city: $('#city').val(),
                state: $('#state').val(),
                addr: $('#addr').val(),
                postcode: $('#postcode').val(),
                passport: $('#passport').val(),
                birth_date: $('#birth_date').val(),
                addr_ru: $('#addr_ru').val(),
                org: $('#org').val(),
                org_r: $('#org_r').val(),
                code: $('#code').val(),
                kpp: $('#kpp').val(),
                private: private_flag
            },
            dataType: "json",
            success: function (data) {
                if (data.result == '0') {
                    if (data.error) { // ERROR
                        $('#profile_edit_form_error_text').html(data.error);
                        $('#profile_edit_form_error').fadeIn(400);
                        $('#profile_edit_form_error').alert();
                    }
                    $('#profile_edit_ajax').hide();
                    $('#profile_edit_form').show();
                    $('#profile_edit_buttons').show();
                    $('#ajax_loading').hide();
                    if (data.field) {
                        $('#cg_' + data.field).addClass('has-error');
                        $('#' + data.field).focus();
                    }
                } else { // OK
                    $.jmessage(js_lang_success, js_lang_data_saved, 2500, 'jm_message_success');                    
                    $('#profile_edit_dialog').modal('hide');
                }
            },
            error: function () {
                $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
                $('#profile_edit_ajax').hide();
                $('#profile_edit_form').show();
                $('#profile_edit_buttons').show();
            }
        });
    }
});

function editHosting(id) {
    $('#hosting_edit_dialog_title').html(js_lang_edit_account);
    $('#cg_haccount').removeClass('has-error');
    $('#cg_hplan').removeClass('has-error');
    $('#cg_hdays').removeClass('has-error');
    $('#hosting_edit_form_error').hide();
    hosting_edit_id = id;
    $('#hosting_edit_dialog').modal({
        keyboard: true
    });
    $('#hosting_edit_ajax_msg').html(js_lang_ajax_loading);
    $('#hosting_edit_ajax').show();
    $('#hosting_edit_form').hide();
    $('#hosting_edit_buttons').hide();
    $.ajax({
        type: 'POST',
        url: '/admin/billing/data/hosting/load',
        data: {
            id: hosting_edit_id
        },
        dataType: "json",
        success: function (data) {
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
                if (data.h_queue && data.h_queue == 1) {
                    $('#h_queue').attr('checked', 'checked');
                } else {
                    $('#h_queue').removeAttr('checked');
                }
            }
        },
        error: function () {
            $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
            $('#hosting_edit_ajax').hide();
            $('#hosting_edit_form').show();
            $('#hosting_edit_buttons').show();
            $('#hosting_edit_dialog').modal('hide');
        }
    });
}

function editDomain(id) {
    $('#domain_edit_dialog_title').html(js_lang_edit_domain);
    $('#cg_domain_name').removeClass('has-error');
    $('#cg_domain_exp').removeClass('has-error');
    $('#cg_ns1').removeClass('has-error');
    $('#cg_ns2').removeClass('has-error');
    $('#cg_ns3').removeClass('has-error');
    $('#cg_ns4').removeClass('has-error');
    $('#cg_ns1_ip').removeClass('has-error');
    $('#cg_ns2_ip').removeClass('has-error');
    $('#cg_ns3_ip').removeClass('has-error');
    $('#cg_ns4_ip').removeClass('has-error');
    $('#domain_edit_form_error').hide();
    domain_edit_id = id;
    $('#domain_edit_dialog').modal({
        keyboard: true
    });
    $('#domain_edit_ajax_msg').html(js_lang_ajax_loading);
    $('#domain_edit_ajax').show();
    $('#domain_edit_form').hide();
    $('#domain_edit_buttons').hide();    
    $.ajax({
        type: 'POST',
        url: '/admin/billing/data/domain/load',
        data: {
            id: domain_edit_id
        },
        dataType: "json",
        success: function (data) {
            if (data.result == '0') {
                $('#domain_edit_dialog').modal('hide');
                $.jmessage(js_lang_error, js_lang_data_loading_error, 2500, 'jm_message_error');
            } else { // OK
                var domain_name = data.domain_name || '';
                var domain_exp = data.domain_exp || '';
                var ns1 = data.ns1 || '';
                var ns2 = data.ns2 || '';
                var ns3 = data.ns3 || '';
                var ns4 = data.ns4 || '';
                var ns1_ip = data.ns1_ip || '';
                var ns2_ip = data.ns2_ip || '';
                var ns3_ip = data.ns3_ip || '';
                var ns4_ip = data.ns4_ip || '';
                $('#domain_name').val(domain_name);                
                $('#domain_exp').val(domain_exp);
                $('#ns1').val(ns1);
                $('#ns2').val(ns2);
                $('#ns3').val(ns3);
                $('#ns4').val(ns4);
                $('#ns1_ip').val(ns1_ip);
                $('#ns2_ip').val(ns2_ip);
                $('#ns3_ip').val(ns3_ip);
                $('#ns4_ip').val(ns4_ip);
                $('#domain_edit_ajax').hide();
                $('#domain_edit_form').show();
                $('#domain_edit_buttons').show();
                if (data.d_queue && data.d_queue == 1) {
                    $('#d_queue').attr('checked', 'checked');
                } else {
                    $('#d_queue').removeAttr('checked');
                }
            }
        },
        error: function () {
            $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
            $('#domain_edit_ajax').hide();
            $('#domain_edit_form').show();
            $('#domain_edit_buttons').show();
            $('#domain_edit_dialog').modal('hide');
        }
    });
}

function editService(id) {
    $('#service_edit_dialog_title').html(js_lang_edit_service);
    $('#cg_sid').removeClass('has-error');
    $('#cg_sdays').removeClass('has-error');
    $('#service_edit_form_error').hide();
    service_edit_id = id;
    $('#service_edit_dialog').modal({
        keyboard: true
    });
    $('#service_edit_ajax_msg').html(js_lang_ajax_loading);
    $('#service_edit_ajax').show();
    $('#service_edit_form').hide();
    $('#service_edit_buttons').hide();
    $.ajax({
        type: 'POST',
        url: '/admin/billing/data/service/load',
        data: {
            id: service_edit_id
        },
        dataType: "json",
        success: function (data) {
            if (data.result == '0') {
                $('#service_edit_dialog').modal('hide');
                $.jmessage(js_lang_error, js_lang_data_loading_error, 2500, 'jm_message_error');
            } else { // OK
                var sid = data.sid || '';
                var sdays = data.sdays || '';
                $('#sid').val(sid);
                $('#sdays').val(sdays);
                $('#service_edit_ajax').hide();
                $('#service_edit_form').show();
                $('#service_edit_buttons').show();
            }
        },
        error: function () {
            $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
            $('#service_edit_ajax').hide();
            $('#service_edit_form').show();
            $('#service_edit_buttons').show();
            $('#service_edit_dialog').modal('hide');
        }
    });
}

function deleteHosting(id) {
    if (!confirm(js_lang_data_delete_confirm + ":\n\n" + $('#hosting_account_name_' + id).html())) {
        return false;
    }
    $("#hosting_row_" + id).fadeOut(400);
    $.ajax({
        type: 'POST',
        url: '/admin/billing/data/hosting/delete',
        data: {
            id: id
        },
        dataType: "json",
        success: function (data) {
            if (data.result == '0') {
                $('#hosting_edit_dialog').modal('hide');
                $.jmessage(js_lang_error, js_lang_data_delete_error, 2500, 'jm_message_error');
                $("#hosting_row_" + id).fadeIn(400);
            } else { // OK         
                $("#hosting_row_" + id).html('');
                $.jmessage(js_lang_success, js_lang_data_delete_ok, 2500, 'jm_message_success');
                hosting_count--;
                if (hosting_count == 0) {
                    $('#data_accounts').html('<br/>'+js_lang_no_hosting_accounts);
                }
            }
        },
        error: function () {
            $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
            $("#hosting_row_" + id).fadeIn(400);
        }
    });
}

function deleteDomain(id) {
    if (!confirm(js_lang_data_delete_confirm + ":\n\n" + $('#domain_name_' + id).html())) {
        return false;
    }
    $("#domain_row_" + id).fadeOut(400);
    $.ajax({
        type: 'POST',
        url: '/admin/billing/data/domain/delete',
        data: {
            id: id
        },
        dataType: "json",
        success: function (data) {
            if (data.result == '0') {
                $('#domain_edit_dialog').modal('hide');
                $.jmessage(js_lang_error, js_lang_data_delete_error, 2500, 'jm_message_error');
                $("#domain_row_" + id).fadeIn(400);
            } else { // OK         
                $("#domain_row_" + id).html('');
                $.jmessage(js_lang_success, js_lang_data_delete_ok, 2500, 'jm_message_success');
                domains_count--;
                if (domains_count == 0) {
                    $('#data_domains').html('<br/>'+js_lang_no_domains);
                }
            }
        },
        error: function () {
            $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
            $("#domain_row_" + id).fadeIn(400);
        }
    });
}

function deleteService(id) {
    if (!confirm(js_lang_data_delete_confirm + ":\n\n" + $('#service_name_' + id).text())) {
        return false;
    }
    $("#service_row_" + id).fadeOut(400);
    $.ajax({
        type: 'POST',
        url: '/admin/billing/data/service/delete',
        data: {
            id: id
        },
        dataType: "json",
        success: function (data) {
            if (data.result == '0') {
                $('#service_edit_dialog').modal('hide');
                $.jmessage(js_lang_error, js_lang_data_delete_error, 2500, 'jm_message_error');
                $("#service_row_" + id).fadeIn(400);
            } else { // OK         
                $("#service_row_" + id).html('');
                $.jmessage(js_lang_success, js_lang_data_delete_ok, 2500, 'jm_message_success');
                services_count--;
                if (services_count == 0) {
                    $('#data_services').html('<br/>'+js_lang_no_services);
                }
            }
        },
        error: function () {
            $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
            $("#service_row_" + id).fadeIn(400);
        }
    });
}

$('#btn_funds').click(function() {
    var features, w = screen.width - 100, h = screen.height - 200;
    var top = (screen.height - h) / 2 - 50,
    left = (screen.width - w) / 2;
    if (top < 0) top = 0;
    if (left < 0) left = 0;
    features = 'top=' + top + ',left=' + left;
    features += ',height=' + h + ',width=' + w + ',resizable=no';
    imgbrowser = open('/admin/billing/funds?id=' + edit_id, 'displayWindow', features);
});

$('#btn_profile').click(function() {    
    $('#private').removeAttr('checked');
    $('#profile_edit_dialog').modal({
        keyboard: true
    });  
    $(".prif").each(function() {
        $(this).val('');
    });
    $(".prcg").each(function() {
        $(this).removeClass('has-error');
    });
    $('#profile_edit_ajax_msg').html(js_lang_ajax_loading);
    $('#profile_edit_ajax').show();
    $('#profile_edit_form').hide();
    $('#profile_edit_buttons').hide();
    $.ajax({
        type: 'POST',
        url: '/admin/billing/data/profile/load',
        data: {
            id: edit_id
        },
        dataType: "json",
        success: function (data) {
            $('#profile_edit_ajax').hide();
            $('#profile_edit_form').show();
            $('#profile_edit_buttons').show();
            if (data.db) {
                if (data.db.n1r) {
                    $('#n1r').val(data.db.n1r);
                }
                if (data.db.n2r) {
                    $('#n2r').val(data.db.n2r);
                }
                if (data.db.n3r) {
                    $('#n3r').val(data.db.n3r);
                }
                if (data.db.n1e) {
                    $('#n1e').val(data.db.n1e);
                }
                if (data.db.n2e) {
                    $('#n2e').val(data.db.n2e);
                }
                if (data.db.n3e) {
                    $('#n3e').val(data.db.n3e);
                }
                if (data.db.email) {
                    $('#email').val(data.db.email);
                }
                if (data.db.phone) {
                    $('#phone').val(data.db.phone);
                }
                if (data.db.fax) {
                    $('#fax').val(data.db.fax);
                }
                if (data.db.country) {
                    $('#country').val(data.db.country);
                }
                if (data.db.city) {
                    $('#city').val(data.db.city);
                }
                if (data.db.state) {
                    $('#state').val(data.db.state);
                }
                if (data.db.addr) {
                    $('#addr').val(data.db.addr);
                }
                if (data.db.postcode) {
                    $('#postcode').val(data.db.postcode);
                }
                if (data.db.passport) {
                    $('#passport').val(data.db.passport);
                }
                if (data.db.birth_date) {
                    $('#birth_date').val(data.db.birth_date);
                }
                if (data.db.addr_ru) {
                    $('#addr_ru').val(data.db.addr_ru);
                }
                if (data.db.org) {
                    $('#org').val(data.db.org);
                }
                if (data.db.org_r) {
                    $('#org_r').val(data.db.org_r);
                }
                if (data.db.code) {
                    $('#code').val(data.db.code);
                }
                if (data.db.kpp) {
                    $('#kpp').val(data.db.kpp);
                }
                if (data.db.private && data.db.private == 1) {
                    $('#private').attr('checked', 'checked');
                } else {
                    $('#private').removeAttr('checked');
                }
            }
            $('#profile_edit_form_error').hide();            
            $('#profile_modal_body').scrollTop(0);
            $('#n1r').focus();
        },
        error: function () {
            $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
            $('#profile_edit_ajax').hide();
            $('#profile_edit_form').show();
            $('#profile_edit_buttons').show();
            $('#profile_edit_dialog').modal('hide');
        }
    });    
});

$('#btn_save_config').click(function() {    
    if ($('#btn_save_config').hasClass('disabled')) {
        return;
    }
    $('#btn_save_config').addClass('disabled');
    $.ajax({
        type: 'POST',
        url: '/admin/billing/data/config/generate',        
        dataType: "json",
        success: function (data) {
            $('#btn_save_config').removeClass('disabled');
            if (data.result && data.result == 1) { // ok
                $.jmessage(js_lang_success, js_lang_data_saved, 2500, 'jm_message_success');                
            } else { // error
                $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
            }
        },
        error: function () {
            $('#btn_save_config').removeClass('disabled');
            $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
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
    $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');   
    dtable.fnProcessingIndicator( false );
}
function submitEdit(value, settings) {
    var value_old = this.revert;
    if (value_old == value) {
        return (value);
    }
    value = value.replace(/\</g, '&lt;');
    value = value.replace(/\>/g, '&gt;');
    value = value.replace(/\"/g, '&quot;');
    $.ajax({
        type: 'POST',
        url: '/admin/billing/data/funds/save',
        data: {
            user_id: edit_id,
            amount: value
        },
        dataType: "json",
        success: function (data) {
            if (data.result != '1') {
                $('#funds').html(value_old);
            } else {
                if (data.value) {
                    $('#funds').html(value);
                }
            }
        },
        error: function () {
            $.jmessage(js_lang_error, js_lang_error_ajax, 2500, 'jm_message_error');
            $('#funds').html(value_old);
        }
    });
    return (value);
}
$('#funds').editable(submitEdit, {
    placeholder: '—',
    tooltip: ''
});
