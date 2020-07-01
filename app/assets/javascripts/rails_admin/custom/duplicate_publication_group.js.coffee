$(document).on('ready pjax:end', ->
  if $('.grouped-publications').length
    merge_target_value = ->
      $('input[name=merge_target_publication_id]:checked').val()

    disable_merge_button = ->
      $('#merge-selected-button').prop('disabled', true)

    enable_merge_button = ->
      $('#merge-selected-button').prop('disabled', false)

    disable_ignore_button = ->
      $('#ignore-selected-button').prop('disabled', true)

    enable_ignore_button = ->
      $('#ignore-selected-button').prop('disabled', false)

    toggle_buttons = ->
      selected_pub_ids = new Array()
      $.each($("input[name='selected_publication_ids[]']:checked"), ->
        selected_pub_ids.push($(this).val())
      )

      if merge_target_value() && selected_pub_ids.length > 0 && $.inArray(merge_target_value(), selected_pub_ids) == -1
        enable_merge_button()

      if !merge_target_value() || !selected_pub_ids.length > 0 || $.inArray(merge_target_value(), selected_pub_ids) != -1
        disable_merge_button()

      if selected_pub_ids.length > 1
        enable_ignore_button()
      else
        disable_ignore_button()

    disable_merge_button()    
    disable_ignore_button()

    $('.merge-target-selector').on('change', toggle_buttons)
    $('.publication-selector').on('change', toggle_buttons)
)