User = require '/User'
topbar = require './ui/topbar'
login = require './ui/login'

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
  login.renderLogin()

User.model.getCurrent (err, user) ->
  return login.renderLogin() if err
  ss.heartbeatStart()
  UI.init user
