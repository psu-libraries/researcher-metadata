$(document).on('ready pjax:end', function(event){
    if ($(location).attr("href").match(/.*\/admin\/duplicate_publication_group/)) {
        if ($('a.opened').length) {
            toggleMenu(event)
        }
    }
});
