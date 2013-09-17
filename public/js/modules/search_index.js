$(document).ready(function () {
	$('#search_query').focus();
    var url_hash = window.location.hash.substr(1);
    if (url_hash && url_hash.length > 0) {
        $('#search_query').val(url_hash);
        performSearch(1);
    }
}); // document.ready

var performSearch = function(page) {
    $('#search_query').css('background', "#fff");    
    $('#search_result').html('');
    if ($('#search_query').val().length < 3) {
        $('#search_query').css('background', "#ffdddd");
        return;
    }
    $('#search_result').html('<img src="/images/white_loading.gif" width="16" height="16" alt="" />&nbsp;'+js_lang_search_in_progress);
    $('#search_query').focus();
    $.ajax({
        type: 'POST',
        url: '/search/process',
        data: {
            search_query: $('#search_query').val(),
            page: page
        },
        dataType: "json",
        success: function (data) {
            if (data.status == 1) {
                $('#search_result').html('');
                if (data.items && data.items.length > 0) {
                    for (var i = 0; i < data.items.length; i++) {
                        $('#search_result').append('<a href="'+data.items[i].url+'"><h4 class="taracot-search-result-title">'+data.items[i].title+'</h4></a><a href="'+data.items[i].url+'"><div class="taracot-search-result-url">'+window.location.protocol+'//'+window.location.host+data.items[i].url+'</div></a><div class="taracot-search-result-text">'+data.items[i].text+'</div>');
                    }
                }
                if (data.paginator_html) {
                    $('#search_result').append(data.paginator_html);
                }
                if (!data.count) {
                    $('#search_result').append(js_lang_search_no_results);
                }
            } else {
                $('#search_result').html('<div class="alert alert-danger">'+js_lang_search_error+'</div>');
            }
        },
        error: function () {
            $('#search_result').html('<div class="alert alert-danger">'+js_lang_search_error+'</div>');
        }
    });
};

$('#btn_search').click(function() { performSearch(1); });

function setSearchPage(page) {
    performSearch(page);
}

$('#search_query').bind('keypress', function (e) {
    if (e.keyCode == 13) {
        performSearch(1);
    }
});