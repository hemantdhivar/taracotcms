$(document).ready(function () {
    $('#customer_tabs a').click(function (e) {
        e.preventDefault();
        $(this).tab('show');
    });
    $('#billing_customer_wrap_ajax').fadeIn(200);
    $.ajax({
        type: 'POST',
        url: '/customer/data/load',
        dataType: "json",
        success: function (data) {
            if (data.result == '0') {                
                $('#billing_customer_wrap').html(js_lang_error_ajax);
                $('#billing_customer_wrap').fadeIn(200);
                $('#billing_customer_wrap_ajax').hide();
            } else { // OK
                if (data.hosting && data.hosting.length > 0) {
                    var tdata='';
                    tdata = '<table class="table table-striped " id="hosting_table"><tbody>';
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
                    tdata = '<table class="table table-striped " id="domains_table"><tbody>';                    
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
                        tdata += "<tr"+update_class+"><td><strong>" + data.domains[i].domain_name + "</strong></span></td><td style=\"width:100px\"><i class=\" icon-calendar\"></i>&nbsp;" + data.domains[i].exp_date + "</td><td style=\"width:40px;text-align:center\">"+update_icon+"</td></tr>";
                    }
                    tdata += "</tbody></table>";
                    $('#data_domains').html(tdata);                    
                } else {
                    $('#data_domains').html('<br/>'+js_lang_no_domains_accounts+'&nbsp;'+js_lang_no_add_by_click);
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
}); // document.ready