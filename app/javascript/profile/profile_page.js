import Foundation from './foundation';

$(window).on('load', function () {
  $(function () { $(document).foundation(); });
});

$(window).on('load', function () {
  if ($('ul#profile-tabs').children().length > 0) {
    $('ul#profile-tabs').children().first().addClass('is-active');
    $('ul#profile-tabs:first-child').attr('aria-selected', 'true');

    $('div#profile-tabs-content').children().first().addClass('is-active');
  }

  // Scroll
  $('.tabs li a').on('click', function () {
    $([document.documentElement, document.body]).animate({
      scrollTop: $(".tabs-wrapper").offset().top + 20
    }, 150);
  });

  // Sticky nav
  var tabNav = $('#profile-tabs');
  var stickyNavTop = tabNav.offset().top;
  var navWidth = tabNav.width();
  var padding = tabNav.height();

  var stickyNav = function () {
    var scrollTop = $(window).scrollTop();
    if (scrollTop > stickyNavTop) {
      tabNav.addClass('sticky');
      $('.tabs-wrapper').css('padding-top', padding);
      if (Foundation.MediaQuery.is('large')) {
        tabNav.css('width', navWidth);
      }
    } else {
      tabNav.removeClass('sticky');
      tabNav.css('width', '100%');
      $('.tabs-wrapper').css('padding-top', 0);
    }
  };

  stickyNav();

  $(window).scroll(function () {
    stickyNav();
  });
});
