Game = require '/Game'
User = require '/User'
Repository = require '/Repository'
LudoRules = require '/LudoRules'
routes = require '/ui/routes'

$createGame = null
$joinGame = null
$openGame = null
$createModal = null

logger = winston.getLogger 'ui.games'

findControls = ->
  $createGame = $('#create-game-btn')
  $joinGame = $('.join-game.btn')
  $openGame = $('.open-game.btn')
  $createModal = $('#create-ludo-modal')

formToLudoFlavor = ->
  flavor = new LudoRules.Flavor()
  $form = $('form#ludo-flavor')
  for field in LudoRules.Flavor.FIELDS
    $checkbox = $form.find('#' + field)
    flavor[field] = $checkbox.is(':checked') if $checkbox.length > 0
  flavor

makeRender = (route, listMethod) -> (page=1) ->
  logger.debug 'render_start', {route: route.interpolate({page: page})}
  listMethod (err, games) ->
    if err
      logger.error 'failed_to_load_games', {listMethod: listMethod, err: err}
      return alert err
    limit = require('/constants').ui.games.pagerLimit
    offset = (page - 1) * limit
    displayedGames = _(games).drop(offset).take(limit).value()
    createdByIds = _.pluck(displayedGames, 'createdBy')
    Repository.getMulti User, createdByIds..., (err, createdByUsers) ->
      if err
        logger.error 'failed_to_get_created_by_users', {ids: createdByIds, err: err}
        return alert err
      contextGames = []
      for [game, createdBy] in _.zip(displayedGames, createdByUsers)
        contextGames.push {
          playerCount: game.playerCount()
          maximumPlayers: Game.MAXIMUM_PLAYERS
          createdBy: createdBy.nick
          createdAt: moment(game.createdAt).format('YYYY-MM-DD HH:mm:ss')
          joined: game.isUserPlaying(window.user)
          uri: routes.ludo.interpolate {gameId: game.id}
        }
      pageCount = Math.floor((games.length - 1) / limit + 1)
      pagesFrom = Math.max(1, page - Math.floor(limit - 1 / 2))
      pagesTo = Math.min(pageCount, page + Math.ceil((limit - 1 / 2)))
      pageIds = _.range(pagesFrom, pagesTo + 1)
      logger.debug 'pagination', {pageCount: pageCount, pagesFrom: pagesFrom, pagesTo: pagesTo, pageIds: pageIds}
      UI.$container.empty().append ss.tmpl['gamelist'].render {
        prev: {
          disabled: pagesFrom == page
          hash: '#' + route.interpolate({page: Math.max(pagesFrom, page-1)})
        }
        next: {
          disabled: pagesTo == page
          hash: '#' + route.interpolate({page: Math.min(pagesTo, page+1)})
        }
        pages: ({
          id: id,
          hash: '#' + route.interpolate({page: id}),
          isCurrentPage: page == id
        } for id in pageIds)
        games: contextGames
      }
      findControls()
      $createGame.click -> $createModal.modal('hide').on 'hidden.bs.modal', ->
        logger.debug 'create_game_clicked'
        ludoFlavor = formToLudoFlavor().serialize()
        Game.model.create ludoFlavor, (err, game) ->
          if err
            logger.error 'failed_to_create_game', {ludoFlavor: ludoFlavor, err: err}
            return alert err
          game.join window.user, (err) ->
            if err
              logger.error 'failed_to_join_created_game', {ludoFlavor: ludoFlavor, err: err}
              return alert err
            logger.info 'created_and_joined_game', {ludoFlavor: ludoFlavor, err: err}
            routes.navigate routes.ludo, {gameId: game.id}
      logger.debug 'render_finished', {route: route.interpolate({page: page})}


exports.bindRoutes = ->
  routes.openGames.matched.add(makeRender(routes.openGames, Game.model.listOpenGames))
  routes.myGames.matched.add(makeRender(routes.myGames, ((args...) -> Game.model.listGamesOfUser window.user, args...)))

