games = require('./games')
Game = require '/Game'
views =
  login: require('./login')
  admin: require('./admin')
  lobby: require('./lobby')
  games: games.makeRender Game.model.listOpenGames
  myGames: games.makeRender (args...) -> Game.model.listGamesOfUser window.user, args...

currentView = null
window.setCurrentView = (v) -> currentView = v

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

setButtonView = ($btn, view) ->
  $btn.click (event) ->
    event.preventDefault()
    $('.navbar .active').removeClass('active')
    $btn.addClass('active')
    currentView?.destroy?()
    currentView = view
    view.render()


module.exports =
  render: ->
    $navbarContainer.empty().append ss.tmpl['navbar'].render(window.user)
    findControls()
    if user.isSuperuser
      $admin.show()
      setButtonView $admin, views.admin
    setButtonView $lobby, views.lobby
    setButtonView $games, views.games
    setButtonView $myGames, views.myGames
    $('#signout').click views.login.logout
    $lobby.click()

  destroy: ->
    $navbarContainer.empty()
