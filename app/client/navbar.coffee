class Navbar
  constructor: (@$navbar) ->
    @items = {}
  
  render: (defaultTab=null) ->
    $navbar = $('#common-navbar').tmpl user:RUB.user
    RUB.$navbar.html $navbar
    for id, action of @items
      do (id, action) ->
        $navbar.find('#'+id).click ->
          $navbar.find('.active').removeClass('active')
          action()
    if defaultTab isnt null
      $navbar.find('#'+defaultTab).click()


instance = null

exports.render = (defaultTab=null) ->
  if instance is null
    instance = new Navbar RUB.navbar
    instance.items = 
      chat: SS.client.chat.init,
      'edit-profile': SS.client.user.edit 
      logout: -> 
        SS.server.user.logout ->
          delete RUB.user
          instance.render()
          SS.client.user.loginForm -> instance.render defaultTab
  instance.render defaultTab
