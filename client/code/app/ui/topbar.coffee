views =
  login: require('./login')

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

module.exports =
  render: ->
    $navbarContainer.empty().append ss.tmpl['navbar'].render(window.user)
    findControls()
    $admin.show() if user.isSuperuser
    $('#signout').click views.login.logout

  destroy: ->
    $navbarContainer.empty()
