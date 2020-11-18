$(document).ready(function(){
    $(".scroll-wrapper1").scroll(function(){
        $(".scroll-wrapper2")
            .scrollLeft($(".scroll-wrapper1").scrollLeft());
    });
    $(".scroll-wrapper2").scroll(function(){
        $(".scroll-wrapper1")
            .scrollLeft($(".scroll-wrapper2").scrollLeft());
    });
});
$(window).on('load', function (e) {
    $('.scroll-top').width($('table').width());
    $('.grouped-publications').width($('table').width());
});
