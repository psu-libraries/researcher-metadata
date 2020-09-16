$(document).on('click', "[name='_integrate']", function () {
  var button = $("[name='_integrate']").not($(this));
  button.attr('disabled', true);
});
