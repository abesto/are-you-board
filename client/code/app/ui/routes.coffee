routes = {}
routes.login = crossroads.addRoute 'login/:redirectTo:'
routes.logout = crossroads.addRoute 'logout'
routes.lobby = crossroads.addRoute ''
routes.myGames = crossroads.addRoute 'games/my'
routes.openGames = crossroads.addRoute 'games/open'
routes.ludo = crossroads.addRoute 'ludo/{gameId}'

index = routes.lobby

logger = winston.getLogger 'routes'

redirectToLoginIfNeeded = ->
  noLoginNeeded = [routes.login]
  for route in _.difference(_.values(routes), noLoginNeeded)
    do (route) ->
      route.matched.add ->
        unless window.user
          route.matched.halt()
          redirectTo = slugifySegment hasher.getHash()
          logger.debug 'redirect_to_login', redirectTo
          exports.navigate routes.login, {redirectTo: redirectTo}

navigate = (route, args={}) -> hasher.setHash route.interpolate(args)

# Export routes
for name, route of routes
  exports[name] = route
exports.index = index
exports.navigate = navigate

redirectToIndexFromUnknown = ->
  crossroads.bypassed.add (request) ->
    logger.warn 'unknown_route', request
    navigate index

parseHash = (newHash, oldHash) ->
  crossroads.parse(newHash)

hasher.initialized.add(parseHash)
hasher.changed.add(parseHash)

initialized = false
exports.init = ->
  return if initialized
  redirectToIndexFromUnknown()
  redirectToLoginIfNeeded()
  for moduleWithRoutes in ['/ui/lobby', '/ui/games', '/ui/login', '/ui/ludo']
    require(moduleWithRoutes).bindRoutes()
  hasher.init()
  initialized = true

exports.slugifySegment = slugifySegment = (s) -> s.replace(/\//g, '.')
exports.unslugifySegment = unslugifySegment = (s) -> s.replace(/\./g, '/')
