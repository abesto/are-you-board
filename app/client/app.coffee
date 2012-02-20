window.RUB = {}

exports.init = ->
  RUB.content = $('#content')
  RUB.navbar = $('#navbar-content')
  RUB.V = SS.shared.validate

  SS.server.user.getCurrentUser (res) ->
    RUB.navbar.html $('#common-navbar').tmpl(user: res)
    if res then console.log res
    else SS.client.user.login.init (user) ->
      $('#common-navbar').tmpl(user: user)

