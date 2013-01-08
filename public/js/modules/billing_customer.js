var hosting_plans_cost = {};
var hosting_plans_id = {};
var hosting_planid_cost = {};
var queue_internal=[];
var domain_update_cost = {};
var service_plans_cost = {};
var domains_zones = {};
var queue_request_active = false;
var tmp_service_id = '';
var allowModalEsc = false;
var data_nss = [];

$(document).ready(function () {
    $('#use_default_nss').change(function() {
        if ($('input[name=use_default_nss]').is(':checked')) {
            $('#nss_controls').hide();
            if (data_nss && data_nss.length > 0) {
                for (var i = 0; i < data_nss.length; i++) {
                    $('#'+data_nss[i].ns).val(data_nss[i].host);
                }
            }
        } else {
            $('#nss_controls').show();
        }
    });
    $('body').tooltip({animation:true, html: true, placement: 'right', trigger: 'hover', selector: '[rel=progress_img]', title: js_lang_progress_popup_text});
    $('#customer_tabs a').click(function (e) {
        e.preventDefault();
        $(this).tab('show');
    });
    // Populate countries list
    var cntrs = js_lang_countries.split('=');
    for (var i=0; i<cntrs.length; i++) {
        var cntr = cntrs[i].split(',');
        $('#country').append('<option value="'+cntr[0]+'">'+cntr[1]+'</option>');
    } 
    $('.nav-tabs a').on('shown', function (e) {
        var target = e.target.toString();
        if (target.search('tab_profile') != -1) {
            $('#n1e').focus();
        }
        if (target.search('tab_account') != -1) {
            $('#amnt').focus();
        }
    });
    function loadData() {
        $('#billing_customer_wrap_ajax').fadeIn(200);
        $('#billing_customer_wrap').hide();
        $.ajax({
            type: 'POST',
            url: '/customer/data/load?'+Math.random(),
            dataType: "json",
            success: function (data) {
                if (data.result == '0') {                
                    $('#billing_customer_wrap').html(js_lang_error_ajax);
                    $('#billing_customer_wrap').fadeIn(200);
                    $('#billing_customer_wrap_ajax').hide();
                } else { // OK
                    if (data.amount) {
                        $('#funds_avail').html(data.amount);
                    } else {
                        $('#funds_avail').html('0');
                    }                    
                    var queue = false;

                    // Hosting

                    if (data.nss) {
                        data_nss = data.nss;
                    }

                    if (data.hosting && data.hosting.length > 0) {                    
                        var tdata = '<table class="table table-striped table-bordered" id="hosting_table"><thead><tr><th>'+js_lang_hosting_account+'</th><th style="width:40px;text-align:center">'+js_lang_hac_days+'</th><th style="width:50px"></th></tr></thead><tbody>';
                        for (var i = 0; i < data.hosting.length; i++) {
                            hosting_plans_id[data.hosting[i].account] = data.hosting[i].plan_id;
                            hosting_plans_cost[data.hosting[i].account] = data.hosting[i].plan_cost;
                            var tr_class='';
                            if (data.hosting[i].days <= 0) {
                                tr_class=' class="error"';
                            }
                            var prp='';
                            if (data.hosting[i].in_queue && data.hosting[i].in_queue == 1) {
                                prp='<img src="/images/update.png" width="16" height="16" alt="" />';
                                queue_internal.push(data.hosting[i].account);
                                queue = true;
                            }
                            var error_msg='';
                            var error_act='';
                            if (data.hosting[i].error_msg && data.hosting[i].error_msg != '') {
                                error_act=js_lang_error+'&nbsp;<i class="icon-question-sign icon-white"></i>';
                                error_msg=data.hosting[i].error_msg;
                            }
                            var error_label='<span class="badge badge-important" style="cursor:pointer" id="error_label_'+data.hosting[i].account+'" onclick="errorMessage(\''+error_msg+'\')">'+error_act+'</span>&nbsp;';
                            tdata += "<tr"+tr_class+" id=\"hosting_row_"+data.hosting[i].account+"\"><td><span class=\"label label-inverse\">" + data.hosting[i].account + "</span>&nbsp;<span class=\"badge badge-success\" rel=\"progress_img\" id=\"progress_"+data.hosting[i].account+"\">"+prp+"</span><span id=\"qerror_"+data.hosting[i].account+"\" rel=\"qerror\" class=\"badge badge-important qerror\"></span></span>&nbsp;"+error_label+"&nbsp;" + data.hosting[i].plan_name + " <small style=\"color:#666\">(" + data.hosting[i].plan_cost + " " + js_lang_billing_currency + "/" + js_lang_hac_per_month + ")</small></td><td style=\"width:90px;text-align:center\"><i class=\" icon-time\"></i>&nbsp;<span id=\"hosting_days_"+data.hosting[i].account+"\">" + data.hosting[i].days + "</span></td><td style=\"width:40px;text-align:center\"><span class=\"btn btn-mini\" onclick=\"updateHosting('"+data.hosting[i].account+"')\"><i class=\"icon-plus-sign\"></i></span></td></tr>";
                        }
                        tdata += "</tbody></table>";                        
                        $('#data_hosting').html(tdata);                        
                    } else {
                        $('#data_hosting').html(js_lang_no_hosting_accounts+'&nbsp;'+js_lang_no_add_by_click);
                    }
                    
                    // Domains

                    if (data.domains && data.domains.length > 0) {                                                
                        var tdata = '<table class="table table-striped table-bordered" id="domains_table"><thead><tr><th>'+js_lang_domain_name+'</th><th style="width:100px;text-align:center">'+js_lang_domain_exp_short+'</th><th style="width:50px"></th></tr></thead><tbody>';                    
                        for (var i = 0; i < data.domains.length; i++) {
                            var update_icon='';
                            var update_class='';
                            if (data.domains[i].update && data.domains[i].update == 1) {
                                update_icon = '<span class="btn btn-mini"  onclick="updateDomain(\''+data.domains[i].domain_name+'\');"><i class="icon-refresh"></i></span>';
                            }
                            if (data.domains[i].expired && data.domains[i].expired == 1) {
                                update_class = ' class="error"';
                            }
                            var prp='';
                            if (data.domains[i].in_queue && data.domains[i].in_queue == 1) {
                                queue_internal.push(data.domains[i].domain_name);
                                queue = true;
                                prp='<img src="/images/update.png" width="16" height="16" alt="" />';
                            }
                            var dnid=data.domains[i].domain_name.replace(/\./g, "_");
                            var error_msg = data.domains[i].error_msg || '';
                            var error_msg='';
                            var error_act='';
                            if (data.domains[i].error_msg && data.domains[i].error_msg != '') {
                                error_act=js_lang_error+'&nbsp;<i class="icon-question-sign icon-white"></i>';
                                error_msg=data.domains[i].error_msg;
                            }
                            var error_label='<span class="badge badge-important" style="cursor:pointer" id="error_label_'+dnid+'" onclick="errorMessage(\''+error_msg+'\')">'+error_act+'</span>&nbsp;';
                            tdata += "<tr"+update_class+" id=\"domain_row_"+dnid+"\"><td><span class=\"label label-inverse\">" + data.domains[i].domain_name + "</span>&nbsp;<span class=\"badge badge-success\" id=\"progress_"+dnid+"\" rel=\"progress_img\">"+prp+"</span><span id=\"qerror_"+dnid+"\" rel=\"qerror\" class=\"badge badge-important qerror\"></span>"+error_label+"</td><td style=\"width:100px;text-align:center\"><i class=\" icon-calendar\"></i>&nbsp;<span id=\"exp_"+dnid+"\">" + data.domains[i].exp_date + "</span></td><td style=\"width:40px;text-align:center\">"+update_icon+"</td></tr>";
                            if (data.domains[i].zone) {
                                domains_zones[data.domains[i].domain_name] = data.domains[i].zone;
                            }
                        }
                        tdata += "</tbody></table>";
                        $('#data_domains').html(tdata);                    
                    } else {
                        $('#data_domains').html(js_lang_no_domains+'&nbsp;'+js_lang_no_add_by_click);
                    }           

                    // Services

                    if (data.services && data.services.length > 0) {
                        var tdata='';
                        tdata = '<table class="table table-striped table-bordered" id="services_table"><thead><tr><th>'+js_lang_service+'</th><th style="width:40px;text-align:center">'+js_lang_hac_days+'</th><th style="width:50px"></th></tr></thead><tbody>';
                        for (var i = 0; i < data.services.length; i++) {
                            var tr_class='';
                            if (data.services[i].days <= 0) {
                                tr_class=' class="error"';
                            }
                            service_plans_cost[data.services[i].service_id] = data.services[i].cost;
                            tdata += "<tr"+tr_class+"><td><span class=\"label label-inverse\"><span id=\"service_name_"+data.services[i].service_id+"\">" + data.services[i].name + "</span></span></td><td style=\"width:90px;text-align:center\"><i class=\" icon-time\"></i>&nbsp;<span id=\"service_days_"+data.services[i].service_id+"\">" + data.services[i].days + "</span></td><td style=\"width:40px;text-align:center\"><span class=\"btn btn-mini\" onclick=\"updateService('"+data.services[i].service_id+"');\"><i class=\"icon-plus-sign\"></i></span></td></tr>";
                        }
                        tdata += "</tbody></table>";
                        $('#data_services').html(tdata);                    
                    } else {
                        $('#data_services').html(js_lang_no_services);
                    }                   

                    if (queue) {
                        setTimeout(function() { loadQueue() }, 6000);
                        queue_request_active = true;
                    }

                    if (data.history && data.history.length > 0) {
                        var tdata='';
                        tdata = js_lang_history_hint+'<br/><br/><table class="table table-striped table-bordered" id="history_table"><thead><tr><th>'+js_lang_event+'</th><th style="text-align:center">'+js_lang_preview_amount+'</th><th style="text-align:center">'+js_lang_trans_date+'</th></tr></thead><tbody>';
                        for (var i = 0; i < data.history.length; i++) {
                            var tr_class='';
                            if (data.history[i].days <= 0) {
                                tr_class=' class="error"';
                            }
                            var pic = '/images/plus.png';
                            if (data.history[i].amount && data.history[i].amount < 0) {
                                pic = '/images/minus.png';
                                data.history[i].amount = data.history[i].amount * -1;
                            }                        
                            tdata += "<tr"+tr_class+"><td>" + data.history[i].event + "</td><td style=\"width:90px;text-align:center\"><img src=\""+pic+"\" width=\"16\" height=\"16\" alt=\"\" />&nbsp;" + data.history[i].amount + "</td><td style=\"width:160px;text-align:center\">"+data.history[i].date+"</td></tr>";
                        }
                        tdata += "</tbody></table>";
                        $('#data_history').html(tdata);
                    } else {
                        $('#data_history').html('<br/>'+js_lang_no_history_records);
                    }
                    if (data.profile) {
                        if (data.profile.n1r) {
                            $('#n1r').val(data.profile.n1r);
                        }
                        if (data.profile.n2r) {
                            $('#n2r').val(data.profile.n2r);
                        }
                        if (data.profile.n3r) {
                            $('#n3r').val(data.profile.n3r);
                        }
                        if (data.profile.n1e) {
                            $('#n1e').val(data.profile.n1e);
                        }
                        if (data.profile.n2e) {
                            $('#n2e').val(data.profile.n2e);
                        }
                        if (data.profile.n3e) {
                            $('#n3e').val(data.profile.n3e);
                        }
                        if (data.profile.email) {
                            $('#email').val(data.profile.email);
                        }
                        if (data.profile.phone) {
                            $('#phone').val(data.profile.phone);
                        }
                        if (data.profile.fax) {
                            $('#fax').val(data.profile.fax);
                        }
                        if (data.profile.country) {
                            $('#country').val(data.profile.country);
                        }
                        if (data.profile.city) {
                            $('#city').val(data.profile.city);
                        }
                        if (data.profile.state) {
                            $('#state').val(data.profile.state);
                        }
                        if (data.profile.addr) {
                            $('#addr').val(data.profile.addr);
                        }
                        if (data.profile.postcode) {
                            $('#postcode').val(data.profile.postcode);
                        }
                        if (data.profile.passport) {
                            $('#passport').val(data.profile.passport);
                        }
                        if (data.profile.birth_date) {
                            $('#birth_date').val(data.profile.birth_date);
                        }
                        if (data.profile.addr_ru) {
                            $('#addr_ru').val(data.profile.addr_ru);
                        }
                        if (data.profile.org) {
                            $('#org').val(data.profile.org);
                        }
                        if (data.profile.org_r) {
                            $('#org_r').val(data.profile.org_r);
                        }
                        if (data.profile.code) {
                            $('#code').val(data.profile.code);
                        }
                        if (data.profile.kpp) {
                            $('#kpp').val(data.profile.kpp);
                        }
                        if (data.profile.private) {
                            $('#private').attr('checked', 'checked');
                        } else {
                            $('#private').removeAttr('checked');
                        } 
                    }
                    if (data.payment_methods && data.payment_methods.length > 0) {
                        var pdata='<table class="table">';
                        for (var i = 0; i < data.payment_methods.length; i++) {
                            var chk='';
                            if (i == 0) {
                                chk=" checked";
                            }
                            pdata += '<tr style="cursor:pointer" onclick="$(\'#payment_method_\'+'+i+').attr(\'checked\', \'checked\');"><td style="width:20px;text-align:center;vertical-align:middle"><input type="radio" name="payment_method_id" id="payment_method_'+i+'" value="'+data.payment_methods[i].id+'"'+chk+'></td><td><h4>'+data.payment_methods[i].name+'</h4>'+data.payment_methods[i].desc+'</td></tr>';
                        }
                        pdata += '</table>';
                        $('#payment_methods').html(pdata);
                    }
                    var hplans = ''; 
                    if (data.hosting_plans) {                    
                        for (var i = 0; i < data.hosting_plans.length; i++) {
                            var name = data.hosting_plans[i].name || '';
                            var id = data.hosting_plans[i].id || '';
                            var cost = data.hosting_plans[i].cost || 0;
                            hosting_planid_cost[id]=cost;
                            hplans += "<option value=\"" + id + "\">" + name + " (" + cost+ " " + js_lang_billing_currency + "/" + js_lang_hac_per_month + ")</option>";
                        }
                    }
                    $('#hplan').html(hplans);
                    var domain_zones = ''; 
                    if (data.domain_zones) {                    
                        for (var i = 0; i < data.domain_zones.length; i++) {
                            var zone = data.domain_zones[i].zone || '';
                            var cost = data.domain_zones[i].cost || '';
                            var cost_up = data.domain_zones[i].cost_up || '';
                            domain_zones += "<option value=\"" + zone + "\">" + zone + " (" + cost+ " " + js_lang_billing_currency + "/" + js_lang_hac_per_month + ")</option>";
                            domain_update_cost[zone] = cost_up;
                        }
                    }
                    $('#domain_zone').html(domain_zones);
                    $('#billing_customer_wrap_ajax').hide();
                    $('#billing_customer_wrap').show();
                }
            },
            error: function () {
                $('#billing_customer_wrap').html(js_lang_error_ajax);
                $('#billing_customer_wrap').fadeIn(200);
                $('#billing_customer_wrap_ajax').hide();
            }
        });
    }
    $('#btn_save_funds').click(function() {
        $('#form_error_msg').hide();
        $('#form_error_msg_text').html('');        
        $('#cg_amnt').removeClass('error');
        var form_errors = false;
        if (!$('#amnt').val().match(/^[0-9]*\.?[0-9]+$/) || $('#amnt').val() <= 0) {
            $('#cg_amnt').addClass('error');
            $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_form_error_invalid_amount + "<br/>");
            form_errors = true;
        }
        if (form_errors) {
            $('#form_error_msg').fadeIn(200);
            $('#amnt').focus();
        } else {
            $('#funds_buttons').hide();
            $('#account_form_1').hide();
            $('#ajax_funds_loading').show();
            $.ajax({
                    type: 'POST',
                    url: '/customer/data/get_bill?'+Math.random(),
                    data: {
                        amount: $('#amnt').val(),
                        plugin: $('input[name=payment_method_id]:checked').val()
                    },
                    dataType: "json",
                    success: function (data) {
                        if (data.result == '0') { // error
                            $('#ajax_funds_loading').hide();
                            $('#funds_buttons').show();
                            $('#account_form_1').show();
                            $('#amnt').focus();
                            if (data.error) {
                                $('#form_error_msg_text').html(data.error);
                                $('#form_error_msg').fadeIn(400);
                                $('#form_error_msg').alert();
                            }
                            if (data.field) {
                                $('#cg_' + data.field).addClass('error');
                                $('#' + data.field).focus();
                            }  
                        } else { // ok
                            $('#account_form_2').show();                                
                            $('#funds_buttons_step2').show();
                            $('#btn_funds_submit').focus();
                            var frm='<form action="'+data.pdata.url+'" method="'+data.pdata.method+'" id="funds_submit_form">';
                            for (var i=0; i<data.pdata.fields.length; i++) {
                                frm+='<input type="hidden" name="'+data.pdata.fields[i].name+'" value="'+data.pdata.fields[i].value+'">';
                            }
                            frm+='<strong>'+js_lang_preview_amount+':</strong>&nbsp;'+data.amount+' '+js_lang_billing_currency+'<br/>';
                            frm+='<strong>'+js_lang_preview_paysys+':</strong>&nbsp;'+data.paysys+'<br/>';
                            frm+='<strong>'+js_lang_preview_billid+':</strong>&nbsp;'+data.id+'<br/>';
                            frm+='</form>';
                            $('#account_ext_form').html(frm);
                            $('#ajax_funds_loading').hide();
                        }
                    },
                    error: function () {
                        $('#ajax_funds_loading').hide();
                        $('#funds_buttons').show();
                        $('#account_form_1').show();
                        $('#form_error_msg_text').append("&nbsp;&#9632;&nbsp;&nbsp;" + js_lang_error_ajax + "<br/>");
                        $('#form_error_msg').fadeIn(200);
                        $('#amnt').focus();
                    }
                });            
        }
    });
    $('#btn_funds_back').click(function(){
        $('#funds_buttons').show();
        $('#funds_buttons_step2').hide();
        $('#account_form_1').show();
        $('#account_form_2').hide();
        $('#amnt').focus();
    });
    $('#btn_funds_submit').click(function(){
        $('#funds_submit_form').submit();
    });
    $('#btn_save_profile').click(function() {
        $(".pr_input").each(function() {
            $(this).attr('disabled', 'disabled');
        });
        $('#ajax_profile_loading').show();
        $('#profile_buttons').hide();
        $('#profile_edit_form_error').hide();
        var errors = false;
        if ($('#n1r').val() || $('#n2r').val() || $('#n3r').val() || $('#passport').val() || $('#addr_ru').val()) {
            if (!$('#n1r').val().match(/^[А-Яа-я\-]{1,19}$/)) {
                $('#cg_n1r').addClass('error');
                errors = true;
            }
            if (!$('#n2r').val().match(/^[А-Яа-я\-]{1,19}$/)) {
                $('#cg_n2r').addClass('error');
                errors = true;
            }
            if (!$('#n3r').val().match(/^[А-Яа-я\-]{1,24}$/)) {
                $('#cg_n3r').addClass('error');
                errors = true;
            }
            if (!$('#passport').val().match(/^([0-9]{2})(\s)([0-9]{2})(\s)([0-9]{6})(\s)(.*)([0-9]{2})(\.)([0-9]{2})(\.)([0-9]{4})$/)) {
                $('#cg_passport').addClass('error');
                errors = true;
            }
            if (!$('#addr_ru').val().match(/^([0-9]{6}),(\s)(.*)$/)) {
                $('#cg_addr_ru').addClass('error');
                errors = true;
            }
        }
        if (!$('#n1e').val().match(/^[A-Za-z\-]{1,30}$/)) {
            $('#cg_n1e').addClass('error');
            errors = true;
        }
        if (!$('#n2e').val().match(/^[A-Za-z\-]{1,30}$/)) {
            $('#cg_n2e').addClass('error');
            errors = true;
        }
        if (!$('#n3e').val().match(/^[A-Z]{1}$/)) {
            $('#cg_n3e').addClass('error');
            errors = true;
        }
        if (!$('#email').val().match(/^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/)) {
            $('#cg_email').addClass('error');
            errors = true;
        }
        if (!$('#phone').val().match(/^(\+)([0-9]{1,5})(\s)([0-9]{1,6})(\s)([0-9]{1,10})$/)) {
            $('#cg_phone').addClass('error');
            errors = true;
        }
        if ($('#fax').val() && !$('#fax').val().match(/^(\+)([0-9]{1,5})(\s)([0-9]{1,6})(\s)([0-9]{1,10})$/)) {
            $('#cg_fax').addClass('error');
            errors = true;
        }    
        if (!$('#birth_date').val().match(/^([0-9]{2})(\.)([0-9]{2})(\.)([0-9]{4})$/)) {
            $('#cg_birth_date').addClass('error');
            errors = true;
        }        
        if (!$('#postcode').val().match(/^([0-9]{5,6})$/)) {
            $('#cg_postcode').addClass('error');
            errors = true;
        }
        if ($('#org_r').val() || $('#org').val() || $('#code').val() || $('#kpp').val()) {
            if (!$('#org_r').val().match(/^(.{1,80})$/)) {
                $('#cg_org_r').addClass('error');
                errors = true;
            }
            if (!$('#org').val().match(/^(.{1,80})$/)) {
                $('#cg_org').addClass('error');
                errors = true;
            }
            if (!$('#code').val().match(/^([0-9]{10})$/)) {
                $('#cg_code').addClass('error');
                errors = true;
            }
            if (!$('#kpp').val().match(/^([0-9]{9})$/)) {
                $('#cg_kpp').addClass('error');
                errors = true;
            }
        }   
        if (!$('#city').val().match(/^([A-Za-z\-\. ]{2,64})$/)) {
            $('#cg_city').addClass('error');
            errors = true;
        }
        if (!$('#state').val().match(/^([A-Za-z\-\. ]{2,40})$/)) {
            $('#cg_state').addClass('error');
            errors = true;
        }
        if (!$('#addr').val().match(/^(.{2,80})$/)) {
            $('#cg_addr').addClass('error');
            errors = true;
        } 
        if (errors) {
            $('#profile_edit_form_error_text').html(js_lang_form_errors);
            $('#profile_edit_form_error').fadeIn(400);
            $('#profile_edit_form_error').alert();
            $(window).scrollTop(0);
            $(".pr_input").each(function() {
                $(this).removeAttr('disabled');
            });
            $('#n1e').focus();
            $('#ajax_profile_loading').hide();
            $('#profile_buttons').show();
        } else { 
            var private_flag = '';
            if ($('input[name=private]').is(':checked')) {
                private_flag = 1;
            }
            $.ajax({
                type: 'POST',
                url: '/customer/data/profile/save',
                data: {
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
                        $('#ajax_profile_loading').hide();
                        $('#profile_buttons').show();
                        $('#ajax_loading').hide();
                        $(window).scrollTop(0);
                        $(".pr_input").each(function() {
                            $(this).removeAttr('disabled');
                        });
                        if (data.field) {
                            $('#cg_' + data.field).addClass('error');
                            $('#' + data.field).focus();
                        }
                    } else { // OK
                        $('#ajax_profile_loading').hide();
                        $('#profile_buttons').show();
                        $('#ajax_loading').hide();
                        $(window).scrollTop(0);
                        $(".pr_input").each(function() {
                            $(this).removeAttr('disabled');
                        });
                        $('#form_profile_success_msg').fadeIn(300).delay(2000).fadeOut(300);
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
    $('#btn_hosting_cancel').click(function() {
        $('#hosting_dialog').modal('hide');
    });
    $('#btn_domain_cancel').click(function() {
        $('#domain_dialog').modal('hide');
    });
    $('#btn_hosting_update_cancel').click(function() {
        $('#hosting_update_dialog').modal('hide');
    });
    $('#btn_domain_update_cancel').click(function() {
        $('#domain_update_dialog').modal('hide');
    });
    $('#btn_service_update_cancel').click(function() {
        $('#service_update_dialog').modal('hide');
    });
    $('#btn_error_msg_dialog_close').click(function() {
        $('#error_msg_dialog').modal('hide'); 
    });
    $('#btn_add_hosting').click(function() {
        allowModalEsc = true;
        $('#hosting_dialog_head').html(js_lang_add_hosting);
        $('#cg_haccount').removeClass('error');
        $('#cg_hpwd').removeClass('error');
        $('#cg_hplan').removeClass('error');
        $('#cg_hdays').removeClass('error');
        $('#hosting_edit_form_error').hide();
        $('#haccount').val('');
        $('#hpwd').val('');
        $('#hpwd_repeat').val('');
        $('#hosting_dialog').modal({
            keyboard: false,
            backdrop: 'static'
        });
        $('#hosting_edit_ajax').hide();
        $('#hosting_edit_form').show();
        $('#hosting_edit_buttons').show();
        $('#haccount').focus();
        $('select option:first-child').attr("selected", "selected");        
        var haddcost = hosting_planid_cost[$('#hplan').val()] * $('#hdays').val();
        $('#haddcost').html(haddcost);
    });
    $('#btn_add_domain').click(function() {
        allowModalEsc = true;
        $(".inpt-domain").each(function() {
            $(this).val('');
        });
        $('select option:first-child').attr("selected", "selected");
        $(".ctrl-grp-domain").each(function() {
            $(this).removeClass('error');
        });
        $('#domain_dialog').modal({
            keyboard: false,
            backdrop: 'static'
        });
        $('#domain_edit_form_error').hide();
        $('#domain_edit_ajax').hide();
        $('#domain_edit_form').show();
        $('#domain_edit_buttons').show();
        $('#domain_name').focus();     
        if (data_nss && data_nss.length > 0) {
            for (var i = 0; i < data_nss.length; i++) {
                $('#'+data_nss[i].ns).val(data_nss[i].host);
            }
        }
        $('input[name=use_default_nss]').attr('checked', true);
        $('#nss_controls').hide();
        updateDomainPreview();
    });
    $('#btn_hosting_save').click(function() {        
        allowModalEsc = true;
        $('#cg_haccount').removeClass('error');
        $('#cg_hplan').removeClass('error');
        $('#cg_hpwd').removeClass('error');
        $('#cg_hdays').removeClass('error');
        $('#hosting_edit_form_error').hide();
        var errors = false;
        if (!$('#haccount').val().match(/^[A-Za-z0-9]{4,8}$/)) {
            $('#cg_haccount').addClass('error');
            errors = true;
        }
        if ($('#hosting_row_' + $('#haccount').val()) && $('#hosting_row_' + $('#haccount').val()).length > 0) {
            $('#cg_haccount').addClass('error');
            errors = true;
        }
        if (!$('#hpwd').val().match(/^[A-Za-z0-9_\-\$\!\@\#\%\^\&\[\]\{\}\*\+\=\.\,\'\"\|\<\>\?]{8,100}$/) || $('#hpwd').val() != $('#hpwd_repeat').val()) {
            $('#cg_hpwd').addClass('error');
            errors = true;
        }
        if (errors) {
            $('#hosting_edit_form_error_text').html(js_lang_form_errors);
            $('#hosting_edit_form_error').fadeIn(400);
            $('#hosting_edit_form_error').alert();
            $('#haccount').focus();
        } else {
            allowModalEsc = false;
            if (!confirm(js_lang_pay_action_confirm+' '+$('#haddcost').html()+' '+js_lang_billing_currency)) {
                allowModalEsc = true;
                return;
            }                      
            $('#hosting_edit_ajax_msg').html(js_lang_ajax_saving);
            $('#hosting_edit_ajax').show();
            $('#hosting_edit_form').hide();
            $('#hosting_edit_buttons').hide();
            $.ajax({
                type: 'POST',
                url: '/customer/data/hosting/save',
                data: {
                    haccount: $('#haccount').val(),
                    hpwd: $('#hpwd').val(),
                    hplan: $('#hplan').val(),
                    hdays: $('#hdays').val()
                },
                dataType: "json",
                success: function (data) {
                    if (data.result == '0') {
                        allowModalEsc = true;
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
                            $('#cg_' + data.field).addClass('error');
                            $('#' + data.field).focus();
                        }                        
                    } else { // OK
                        hosting_plans_cost[data.haccount] = data.hplan_cost;
                        var prp='<img src="/images/update.png" width="16" height="16" alt="" />';
                        var error_label='<span class="badge badge-important" id="error_label_'+data.haccount+'"></span>&nbsp;';
                        var tdata = "<tr id=\"hosting_row_"+data.haccount+"\"><td><span class=\"label label-inverse\">" + data.haccount + "</span>&nbsp;<span class=\"badge badge-success\" id=\"progress_"+data.haccount+"\" rel=\"progress_img\">"+prp+"</span><span id=\"qerror_"+data.haccount+"\" rel=\"qerror\" class=\"badge badge-important qerror\"></span></span>&nbsp;"+error_label+"&nbsp;" + data.hplan_name + " <small style=\"color:#666\">(" + data.hplan_cost + " " + js_lang_billing_currency + "/" + js_lang_hac_per_month + ")</small></td><td style=\"width:90px;text-align:center\"><i class=\" icon-time\"></i>&nbsp;<span id=\"hosting_days_"+data.haccount+"\">" + data.hdays + "</span></td><td style=\"width:40px;text-align:center\"><span class=\"btn btn-mini\" onclick=\"updateHosting('"+data.haccount+"')\"><i class=\"icon-plus-sign\"></i></span></td></tr>";
                        if ($('#hosting_table tr:last').size() > 0) {
                            $('#hosting_table tr:last').after(tdata);
                        } else {
                            var ndata = '<table class="table table-striped table-bordered" id="hosting_table"><thead><tr><th>'+js_lang_hosting_account+'</th><th style="width:40px;text-align:center">'+js_lang_hac_days+'</th><th style="width:50px"></th></tr></thead><tbody>'+tdata+"</tbody></table>";
                            $('#data_hosting').html(ndata);
                        }
                        $('#hosting_dialog').modal('hide');
                        $('#funds_avail').html(data.funds_remain);                        
                        $('#queue_success_msg').fadeIn(400).delay(3000).fadeOut(400);
                        reloadHistory();
                        queue_internal.push(data.haccount);
                        if (!queue_request_active) {
                            setTimeout(function() { loadQueue() }, 6000);
                            queue_request_active = true;
                        }                        
                    }
                },
                error: function () {
                    allowModalEsc = true;
                    $('#hosting_edit_form_error_text').html(js_lang_error_ajax);
                    $('#hosting_edit_form_error').fadeIn(400);
                    $('#hosting_edit_form_error').alert();
                    $('#hosting_edit_ajax').hide();
                    $('#hosting_edit_form').show();
                    $('#hosting_edit_buttons').show();
                }
            });
        }
    }); 
    $('#btn_domain_save').click(function() {
        allowModalEsc = true;
        $(".ctrl-grp-domain").each(function() {
            $(this).removeClass('error');
        });
        $('#domain_edit_form_error').hide();
        var errors = false;
        if (!$('#domain_name').val().match(/^[A-Za-z0-9\-]{2,100}$/)) {
            $('#cg_domain_name').addClass('error');
            errors = true;
        }
        if (!$('#ns1').val().match(/^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$/)) {
            $('#cg_ns1').addClass('error');
            errors = true;
        }
        if (!$('#ns2').val().match(/^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$/)) {
            $('#cg_ns2').addClass('error');
            errors = true;
        }
        if ($('#ns3').val() && !$('#ns3').val().match(/^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$/)) {
            $('#cg_ns3').addClass('error');
            errors = true;
        }
        if ($('#ns4').val() && !$('#ns4').val().match(/^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$/)) {
            $('#cg_ns4').addClass('error');
            errors = true;
        }
        if ($('#ns1_ip').val() && !$('#ns1_ip').val().match(/^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/)) {
            $('#cg_ns1_ip').addClass('error');
            errors = true;
        }
        if ($('#ns2_ip').val() && !$('#ns2_ip').val().match(/^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/)) {
            $('#cg_ns2_ip').addClass('error');
            errors = true;
        }
        if ($('#ns3_ip').val() && !$('#ns3_ip').val().match(/^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/)) {
            $('#cg_ns3_ip').addClass('error');
            errors = true;
        }
        if ($('#ns4_ip').val() && !$('#ns4_ip').val().match(/^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/)) {
            $('#cg_ns4_ip').addClass('error');
            errors = true;
        }
        if (errors) {
            $('#domain_edit_form_error_text').html(js_lang_form_errors);
            $('#domain_edit_form_error').fadeIn(400);
            $('#domain_edit_form_error').alert();
            $('#haccount').focus();
        } else {
            allowModalEsc = false;
            if (!confirm(js_lang_pay_domain_confirm+': '+ $('#domain_name').val() + '.' + $('#domain_zone option:selected').text())) {
                allowModalEsc = true;
                return;
            }
            $('#domain_edit_ajax_msg').html(js_lang_ajax_saving);
            $('#domain_edit_ajax').show();
            $('#domain_edit_form').hide();
            $('#domain_edit_buttons').hide();
            $.ajax({
                type: 'POST',
                url: '/customer/data/domain/save',
                data: {
                    domain_name: $('#domain_name').val(),
                    domain_zone: $('#domain_zone').val(),
                    ns1: $('#ns1').val(),
                    ns2: $('#ns2').val(),
                    ns3: $('#ns3').val(),
                    ns4: $('#ns4').val(),
                    ns1_ip: $('#ns1_ip').val(),
                    ns2_ip: $('#ns2_ip').val(),
                    ns3_ip: $('#ns3_ip').val(),
                    ns4_ip: $('#ns4_ip').val()
                },
                dataType: "json",
                success: function (data) {
                    if (data.result == '0') {
                        allowModalEsc = true;
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
                            $('#cg_' + data.field).addClass('error');
                            $('#' + data.field).focus();
                        }
                    } else { // OK
                        var update_icon='';
                        if (data.zone != "ru" && data.zone != "su") {
                            update_icon = '<span class="btn btn-mini"><i class="icon-refresh" onclick="updateDomain(\''+data.domain_name+'\');"></i></span>';
                        }
                        var dnid=data.domain_name.replace(/\./g, "_");
                        var error_label='<span class="badge badge-important" id="error_label_'+dnid+'"></span>&nbsp;';
                        var prp='<img src="/images/update.png" width="16" height="16" alt="" />';
                        var tdata = "<tr id=\"domain_row_"+dnid+"\"><td><span class=\"label label-inverse\">" + data.domain_name + "</span>&nbsp;<span class=\"badge badge-success\" id=\"progress_"+dnid+"\" rel=\"progress_img\">"+prp+"</span><span id=\"qerror_"+dnid+"\" rel=\"qerror\" class=\"badge badge-important qerror\"></span>"+error_label+"</td><td style=\"width:100px;text-align:center\"><i class=\" icon-calendar\"></i>&nbsp;<span id=\"exp_"+dnid+"\">" + data.exp_date + "</span></td><td style=\"width:40px;text-align:center\">"+update_icon+"</td></tr>";
                        if ($('#domains_table tr:last').size() > 0) {
                            $('#domains_table tr:last').after(tdata);
                        } else {
                            var ndata = '<table class="table table-striped table-bordered" id="domains_table"><thead><tr><th>'+js_lang_domain_name+'</th><th style="width:100px;text-align:center">'+js_lang_domain_exp_short+'</th><th style="width:50px"></th></tr></thead><tbody>'+tdata+"</tbody></table>";
                            $('#data_domains').html(ndata);
                        }                        
                        $('#domain_dialog').modal('hide');
                        $('#funds_avail').html(data.funds_remain);                        
                        $('#queue_success_msg').fadeIn(400).delay(3000).fadeOut(400);
                        reloadHistory();
                        queue_internal.push(data.domain_name);
                        if (!queue_request_active) {
                            setTimeout(function() { loadQueue() }, 6000);
                            queue_request_active = true;
                        }
                        domains_zones[data.domain_name] = data.zone;
                    }
                },
                error: function () {
                    allowModalEsc = true;
                    $('#domain_edit_form_error_text').html(js_lang_error_ajax);
                    $('#domain_edit_form_error').fadeIn(400);
                    $('#domain_edit_form_error').alert();
                    $('#domain_edit_ajax').hide();
                    $('#domain_edit_form').show();
                    $('#domain_edit_buttons').show();
                }
            });
        }
    }); 
    $('#btn_hosting_update_save').click(function() {
        allowModalEsc = false;
        if (!confirm(js_lang_pay_action_confirm+' '+$('#hupcost').html()+' '+js_lang_billing_currency)) {
            allowModalEsc = true;
            return;
        }
        $('#cg_hdays').removeClass('error');
        $('#hosting_update_edit_form_error').hide();
        $('#hosting_update_edit_ajax_msg').html(js_lang_ajax_saving);
        $('#hosting_update_edit_ajax').show();
        $('#hosting_update_edit_form').hide();
        $('#hosting_update_edit_buttons').hide();
        $.ajax({
            type: 'POST',
            url: '/customer/data/hosting/update/save',
            data: {
                haccount: $('#hacnt').val(),
                hdays: $('#hdaysup').val()
            },
            dataType: "json",
            success: function (data) {                
                if (data.result == '0') {
                    allowModalEsc = true;
                    if (data.error) { // ERROR
                        $('#hosting_update_edit_form_error_text').html(data.error);
                        $('#hosting_update_edit_form_error').fadeIn(400);
                        $('#hosting_update_edit_form_error').alert();
                    }
                    $('#hosting_update_edit_ajax').hide();
                    $('#hosting_update_edit_form').show();
                    $('#hosting_update_edit_buttons').show();
                    $('#ajax_loading').hide();
                    if (data.field) {
                        $('#cg_' + data.field).addClass('error');
                        $('#' + data.field).focus();
                    }
                } else { // OK
                    $('#error_label_'+data.haccount).html('');
                    $('#progress_'+data.haccount).html('<img src="/images/update.png" width="16" height="16" alt="" />');
                    $('#hosting_days_'+data.haccount).html(data.hdays);
                    $('#hosting_update_dialog').modal('hide');
                    $('#funds_avail').html(data.funds_remain);
                    $('#queue_success_msg').fadeIn(400).delay(3000).fadeOut(400);
                    reloadHistory();
                    queue_internal.push(data.haccount);
                    if (!queue_request_active) {
                        setTimeout(function() { loadQueue() }, 6000);
                        queue_request_active = true;
                    }
                }
            },
            error: function () {
                allowModalEsc = true;
                $('#hosting_update_edit_form_error_text').html(js_lang_error_ajax);
                $('#hosting_update_edit_form_error').fadeIn(400);
                $('#hosting_update_edit_form_error').alert();
                $('#hosting_update_edit_ajax').hide();
                $('#hosting_update_edit_form').show();
                $('#hosting_update_edit_buttons').show();
            }
        });
    });
    $('#btn_service_update_save').click(function() {
        allowModalEsc = false;
        if (!confirm(js_lang_pay_action_confirm+' '+$('#supcost').html()+' '+js_lang_billing_currency)) {
            allowModalEsc = true;
            return;
        }
        $('#cg_sdays').removeClass('error');
        $('#service_update_edit_form_error').hide();
        $('#service_update_edit_ajax_msg').html(js_lang_ajax_saving);
        $('#service_update_edit_ajax').show();
        $('#service_update_edit_form').hide();
        $('#service_update_edit_buttons').hide();
        $.ajax({
            type: 'POST',
            url: '/customer/data/service/update/save',
            data: {
                sid: tmp_service_id,
                sdays: $('#sdaysup').val()
            },
            dataType: "json",
            success: function (data) {
                if (data.result == '0') {
                    allowModalEsc = true;
                    if (data.error) { // ERROR
                        $('#service_update_edit_form_error_text').html(data.error);
                        $('#service_update_edit_form_error').fadeIn(400);
                        $('#service_update_edit_form_error').alert();
                    }
                    $('#service_update_edit_ajax').hide();
                    $('#service_update_edit_form').show();
                    $('#service_update_edit_buttons').show();
                    $('#ajax_loading').hide();
                    if (data.field) {
                        $('#cg_' + data.field).addClass('error');
                        $('#' + data.field).focus();
                    }
                } else { // OK
                    $('#service_days_'+data.sid).html(data.sdays);
                    $('#service_update_dialog').modal('hide');
                    $('#funds_avail').html(data.funds_remain);
                    $('#service_success_msg').fadeIn(400).delay(3000).fadeOut(400);
                    reloadHistory();
                }
            },
            error: function () {
                allowModalEsc = true;
                $('#service_update_edit_form_error_text').html(js_lang_error_ajax);
                $('#service_update_edit_form_error').fadeIn(400);
                $('#service_update_edit_form_error').alert();
                $('#service_update_edit_ajax').hide();
                $('#service_update_edit_form').show();
                $('#service_update_edit_buttons').show();
            }
        });
    });
    $('#btn_domain_update_save').click(function() {
        allowModalEsc = false;
        if (!confirm(js_lang_pay_action_confirm+' '+$('#dupcost').html()+' '+js_lang_billing_currency)) {
            allowModalEsc = true;
            return;
        }
        $('#domain_update_edit_form_error').hide();
        $('#domain_update_edit_ajax_msg').html(js_lang_ajax_saving);
        $('#domain_update_edit_ajax').show();
        $('#domain_update_edit_form').hide();
        $('#domain_update_edit_buttons').hide();
        $.ajax({
            type: 'POST',
            url: '/customer/data/domain/update/save',
            data: {
                domain_name: $('#up_domain_name').html()
            },
            dataType: "json",
            success: function (data) {
                if (data.result == '0') {
                    allowModalEsc = true;
                    if (data.error) { // ERROR
                        $('#domain_update_edit_form_error_text').html(data.error);
                        $('#domain_update_edit_form_error').fadeIn(400);
                        $('#domain_update_edit_form_error').alert();
                    }
                    $('#domain_update_edit_ajax').hide();
                    $('#domain_update_edit_form').show();
                    $('#domain_update_edit_buttons').show();
                    $('#ajax_loading').hide();
                    if (data.field) {
                        $('#cg_' + data.field).addClass('error');
                        $('#' + data.field).focus();
                    }
                } else { // OK
                    var dnid=data.domain_name.replace(/\./g, "_");
                    $('#error_label_'+dnid).html('');
                    $('#progress_'+dnid).html('<img src="/images/update.png" width="16" height="16" alt="" />');
                    $('#exp_'+dnid).html(data.exp_date);
                    $('#domain_update_dialog').modal('hide');
                    $('#funds_avail').html(data.funds_remain);
                    $('#queue_success_msg').fadeIn(400).delay(3000).fadeOut(400);
                    reloadHistory();
                    queue_internal.push(data.haccount);
                    if (!queue_request_active) {
                        setTimeout(function() { loadQueue() }, 6000);
                        queue_request_active = true;
                    }
                }
            },
            error: function () {
                allowModalEsc = true;
                $('#domain_update_edit_form_error_text').html(js_lang_error_ajax);
                $('#domain_update_edit_form_error').fadeIn(400);
                $('#domain_update_edit_form_error').alert();
                $('#domain_update_edit_ajax').hide();
                $('#domain_update_edit_form').show();
                $('#domain_update_edit_buttons').show();
            }
        });
    });
    function reloadHistory() {
        $('#data_history').html('<img src="/images/white_loading.gif" width="16" height="16" alt="" />&nbsp;&nbsp;'+js_lang_ajax_loading);
        $.ajax({
            type: 'POST',
            url: '/customer/data/load/history?'+Math.random(),
            dataType: "json",
            success: function (data) {
                if (data.result == '0') {                
                } else { // OK
                    if (data.history && data.history.length > 0) {
                        var tdata='';
                        tdata = js_lang_history_hint+'<br/><br/><table class="table table-striped table-bordered" id="history_table"><thead><tr><th>'+js_lang_event+'</th><th style="text-align:center">'+js_lang_preview_amount+'</th><th style="text-align:center">'+js_lang_trans_date+'</th></tr></thead><tbody>';
                        for (var i = 0; i < data.history.length; i++) {
                            var tr_class='';
                            if (data.history[i].days <= 0) {
                                tr_class=' class="error"';
                            }
                            var pic = '/images/plus.png';
                            if (data.history[i].amount && data.history[i].amount < 0) {
                                pic = '/images/minus.png';
                                data.history[i].amount = data.history[i].amount * -1;
                            }
                            tdata += "<tr"+tr_class+"><td>" + data.history[i].event + "</td><td style=\"width:90px;text-align:center\"><img src=\""+pic+"\" width=\"16\" height=\"16\" alt=\"\" />&nbsp;" + data.history[i].amount + "</td><td style=\"width:160px;text-align:center\">"+data.history[i].date+"</td></tr>";
                        }
                        tdata += "</tbody></table>";
                        $('#data_history').html(tdata);
                    } else {
                        $('#data_history').html('<br/>'+js_lang_no_history_records);
                    }                
                }
            },
            error: function () {
                
            }
        });
    }
    function loadQueue() {        
        $.ajax({
            type: 'POST',
            url: '/customer/data/queue?'+Math.random(),
            dataType: "json",
            success: function (data) {      
                var hrel = false;                                      
                if (data.funds) {
                    $('#funds_avail').html(data.funds);
                }
                if (data.queue && data.queue.length > 0) {
                    for (var i=0; i<queue_internal.length; i++) {
                        var found = false;
                        for (var s=0; s< data.queue.length; s++) {                            
                            if (data.queue[s].object == queue_internal[i]) {
                                found = true;
                            }
                        }
                        if (!found) {
                            if (queue_internal[i]) {
                                var dnid = queue_internal[i].replace(/\./g, "_");
                                $('#progress_'+dnid).html('');
                            }
                            hrel=true;                            
                        }                        
                    }
                    queue_internal = [];
                    for (var i=0; i<data.queue.length; i++) {
                        queue_internal.push(data.queue[i].object);
                    }                                                            
                    if (queue_internal.length > 0) {
                        setTimeout(function() { loadQueue() }, 6000);
                    } else {
                        queue_request_active = false;
                    }
                } else {
                    for (var i=0; i<queue_internal.length; i++) {
                        var dnid = queue_internal[i].replace(/\./g, "_");
                        $('#progress_'+dnid).html('');
                    }
                    queue_internal = [];
                    queue_request_active = false;
                    hrel=true;
                }
                // show warnings for hosting accounts and
                $("[rel=qerror]").each(function() {
                    $(this).html('<img src="/images/error.png" width="16" height="16" alt="" />');
                });
                for (var s=0; s< data.hosting.length; s++) {
                    if (data.hosting[s].error_msg && data.hosting[s].error_msg != '') {
                        var emsg = data.hosting[s].error_msg;
                        $("#error_label_"+data.hosting[s].host_acc).html(js_lang_error+'&nbsp;<i class="icon-question-sign icon-white"></i>');
                        $("#error_label_"+data.hosting[s].host_acc).bind('click', {msg: emsg}, function(event) { errorMessage(event.data.msg) });
                    } else {
                        $("#error_label_"+data.hosting[s].host_acc).html('');
                    }
                    $('#qerror_'+data.hosting[s].host_acc).html('');
                    $('#hosting_days_'+data.hosting[s].host_acc).html(data.hosting[s].host_days_remain);
                    if (data.hosting[s].host_days_remain > 0) {
                        $('#hosting_row_'+data.hosting[s].host_acc).removeClass('error');
                    } else {
                        $('#hosting_row_'+data.hosting[s].host_acc).addClass('error');
                    }
                }
                for (var s=0; s< data.domains.length; s++) {
                    var dnid=data.domains[s].domain_name.replace(/\./g, "_");
                    $('#qerror_'+dnid).html('');
                    $('#exp_'+dnid).html(data.domains[s].exp_date);
                    if (data.domains[s].error_msg && data.domains[s].error_msg != '') {
                        var emsg = data.domains[s].error_msg;
                        $("#error_label_"+dnid).html(js_lang_error+'&nbsp;<i class="icon-question-sign icon-white"></i>');
                        $("#error_label_"+dnid).bind('click', {msg: emsg}, function(event) { errorMessage(event.data.msg) });
                    } else {
                        $("#error_label_"+dnid).html('');
                    }                    
                    if (data.domains[s].expired == 1) {
                        $('#domain_row_'+dnid).addClass('error');
                    } else {
                        $('#domain_row_'+dnid).removeClass('error');
                    }
                }
                $(".qerror").each(function() {
                    if ($(this).is(":visible")) {
                        hrel=true;
                        $(this).tooltip('destroy');
                        $(this).tooltip({animation:true, html: false, placement: 'right', trigger: 'hover', title: js_lang_error_popup_text});
                    }
                });
                if (hrel) {
                    reloadHistory();
                }
            },
            error: function () {
                setTimeout(function() { loadQueue() }, 6000);
            }
        });
    }
    // Now load data and start the game
    loadData();
    function updateDomainPreview() {
        $('#domain_preview').html('.'+$('#domain_zone').val());
    }
    $('#domain_name').keyup(function(){
        updateDomainPreview();
    });
    $('#domain_name').change(function(){
        updateDomainPreview();
    });
    $('#domain_zone').change(function(){
        updateDomainPreview();
    });    
    function submitOnEnter(e) {
        var keycode;
        if (window.event) keycode = window.event.keyCode;
        else if (e) keycode = (e.keyCode ? e.keyCode : e.which);
        else return false;
        if (keycode == 13) {
            if (window.previousKeyCode) {
                // down=40,up=38,pgdn=34,pgup=33
                if (window.previousKeyCode == 33 || window.previousKeyCode == 34 ||
                    window.previousKeyCode == 39 || window.previousKeyCode == 40) {
                        window.previousKeyCode = keycode;
                        return false;
                }
            }
            return true;
        } else {
            window.previousKeyCode = keycode;
            return false;
        }
    }
    // bind enter keys to form fields
    $('.btn').bind('keypress', function (e) {
       if (e.keyCode == 27 && allowModalEsc) {
            $('.modal').modal('hide');
       }
    });
    $('#haccount,#hpwd,#hpwd_repeat,#hplan').bind('keypress', function (e) {
       if (submitOnEnter(e)) {
            $('#btn_hosting_save').click();
       }
       if (e.keyCode == 27) {
            if (allowModalEsc) {
                $('.modal').modal('hide');
            }
       }
    });
    $('#hdaysup').bind('keypress', function (e) {
       if (submitOnEnter(e)) {
            $('#btn_hosting_update_save').click();
       }
       if (e.keyCode == 27) {
            if (allowModalEsc) {
                $('.modal').modal('hide');
            }
       }
    });
    $('#sdaysup').bind('keypress', function (e) {       
       if (submitOnEnter(e)) {
        $('#btn_service_update_save').click();
       }
       if (e.keyCode == 27) {
            if (allowModalEsc) {
                $('.modal').modal('hide');
            }
       }
    });
    $('.pr_input').bind('keypress', function (e) {       
       if (submitOnEnter(e)) {
        $('#btn_save_profile').click();
       }
    });
    $('#amnt').bind('keypress', function (e) {       
       if (submitOnEnter(e)) {        
        e.preventDefault();
        $('#btn_save_funds').click();
       }
    });
    $('#domain_name,#domain_zone,#ns1,#ns2,#ns3,#ns4,#ns1_ip,#ns2_ip,#ns3_ip,#ns4_ip').bind('keypress', function (e) {
       if (submitOnEnter(e)) {
        $('#btn_domain_save').click();
       }
       if (e.keyCode == 27) {
            if (allowModalEsc) {
                $('.modal').modal('hide');
            }
       }
    });
}); // document.ready
function updateHosting(acnt) {
    allowModalEsc = true;
    $('#hosting_update_edit_form_error').hide();
    $('#hosting_update_dialog').modal({
        keyboard: false,
        backdrop: 'static'
    });
    $('#hacnt').val(acnt);
    $('#hosting_update_edit_ajax').hide();
    $('#hosting_update_edit_form').show();
    $('#hosting_update_edit_buttons').show();
    $('#hdaysup').focus();
    $('select option:first-child').attr("selected", "selected"); 
    var hupcost = hosting_plans_cost[acnt] * $('#hdaysup').val();
    $('#hupcost').html(hupcost);
}
function updateDomain(acnt) {
    allowModalEsc = true;
    $('#domain_update_edit_form_error').hide();
    $('#domain_update_dialog').modal({
        keyboard: false,
        backdrop: 'static'
    });    
    $('#domain_update_edit_ajax').hide();
    $('#domain_update_edit_form').show();
    $('#domain_update_edit_buttons').show();
    var dupcost = domain_update_cost[domains_zones[acnt]];
    $('#up_domain_name').html(acnt);
    $('#dupcost').html(dupcost);
    $('#btn_domain_update_save').focus();
}
function updateService(acnt) {
    allowModalEsc = true;
    tmp_service_id = acnt;
    $('#service_update_edit_form_error').hide();
    $('#service_update_dialog').modal({
        keyboard: false,
        backdrop: 'static'
    });
    $('#sn').val($('#service_name_'+acnt).html());
    $('#service_update_edit_ajax').hide();
    $('#service_update_edit_form').show();
    $('#service_update_edit_buttons').show();
    $('#sdaysup').focus();
    $('select option:first-child').attr("selected", "selected"); 
    var supcost = service_plans_cost[acnt] * $('#sdaysup').val();
    $('#supcost').html(supcost);
}
function errorMessage(emsg) {
    $('#error_msg_text').html(emsg);
    $('#error_msg_dialog').modal({
        keyboard: true
    });
    $('#btn_error_msg_dialog_close').focus();
}
$('#hdaysup').change(function(){
    var hupcost = hosting_plans_cost[$('#hacnt').val()] * $('#hdaysup').val();
    $('#hupcost').html(hupcost);
});
$('#sdaysup').change(function(){
    var supcost = service_plans_cost[tmp_service_id] * $('#sdaysup').val();
    $('#supcost').html(supcost);
});
$('#hdays').change(function(){
    var haddcost = hosting_planid_cost[$('#hplan').val()] * $('#hdays').val();
    $('#haddcost').html(haddcost);
});
$('#hplan').change(function(){
    var haddcost = hosting_planid_cost[$('#hplan').val()] * $('#hdays').val();
    $('#haddcost').html(haddcost);
});