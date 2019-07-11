$(document).on('turbolinks:load', ->
  $('form.visibility-control').each(->
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
  )
)
