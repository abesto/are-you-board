defaults =
  title: ''
  message: ''
  type: 'info'
  timeout: 5000
  sticky: false
  closeButton: false
  class: null

window.notify = exports.notify = (opts) ->
  opts = $.extend {}, defaults, opts
  if opts.sticky then opts.closeButton = true
  $alert = $('#common-alert').tmpl opts
  $alert.addClass('alert-' + opts.class) unless opts.class is null
  $('.notifications').append $alert
  setTimeout (-> $alert.remove()), opts.timeout unless opts.sticky

