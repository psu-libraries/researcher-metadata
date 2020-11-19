$(document).on('ready pjax:end', function(event){
    if ($('div.grouped-publications').length) {
        if ($('a.opened').length) {
            toggleMenu(event)
        }
    }
});
