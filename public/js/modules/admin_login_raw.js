var browser = '';
var browserVersion = 0;
$('#captcha_img').html('<img id="captcha_shown" src="/captcha_img?' + Math.random() + '" onclick="reloadCaptcha()" width="100" height="50" alt="" style="cursor:pointer" />');
$('#btn_login').click(function () {
    if (!$('#auth_username').val() || !$('#auth_password').val() || !$('#auth_captcha').val()) {
        $('#auth_username').focus();
        $('#taracot_logo').fadeOut(50).delay(2700).fadeIn(500);
        $('#taracot_error').fadeIn(400).delay(2000).fadeOut(400);
        return;
    }
    $('#auth_form').hide();
    $('#taracot-auth-progress-bar').show();
    $('.taracot-auth-modal-header').hide();
    $('#taracot-auth-body').hide();
    $('.taracot-auth-modal-footer').hide();
    $.ajax({
        type: 'POST',
        url: '/admin/authorize',
        data: {
            username: $('#auth_username').val(),
            password: $('#auth_password').val(),
            reg_captcha: $('#auth_captcha').val()
        },
        dataType: "json",
        success: function (data) {
            if (data.result == '1') {                
                location.href = '/admin?' + Math.random();
            } else {
                $('#taracot-auth-progress-bar').hide();
                $('.taracot-auth-modal-header').show();
                $('#taracot-auth-body').show();
                $('.taracot-auth-modal-footer').show();
                $('#auth_password').val('');
                $('#auth_username').focus();
                $('#taracot_logo').fadeOut(50).delay(2700).fadeIn(500);
                $('#taracot_error').fadeIn(400).delay(2000).fadeOut(400);
                $('#auth_captcha').val('');
                reloadCaptcha();
            }
        },
        error: function () {
            $('#taracot-auth-progress-bar').hide();
            $('.taracot-auth-modal-header').show();
            $('#taracot-auth-body').show();
            $('.taracot-auth-modal-footer').show();
            $('#auth_password').val('');
            $('#auth_username').focus();
            $('#auth_captcha').val('');
            reloadCaptcha();
            alert(js_lang_error_ajax);
        }
    });
});
$('#auth_error_close').click(function () {
    $('#auth_error_modal').modal('hide');
});
$('#btn_back').click(function () {
    location.href = "/";
});

function detectBrowser() {
    browser = '';
    browserVersion = 0;
    if (/Opera[\/\s](\d+\.\d+)/.test(navigator.userAgent)) {
        this.browser = 'Opera';
    } else if (/MSIE (\d+\.\d+);/.test(navigator.userAgent)) {
        this.browser = 'MSIE';
    } else if (/Navigator[\/\s](\d+\.\d+)/.test(navigator.userAgent)) {
        this.browser = 'Netscape';
    } else if (/Chrome[\/\s](\d+\.\d+)/.test(navigator.userAgent)) {
        this.browser = 'Chrome';
    } else if (/Safari[\/\s](\d+\.\d+)/.test(navigator.userAgent)) {
        this.browser = 'Safari';
        /Version[\/\s](\d+\.\d+)/.test(navigator.userAgent);
        this.browserVersion = new Number(RegExp.$1);
    } else if (/Firefox[\/\s](\d+\.\d+)/.test(navigator.userAgent)) {
        this.browser = 'Firefox';
    }
    if (this.browser == '') {
        this.browser = 'Unknown';
    } else if (this.browserVersion == 0) {
        this.browserVersion = parseFloat(new Number(RegExp.$1));
    }
}
$('#btn_continue_anyway').click(function () {
    $('#taracot_old_browser_warning').modal('hide');
    $('#taracot-auth-modal').modal({"keyboard":false,"backdrop":false});    
})
$(document).ready(function () {
    $('#taracot-auth-modal').modal({"keyboard":false,"backdrop":false});
    $("#auth_password").keypress(function (e) {
        if (e.which == 13) {
            $("#btn_login").click();
        }
    });
    $("#auth_username").keypress(function (e) {
        if (e.which == 13) {
            $("#btn_login").click();
        }
    });
    $("#auth_captcha").keypress(function (e) {
        if (e.which == 13) {
            $("#btn_login").click();
        }
    });
    detectBrowser();    
    if (browser && browser == "MSIE" && browserVersion && browserVersion < 9) {
        $('#taracot-auth-modal').modal('hide');
        $('#taracot_old_browser_warning').modal();
    } else {
        $('#taracot_auth').show();
        $('#auth_username').focus();
    }
});
function reloadCaptcha() {
    $('#captcha_shown').attr('src', '/captcha_img?' + Math.random());
}