window.RUB = {}

loginInit = ->

appInit = (res) ->
  RUB.user = res
  navbar()
  SS.client.chat.init()

navbar = ->
  $navbar = $('#common-navbar').tmpl user: RUB.user
  RUB.navbar.html $navbar
  if RUB.user
    $navbar.find('#logout').click ->
      SS.server.user.logout -> 
        delete RUB.user
        navbar()
        SS.client.user.login appInit
    $navbar.find('#chat').click SS.client.chat.init
    $navbar.find('#edit-profile').click SS.client.user.edit

exports.init = ->
  RUB.content = $('#content')
  RUB.navbar = $('#navbar-content')
  RUB.V = SS.shared.validate

  SS.server.user.getCurrentUser (res) ->
    if res
      appInit res
    else
      SS.client.user.login appInit
