var hosting_plans_cost = {};
var hosting_plans_id = {};
var hosting_planid_cost = {};
var queue_internal=[];
var queue_request_active = true;

$(document).ready(function () {
    $('#customer_tabs a').click(function (e) {
        e.preventDefault();
        $(this).tab('show');
        $('#main_head').focus();
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

                    if (data.hosting && data.hosting.length > 0) {                    
                        var tdata = '<table class="table table-striped table-bordered" id="hosting_table"><tbody>';                        
                        for (var i = 0; i < data.hosting.length; i++) {
                            hosting_plans_id[data.hosting[i].account] = data.hosting[i].plan_id;
                            hosting_plans_cost[data.hosting[i].account] = data.hosting[i].plan_cost;
                            var tr_class='';
                            if (data.hosting[i].days <= 0) {
                                tr_class=' class="error"';
                            }
                            var hidepr='hide';
                            if (data.hosting[i].in_queue && data.hosting[i].in_queue == 1) {
                                hidepr='';
                                queue_internal.push(data.hosting[i].account);
                                queue = true;
                            }
                            tdata += "<tr"+tr_class+" id=\"hosting_row_"+data.hosting[i].account+"\"><td style=\"width:100px\"><strong>" + data.hosting[i].account + "</strong>&nbsp;<img rel=\"progress_img\" src=\"/images/update.png\" width=\"16\" height=\"16\" alt=\"\" id=\"progress_"+data.hosting[i].account+"\" class=\""+hidepr+"\" /><img rel=\"error_img\" src=\"/images/error.png\" width=\"16\" height=\"16\" alt=\"\" id=\"qerror_"+data.hosting[i].account+"\" class=\"qerror hide\" /></span></td><td style=\"text-align:right\">" + data.hosting[i].plan_name + " <small style=\"color:#666\">(" + data.hosting[i].plan_cost + " " + js_lang_billing_currency + "/" + js_lang_hac_per_month + ")</small></td><td style=\"width:90px;text-align:center\"><i class=\" icon-time\"></i>&nbsp;<span id=\"hosting_days_"+data.hosting[i].account+"\">" + data.hosting[i].days + "</span></td><td style=\"width:40px;text-align:center\"><span class=\"btn btn-mini\" onclick=\"updateHosting('"+data.hosting[i].account+"')\"><i class=\"icon-plus-sign\"></i></span></td></tr>";                            
                        }
                        tdata += "</tbody></table>";                        
                        $('#data_hosting').html(tdata);                        
                    } else {
                        $('#data_hosting').html('<br/>'+js_lang_no_hosting_accounts+'&nbsp;'+js_lang_no_add_by_click);
                    }

                    // Domains

                    if (data.domains && data.domains.length > 0) {                                                
                        var tdata = '<table class="table table-striped table-bordered" id="domains_table"><tbody>';                    
                        for (var i = 0; i < data.domains.length; i++) {
                            var update_icon='';
                            var update_class='';
                            if (data.domains[i].update && data.domains[i].update == 1) {
                                update_icon = '<span class="btn btn-mini"><i class="icon-refresh"></i></span>';
                                if (data.domains[i].zone == "ru" || data.domains[i].zone == "su") {
                                    update_class = ' class="warning"';
                                }
                            }
                            if (data.domains[i].expired && data.domains[i].expired == 1) {
                                update_class = ' class="error"';
                            }
                            var hidepr='hide';
                            if (data.domains[i].in_queue && data.domains[i].in_queue == 1) {
                                queue_internal.push(data.domains[i].domain_name);
                                queue = true;
                                hidepr='';
                            }
                            var dnid=data.domains[i].domain_name.replace(/\./g, "_");
                            tdata += "<tr"+update_class+"><td><strong>" + data.domains[i].domain_name + "</strong>&nbsp;<img rel=\"progress_img\" src=\"/images/update.png\" width=\"16\" height=\"16\" alt=\"\" id=\"progress_"+dnid+"\" class=\""+hidepr+"\" /><img rel=\"error_img\" src=\"/images/error.png\" width=\"16\" height=\"16\" alt=\"\" id=\"qerror_"+dnid+"\" class=\"qerror hide\" /></td><td style=\"width:100px;text-align:center\"><i class=\" icon-calendar\"></i>&nbsp;" + data.domains[i].exp_date + "</td><td style=\"width:40px;text-align:center\">"+update_icon+"</td></tr>";
                        }
                        tdata += "</tbody></table>";
                        $('#data_domains').html(tdata);                    
                    } else {
                        $('#data_domains').html('<br/>'+js_lang_no_domains_accounts+'&nbsp;'+js_lang_no_add_by_click);
                    }           

                    // Services

                    if (data.services && data.services.length > 0) {
                        var tdata='';
                        tdata = '<table class="table table-striped table-bordered" id="services_table"><tbody>';
                        for (var i = 0; i < data.services.length; i++) {
                            var tr_class='';
                            if (data.services[i].days <= 0) {
                                tr_class=' class="error"';
                            }
                            tdata += "<tr"+tr_class+"><td><strong>" + data.services[i].name + "</strong></td><td style=\"width:90px;text-align:center\"><i class=\" icon-time\"></i>&nbsp;" + data.services[i].days + "</td><td style=\"width:40px;text-align:center\"><span class=\"btn btn-mini\"><i class=\"icon-plus-sign\"></i></span></td></tr>";
                        }
                        tdata += "</tbody></table>";
                        $('#data_services').html(tdata);                    
                    } else {
                        $('#data_services').html('<br/>'+js_lang_no_services_accounts);
                    }

                    $('body').tooltip({animation:true, html: false, placement: 'right', trigger: 'hover', selector: '[rel=progress_img]', title: js_lang_progress_popup_title});
                    $('.qerror').tooltip({animation:true, html: false, placement: 'right', trigger: 'hover', title: js_lang_error_popup_text});

                    if (queue) {
                        setTimeout(function() { loadQueue() }, 6000);
                        queue_request_active = true;
                    }

                    if (data.history && data.history.length > 0) {
                        var tdata='';
                        tdata = js_lang_history_hint+'<br/><br/><table class="table table-striped table-bordered" id="history_table"><tbody>';
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
                            tdata += "<tr"+tr_class+"><td>" + data.history[i].event + "</strong></td><td style=\"width:90px\"><img src=\""+pic+"\" width=\"16\" height=\"16\" alt=\"\" />&nbsp;" + data.history[i].amount + "</td><td style=\"width:160px;text-align:center\">"+data.history[i].date+"</td></tr>";
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
                            domain_zones += "<option value=\"" + zone + "\">" + zone + " (" + cost+ " " + js_lang_billing_currency + "/" + js_lang_hac_per_month + ")</option>";
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
    $('#btn_add_hosting').click(function() {
        $('#hosting_dialog_head').html(js_lang_add_hosting);
        $('#haccount').val('');
        $('#hpwd').val('');
        $('#hpwd_repeat').val('');
        $('#hosting_dialog').modal({
            keyboard: true
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
        $(".inpt-domain").each(function() {
            $(this).val('');
        });
        $('select option:first-child').attr("selected", "selected");
        $(".ctrl-grp-domain").each(function() {
            $(this).removeClass('error');
        });
        $('#domain_dialog').modal({
            keyboard: true
        });
        $('#domain_edit_ajax').hide();
        $('#domain_edit_form').show();
        $('#domain_edit_buttons').show();
        $('#domain_name').focus();        
        updateDomainPreview();
    });
    $('#btn_hosting_save').click(function() {        
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
            if (!confirm(js_lang_pay_action_confirm+' '+$('#hupcost').html()+' '+js_lang_billing_currency)) {
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
                        var tdata='';
                        tdata += tdata += "<tr id=\"hosting_row_" + data.haccount + "\"><td style=\"width:100px\"><strong>" + data.haccount + "</strong>&nbsp;<img src=\"/images/update.png\" width=\"16\" height=\"16\" alt=\"\" id=\"progress_"+data.haccount+"\" class=\"hide\" /><img rel=\"error_img\" src=\"/images/error.png\" width=\"16\" height=\"16\" alt=\"\" id=\"qerror_"+data.haccount+"\" class=\"hide\" /></span></td><td style=\"text-align:right\">" + data.hplan_name + " <small style=\"color:#666\">(" + data.hplan_cost + " " + js_lang_billing_currency + "/" + js_lang_hac_per_month + ")</small></td><td style=\"width:90px;text-align:center\"><i class=\" icon-time\"></i>&nbsp;<span id=\"hosting_days_"+data.haccount+"\">" + data.hdays + "</span></td><td style=\"width:40px;text-align:center\"><span class=\"btn btn-mini\" onclick=\"updateHosting('"+data.haccount+"');\"><i class=\"icon-plus-sign\"></i></span></td></tr>";
                        if ($('#hosting_table tr:last').size() > 0) {
                            $('#hosting_table tr:last').after(tdata);
                        } else {
                            var ndata = '<table class="table table-striped table-bordered" id="hosting_table"><tbody>'+tdata+"</tbody></table>";
                            $('#data_hosting').html(ndata);
                        }
                        $('#hosting_dialog').modal('hide');
                        $('#funds_avail').html(data.funds_remain);
                        $('#progress_'+data.haccount).show();
                        reloadHistory();
                        queue_internal.push(data.haccount);
                        if (!queue_request_active) {
                            setTimeout(function() { loadQueue() }, 6000);
                            queue_request_active = true;
                        }
                    }
                },
                error: function () {
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
            if (!confirm(js_lang_pay_domain_confirm+': '+ $('#domain_name').val() + '.' + $('#domain_zone option:selected').text())) {
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
                        var update_class='';
                        if (data.zone != "ru" && data.zone != "su") {
                            update_icon = '<span class="btn btn-mini"><i class="icon-refresh" onclick="updateDomain(\''+data.domain_name+'\');""></i></span>';
                        }
                        var dnid=data.domain_name.replace(/\./g, "_");
                        var tdata = "<tr"+update_class+"><td><strong>" + data.domain_name + "</strong>&nbsp;<img rel=\"progress_img\" src=\"/images/update.png\" width=\"16\" height=\"16\" alt=\"\" id=\"progress_"+dnid+"\" /><img rel=\"error_img\" src=\"/images/error.png\" width=\"16\" height=\"16\" alt=\"\" id=\"qerror_"+dnid+"\" class=\"hide\" /></td><td style=\"width:100px;text-align:center\"><i class=\" icon-calendar\"></i>&nbsp;" + data.exp_date + "</td><td style=\"width:40px;text-align:center\">"+update_icon+"</td></tr>";
                        if ($('#domains_table tr:last').size() > 0) {
                            $('#domains_table tr:last').after(tdata);
                        } else {
                            var ndata = '<table class="table table-striped table-bordered" id="domains_table"><tbody>'+tdata+"</tbody></table>";
                            $('#data_domains').html(ndata);
                        }                        
                        $('#domain_dialog').modal('hide');
                        $('#funds_avail').html(data.funds_remain);                        
                        $('#progress_'+dnid).show();
                        reloadHistory();
                        queue_internal.push(data.domain_name);
                        alert(queue_request_active);
                        if (!queue_request_active) {
                            setTimeout(function() { loadQueue() }, 6000);
                            queue_request_active = true;
                        }
                    }
                },
                error: function () {
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
        if (!confirm(js_lang_pay_action_confirm+' '+$('#hupcost').html()+' '+js_lang_billing_currency)) {
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
                    $('#progress_'+data.haccount).show();
                    $('#hosting_days_'+data.haccount).html(data.hdays);
                    $('#hosting_update_dialog').modal('hide');
                    $('#funds_avail').html(data.funds_remain);
                    reloadHistory();
                    queue_internal.push(data.haccount);
                    if (!queue_request_active) {
                        setTimeout(function() { loadQueue() }, 6000);
                        queue_request_active = true;
                    }
                }
            },
            error: function () {
                $('#hosting_update_edit_form_error_text').html(js_lang_error_ajax);
                $('#hosting_update_edit_form_error').fadeIn(400);
                $('#hosting_update_edit_form_error').alert();
                $('#hosting_update_edit_ajax').hide();
                $('#hosting_update_edit_form').show();
                $('#hosting_update_edit_buttons').show();
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
                        tdata = js_lang_history_hint+'<br/><br/><table class="table table-striped table-bordered" id="history_table"><tbody>';
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
                            tdata += "<tr"+tr_class+"><td>" + data.history[i].event + "</strong></td><td style=\"width:90px\"><img src=\""+pic+"\" width=\"16\" height=\"16\" alt=\"\" />&nbsp;" + data.history[i].amount + "</td><td style=\"width:160px;text-align:center\">"+data.history[i].date+"</td></tr>";
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
                if (data.queue && data.queue.length > 0) {
                    var req_history=false;      
                    for (var i=0; i<queue_internal.length; i++) {
                        var found = false;
                        for (var s=0; s< data.queue.length; s++) {                            
                            if (data.queue[s].object == queue_internal[i]) {
                                found = true;
                            }
                        }
                        if (!found) {
                            var dnid = queue_internal[i].replace(/\./g, "_");
                            $('#progress_'+dnid).fadeOut(300).delay(300).attr('src', '/images/blank.gif');
                            req_history=true;                            
                        }                        
                    }
                    queue_internal = [];
                    for (var i=0; i<data.queue.length; i++) {
                        queue_internal.push(data.queue[i].object);
                    }                                                            
                    // reload history
                    if (req_history) {
                        reloadHistory();
                    }
                    if (queue_internal.length > 0) {
                        setTimeout(function() { loadQueue() }, 6000);
                    } else {
                        queue_request_active = false;
                    }
                } else {
                    for (var i=0; i<queue_internal.length; i++) {
                        var dnid = queue_internal[i].replace(/\./g, "_");
                        $('#progress_'+dnid).fadeOut(300).delay(300).attr('src', '/images/blank.gif');
                    }
                    queue_internal = [];
                    queue_request_active = false;
                    reloadHistory();
                }
                // show warnings for hosting accounts
                $('[rel=error_img]').show();                
                for (var s=0; s< data.hosting.length; s++) {
                    $('#qerror_'+data.hosting[s]).hide();
                }
                for (var s=0; s< data.domains.length; s++) {
                    var dnid=data.domains[s].replace(/\./g, "_");
                    $('#qerror_'+dnid).hide();
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
}); // document.ready
function updateHosting(acnt) {
    $('#hosting_update_edit_form_error').hide();
    $('#hosting_update_dialog').modal({
        keyboard: true
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
$('#hdaysup').change(function(){
    var hupcost = hosting_plans_cost[$('#hacnt').val()] * $('#hdaysup').val();
    $('#hupcost').html(hupcost);
});
$('#hdays').change(function(){
    var haddcost = hosting_planid_cost[$('#hplan').val()] * $('#hdays').val();
    $('#haddcost').html(haddcost);
});
$('#hplan').change(function(){
    var haddcost = hosting_planid_cost[$('#hplan').val()] * $('#hdays').val();
    $('#haddcost').html(haddcost);
});