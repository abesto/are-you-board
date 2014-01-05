Game = require '/Game'
User = require '/User'
Repository = require '/Repository'
LudoRules = require '/LudoRules'
routes = require '/ui/routes'

$createGame = null
$joinGame = null
$openGame = null

logger = winston.getLogger 'ui.games'

findControls = ->
  $createGame = $('#create-game-btn')
  $joinGame = $('.join-game.btn')
  $openGame = $('.open-game.btn')

ludoFlavor = ->
  flavor = new LudoRules.Flavor()
  $form = $('form#ludo-flavor')
  for field in LudoRules.Flavor.FIELDS
    $checkbox = $form.find('#' + field)
    flavor[field] = $checkbox.is(':checked') if $checkbox.length > 0
  flavor

makeRender = (type, listMethod) ->
  render = ->
    logger.debug 'render_start', {type: type}
    listMethod (err, games) ->
      if err
        logger.error 'failed_to_load_games', {listMethod: listMethod, err: err}
        return alert err
      async.map games, ((game, cb) ->
        Repository.get User, game.createdBy, (err, createdBy) ->
          return cb err if err
          cb null, {
            id: game.id
            playerCount: game.playerCount()
            maximumPlayers: Game.MAXIMUM_PLAYERS
            createdBy: createdBy.nick
            createdAt: moment(game.createdAt).format('YYYY-MM-DD HH:mm:ss')
            joined: game.isUserPlaying(window.user)
          }
      ), (err, context) ->
        return alert err if err
        UI.$container.empty().append ss.tmpl['gamelist'].render games: context
        findControls()
        $createGame.click ->
          logger.debug 'create_game_clicked'
          ludoFlavor = ludoFlavor().serialize()
          Game.model.create ludoFlavor, (err, game) ->
            if err
              logger.error 'failed_to_create_game', {ludoFlavor: ludoFlavor, err: err}
              return alert err
            game.join window.user, (err) ->
              if err
                logger.error 'failed_to_join_created_game', {ludoFlavor: ludoFlavor, err: err}
                return alert err
              logger.info 'created_and_joined_game', {ludoFlavor: ludoFlavor, err: err}
              render()
        $joinGame.click ->
          gameId = $(this).data('gameid')
          logger.debug 'join_game_clicked', {gameId: gameId}
          Repository.get Game, gameId, (err, game) ->
            if err
              logger.error 'failed_to_get_game_to_join', {gameId: gameId, err: err}
              return alert err
            game.join window.user, (err) ->
              if err
                logger.error 'failed_to_join_game', {gameId: gameId, err: err}
                return alert err
              logger.info 'joined_game', {gameId: gameId}
              routes.navigate routes.ludo, {gameId: gameId}
        $openGame.click ->
          gameId = $(this).data('gameid')
          logger.debug 'rejoin_game_clicked', {gameId: gameId}
          Repository.get Game, gameId, (err, game) ->
            if err
              logger.error 'failed_to_get_game_to_rejoin', {gameId: gameId, err: err}
              return alert err
            game.rejoin (err) ->
              if err
                logger.error 'failed_to_rejoin_game', {gameId: gameId, err: err}
                return alert err
              logger.info 'rejoined_game', {gameId: gameId}
              routes.navigate routes.ludo, {gameId: gameId}
        logger.verbose 'render_finished', {type: type}


exports.bindRoutes = ->
  routes.openGames.matched.add(makeRender('open_games', Game.model.listOpenGames))
  routes.myGames.matched.add(makeRender('my_games', ((args...) -> Game.model.listGamesOfUser window.user, args...)))

