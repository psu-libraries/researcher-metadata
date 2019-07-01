$(document).on('ready', ->
  $('form.authorship-visibility').each(->
    form = $(this)

    form.find('.visibility-toggle').on('change', ->
      form.trigger('submit.rails')
    )
  )
)
