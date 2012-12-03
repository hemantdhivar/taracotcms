var browser = '';
var browserVersion = 0;
$('#btn_login').click(function () {
    if (!$('#auth_username').val() || !$('#auth_password').val()) {
        $('#auth_username').focus();
        $('#taracot_logo').fadeOut(50).delay(2700).fadeIn(500);
        $('#taracot_error').fadeIn(400).delay(2000).fadeOut(400);
        return;
    }
    $('#auth_form').hide();
    $('#taracot_auth_img').show();
    $.ajax({
        type: 'POST',
        url: '/admin/authorize',
        data: {
            username: $('#auth_username').val(),
            password: $('#auth_password').val()
        },
        dataType: "json",
        success: function (data) {
            if (data.result == '1') {
                location.href = '/admin?' + Math.random();
            } else {
                $('#auth_form').show();
                $('#taracot_auth_img').hide();
                $('#auth_password').val('');
                $('#auth_username').focus();
                $('#taracot_logo').fadeOut(50).delay(2700).fadeIn(500);
                $('#taracot_error').fadeIn(400).delay(2000).fadeOut(400);
            }
        },
        error: function () {
            $('#auth_form').show();
            $('#taracot_auth_img').hide();
            $('#auth_password').val('');
            $('#auth_username').focus();
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
    $('.browser_choice').hide();
    $('#btn_continue_anyway').hide();
    $('#taracot_old_browser_warning').fadeOut(1000);
    $('#taracot_auth').fadeIn(1000);
    $('#auth_username').focus();
})
$(document).ready(

function () {
    $("#auth_password").keypress(function (e) {
        if (e.which == 13) {
            $("#btn_login").click();
        }
    });
    $("#auth_username").keypress(function (e) {
        if (e.which == 13) {
            $('#auth_error_modal').modal('hide');
        }
    });
    detectBrowser();
    if (browser && browser == "MSIE" && browserVersion && browserVersion < 9) {
        $('#taracot_old_browser_warning').show();
    } else {
        $('#taracot_auth').show();
        $('#auth_username').focus();
    }
});