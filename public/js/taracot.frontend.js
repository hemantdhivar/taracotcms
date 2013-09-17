var default_lang = '';
function setTaracotLang(sl) {
  var host = window.location.hostname;
  var re = new RegExp(taracot_lang_current + "\\.", "");
  host = host.replace(re, '');
  if (sl != default_lang) {
    host = sl + '.' + host;
  }
  var lh = $(location).attr('href');
  var relh = new RegExp(window.location.hostname);
  lh = lh.replace(relh, host);
  location.href = lh;
}
if (taracot_langs_available && taracot_langs_available.length>0) {
  for (var i=0; i<taracot_langs_available.length; i++) {
    if (taracot_langs_available[i].default && taracot_langs_available[i].default == 1) {
      default_lang=taracot_langs_available[i].short;
    }
    $('#taracot_ui_lang_select').append('<li><a href="#" onclick="setTaracotLang(\''+taracot_langs_available[i].short+'\');"><img src="/images/flags/'+taracot_langs_available[i].short+'.png" width="16" height="11" alt="" />&nbsp;'+taracot_langs_available[i].long+'</a></li>');
  }
}
$('#taracot-header-search-query').bind('keypress', function (e) {
  if (e.keyCode == 13) {
    location.href='/search?'+Math.random()+'#'+$('#taracot-header-search-query').val();
  }
});