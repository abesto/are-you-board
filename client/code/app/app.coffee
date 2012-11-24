User = require '/User'
topbar = require './ui/topbar'
login = require './ui/login'

window.UI ||= {}
UI.$container = $('div.container')

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
  UI.init user
