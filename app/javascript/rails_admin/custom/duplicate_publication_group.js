$(document).on('rails_admin.dom_ready', function () {
  if ($('.grouped-publications').length) {
    var merge_target_value = function () {
      return $('input[name=merge_target_publication_id]:checked').val();
    };

    var disable_merge_button = function () {
      $('#merge-selected-button').prop('disabled', true);
    };

    var enable_merge_button = function () {
      $('#merge-selected-button').prop('disabled', false);
    };

    var disable_ignore_button = function () {
      $('#ignore-selected-button').prop('disabled', true);
    };

    var enable_ignore_button = function () {
      $('#ignore-selected-button').prop('disabled', false);
    };

    var toggle_buttons = function () {
      var selected_pub_ids = [];
      $("input[name='selected_publication_ids[]']:checked").each(function () {
        selected_pub_ids.push($(this).val());
      });

      if (merge_target_value() && selected_pub_ids.length > 0 && $.inArray(merge_target_value(), selected_pub_ids) === -1) {
        enable_merge_button();
      } else {
        disable_merge_button();
      }

      if (!merge_target_value() || !selected_pub_ids.length > 0 || $.inArray(merge_target_value(), selected_pub_ids) !== -1) {
        disable_merge_button();
      }

      if (selected_pub_ids.length > 1) {
        enable_ignore_button();
      } else {
        disable_ignore_button();
      }
    };

    disable_merge_button();
    disable_ignore_button();

    $('.merge-target-selector').on('change', toggle_buttons);
    $('.publication-selector').on('change', toggle_buttons);
  }
});