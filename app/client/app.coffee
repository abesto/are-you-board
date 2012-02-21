window.RUB = {}

loginInit = ->
  SS.client.user.login.init appInit

appInit = (res) ->
  RUB.user = res
  navbar()
  SS.client.chat.init()

navbar = ->
  RUB.navbar.html $('#common-navbar').tmpl user: RUB.user
  if RUB.user
    $('#logout').click ->
      SS.server.user.logout -> 
        delete RUB.user
        navbar()
        loginInit()
    $('#edit-profile').click SS.client.user.profile.edit

exports.init = ->
  RUB.content = $('#content')
  RUB.navbar = $('#navbar-content')
  RUB.V = SS.shared.validate

  SS.server.user.getCurrentUser (res) ->
    if res
      appInit res
    else
      loginInit()
