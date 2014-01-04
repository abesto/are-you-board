require('/utils')(global ? window)
User = require '/User'
topbar = require '/ui/topbar'
routes = require '/ui/routes'

window.UI ||= {}
window.app ||= {}
UI.$container = $('div.container')
UI.$container.css 'height', $(window).height() - 120

UI.init = (user) ->
  UI.$container.empty()
  window.user = user
  topbar.render()

UI.reset = ->
  topbar.destroy()
  UI.$container.empty()
  routes.navigate routes.login

User.model.getCurrent (err, user) ->
  if err
    routes.init()
  else
    ss.heartbeatStart()
    UI.init user
    routes.init()

