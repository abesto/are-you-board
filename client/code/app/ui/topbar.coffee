routes = require('./routes')

logger = winston.getLogger('topbar')

$navbarContainer = $('.navbar-container')
$navbar = null
$games = null
$myGames = null
$lobby = null
$admin = null
$signout = null

findControls = ->
  $navbar = $('.navbar-fixed-top')
  $lobby = $navbar.find('#navbar-lobby-btn')
  $games = $navbar.find('#navbar-games-btn')
  $myGames = $navbar.find('#navbar-my-games-btn')
  $admin = $navbar.find('#navbar-admin-btn')
  $signout = $navbar.find('#signout')

setButtonRoute = ($btn, route) ->
  $btn.click (event) ->
    logger.debug $btn.attr('id')
    event.preventDefault()
    routes.navigate route

  route.switched.add -> $btn.removeClass('active')
  route.matched.add -> $btn.addClass('active')


module.exports =
  render: ->
    $navbarContainer.empty().append ss.tmpl['navbar'].render(window.user)
    findControls()
    if user.isSuperuser
      $admin.show()
      setButtonRoute $admin, routes.admin
    setButtonRoute $lobby, routes.lobby
    setButtonRoute $games, routes.openGames
    setButtonRoute $myGames, routes.myGames
    $('#signout').click routes.logout

  destroy: ->
    $navbarContainer.empty()
