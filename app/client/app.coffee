window.RUB = {}

appInit = ->
  SS.client.navbar.render 'chat'

exports.init = ->
  RUB.$content = $('#content')
  RUB.$navbar = $('#navbar-content')
  RUB.V = SS.shared.validate

  SS.client.user.getCurrentUser (res) ->
    if res then appInit()
    else SS.client.user.loginForm appInit
