$(document).ready(function () {
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
    $('#billing_customer_wrap_ajax').fadeIn(200);
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
                if (data.hosting && data.hosting.length > 0) {
                    var tdata='';
                    tdata = '<table class="table table-striped table-bordered" id="hosting_table"><tbody>';
                    for (var i = 0; i < data.hosting.length; i++) {
                        var tr_class='';
                        if (data.hosting[i].days <= 0) {
                            tr_class=' class="error"';
                        }
                        tdata += "<tr"+tr_class+"><td style=\"width:100px\"><strong>" + data.hosting[i].account + "</strong></span></td><td style=\"text-align:right\">" + data.hosting[i].plan_name + " <small style=\"color:#666\">(" + data.hosting[i].plan_cost + "/" + js_lang_hac_per_month + ")</small></td><td style=\"width:90px;text-align:center\"><i class=\" icon-time\"></i>&nbsp;" + data.hosting[i].days + "</td><td style=\"width:40px;text-align:center\"><span class=\"btn btn-mini\"><i class=\"icon-plus-sign\"></i></span></td></tr>";
                    }
                    tdata += "</tbody></table>";
                    $('#data_hosting').html(tdata);                    
                } else {
                    $('#data_hosting').html('<br/>'+js_lang_no_hosting_accounts+'&nbsp;'+js_lang_no_add_by_click);
                }
                if (data.domains && data.domains.length > 0) {
                    var tdata='';                    
                    tdata = '<table class="table table-striped table-bordered" id="domains_table"><tbody>';                    
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
                        tdata += "<tr"+update_class+"><td><strong>" + data.domains[i].domain_name + "</strong></td><td style=\"width:100px;text-align:center\"><i class=\" icon-calendar\"></i>&nbsp;" + data.domains[i].exp_date + "</td><td style=\"width:40px;text-align:center\">"+update_icon+"</td></tr>";
                    }
                    tdata += "</tbody></table>";
                    $('#data_domains').html(tdata);                    
                } else {
                    $('#data_domains').html('<br/>'+js_lang_no_domains_accounts+'&nbsp;'+js_lang_no_add_by_click);
                }
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
                        $('input[name=private]').attr(':checked', true);
                    } else {
                        $('input[name=private]').attr(':checked', false);
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
}); // document.ready