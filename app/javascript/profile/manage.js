require('jquery-ui/ui/widgets/sortable')

$(document).ready(function () {
  $('form.visibility-control').each(function () {
    var form = $(this);

    form.find('.visibility-toggle').on('change', function () {
      form.trigger('submit.rails');
    });
  });

  $('tbody#authorships').sortable({
    update: function (event, ui) {
      $.ajax({
        method: 'PUT',
        url: '/authorships/sort',
        data: $(this).sortable('serialize')
      });
    }
  });

  $('tbody#presentation-contributions').sortable({
    update: function (event, ui) {
      $.ajax({
        method: 'PUT',
        url: '/presentation_contributions/sort',
        data: $(this).sortable('serialize')
      });
    }
  });

  $('tbody#user-performances').sortable({
    update: function (event, ui) {
      $.ajax({
        method: 'PUT',
        url: '/user_performances/sort',
        data: $(this).sortable('serialize')
      });
    }
  });
});
