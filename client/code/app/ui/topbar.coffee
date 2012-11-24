views =
  login: require('./login')
  admin: require('./admin')
  lobby: require('./lobby')

currentView = null


$navbarContainer = $('.navbar-container')
$navbar = null
$lobby = null
$admin = null
$signout = null

findControls = ->
  $navbar = $('.navbar-fixed-top')
  $lobby = $navbar.find('#navbar-lobby-btn')
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
    $('#signout').click views.login.logout
    $lobby.click()

  destroy: ->
    $navbarContainer.empty()
