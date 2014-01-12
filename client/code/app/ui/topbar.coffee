routes = require('./routes')

logger = winston.getLogger('topbar')

$navbarContainer = $('.navbar-container')

module.exports =
  render: ->
    routeUrls = {}
    for name in ['admin', 'lobby', 'openGames', 'myGames', 'logout']
      routeUrls[name] = routes[name].interpolate {}
    $navbarContainer.empty().append ss.tmpl['navbar'].render {
      user: window.user,
      routeUrls: routeUrls
    }

  destroy: ->
    $navbarContainer.empty()
