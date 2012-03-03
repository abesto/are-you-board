window.RUB = {}

appInit = ->
  SS.client.navbar.addItems
    chat: SS.client.chat.init
    editor: SS.client.editor.init
    'edit-profile': SS.client.user.edit 
    logout: SS.client.user.logout
  SS.client.navbar.setDefaultTab('chat')
  SS.client.navbar.render()

exports.init = ->
  RUB.$content = $('#content')
  RUB.V = SS.shared.validate

  SS.client.navbar.init $('#navbar-content')

  SS.client.user.getCurrentUser (res) ->
    if res then appInit()
    else SS.client.user.loginForm appInit
