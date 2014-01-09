window.app.i18n ||= {}

dataKey = 'trans'
selector = "[data-#{dataKey}]"

i18n = module.exports =
  activate: (lang) ->
    ss.load.code "/i18n/trans.#{lang}.coffee", () ->
      app.i18n.trans = require("/trans.#{lang}")
      i18n.update()

  gettext: (key, context) ->
    throw 'Rendering context not supported' if context
    try
      text = eval("app.i18n.trans.#{key}")
    catch e
      text = key
    text

  update: ->
    for el in $(selector)
      i18n.updateEl.call el

  updateEl: ->
    $this = $(this)
    value = gettext $this.data('trans')
    if $this.attr('placeholder')
      $this.attr('placeholder', value)
    else if $this.attr('type') == 'submit'
      $this.val value
    else
      $this.text value

window.gettext = i18n.gettext
$(selector).livequery(i18n.updateEl)
$ -> i18n.activate 'hu'
