$(document).on('ready', ->
  $('form.authorship-visibility').each(->
    form = $(this)

    form.find('.visibility-toggle').on('change', ->
      form.trigger('submit.rails')
    )
  )

  $('tbody#authorships').sortable(
    update: (event, ui) ->
      $.ajax(
        method: 'PUT',
        url: '/authorships/sort',
        data: $(this).sortable('serialize')
      )
    handle: 'td.pub-title'
  )
)
