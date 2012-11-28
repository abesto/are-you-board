async = require 'async'

base = require './base'

Game = require('../../../client/code/app/Game')
User = require '../../../client/code/app/User'
LudoBoard = require '../../../client/code/app/LudoBoard'

Authorization = require '../../authorization'


updateOpenGames = (game) ->
  joining = game.state == Game.STATE_JOINING
  not_full = game.playerCount() < Game.MAXIMUM_PLAYERS
  not_empty = game.playerCount() > 0
  # Filter non-public games if/when they are implemented
  open = joining and not_full and not_empty
  if open
    redis.zadd 'open_games', game.createdAt.getTime(), game.id
  else
    redis.zrem 'open_games', game.id
originalSave = Game::save
Game::save = (cb) ->
  updateOpenGames this
  originalSave.call this, cb


exports.actions = (req, res, ss) ->
  req.use 'session'
  auth = new Authorization req


  keyGamesOfUser = (user) -> "games_of_user:#{user.id}"

  addToGamesOfUser = (game, user, cb) ->
    redis.sadd keyGamesOfUser(user), game.id, (err, res) -> cb? err, res

  removeFromGamesOfUser = (game, user, cb) ->
    redis.srem keyGamesOfUser(user), game.id, (err, res) -> cb? err, res

  listGamesOfUser = (user, cb) ->
    redis.smembers keyGamesOfUser(user), cb



  errorOrEvent = (res, event, args...) -> (err, rawGame) ->
    return res err if err
    res()
    Game.deserialize rawGame, (err, game) ->
      ss.publish.channel "game:#{game.id}", "Game:#{event}:#{game.id}", args

  update = (paramGetter, fun) -> (gameId, paramId) -> Game.model.withLock gameId, res, (res) ->
    getters = [(cb) -> Game.model.get gameId, cb]
    getters.push(paramGetter(paramId)) if paramGetter
    async.waterfall getters, (err, args) ->
      game = args[0]
      param = args[1] if args.length > 1
      game[fun].call param, (err) ->
        return res err if err
        game.save res

  actions = base req, res, ss, Game,
    create: (game, cb) ->
      User.model.get req.session.userId, (err, creator) ->
        return cb err if err
        game.createdBy = creator.id
        game.board = new LudoBoard()
        updateOpenGames game
        addToGamesOfUser game, creator, cb

  originalCreate = actions.create
  actions.create = (args...) ->
    return unless auth.checkRes res, 'Game.create'
    originalCreate args...

  originalGet = actions.get
  actions.get = (args...) ->
    return unless auth.checkRes res, 'Game.get'
    originalGet args...

  actions.join = (gameId, userId) -> Game.model.withLock gameId, res, (res) ->
    async.parallel [
      (cb) -> Game.model.get gameId, cb
      (cb) -> User.model.get userId, cb
    ], (err, [game, user]) ->
      return res err if err
      return unless auth.checkRes res, 'Game.join', user
      game.join user, (err) ->
        return res err if err
        addToGamesOfUser game, user
        req.session.channel.subscribe "game:#{gameId}"
        game.save errorOrEvent(res, 'join', userId)

  actions.start = (gameId) -> Game.model.withLock gameId, res, (res) ->
    Game.model.get gameId, (err, game) ->
      return res err if err
      return unless auth.checkRes res, 'Game.start', game
      game.start (err) ->
        return res err if err
        game.save errorOrEvent(res, 'start')

  update ((cb) -> cb null, null), 'start'

  actions.leave = (gameId, userId) -> Game.model.withLock gameId, res, (res) ->
    async.parallel [
      (cb) -> Game.model.get gameId, cb
      (cb) -> User.model.get userId, cb
    ], (err, [game, user]) ->
      return res err if err
      return unless auth.checkRes res, 'Game.leave', user
      game.leave user, (err) ->
        return res err if err
        game.save (err, rawGame) ->
          return res err if err
          removeFromGamesOfUser game, user
          errorOrEvent(res, 'leave', userId)(err, rawGame)
          req.session.channel.unsubscribe "game:#{gameId}"

  actions.rollDice = (gameId) -> Game.model.withLock gameId, res, (res) ->
    Game.model.get gameId, (err, game) ->
      return res err if err
      return unless auth.checkRes res, 'Game.rollDice', game
      game.rollDice (err) ->
        return res err if err
        game.save errorOrEvent(res, 'rollDice', game.dice)

  actions.move = (gameId, pieceId) ->
    Game.model.get gameId, (err, game) ->
      return res err if err
      piece = game.getPiece pieceId
      return unless auth.checkRes res, 'Game.move', game, piece
      game.move piece, (err) ->
        return res err if err
        game.save errorOrEvent(res, 'move', pieceId)

  actions.skip = (gameId) ->
    Game.model.get gameId, (err, game) ->
      return res err if err
      return unless auth.checkRes res, 'Game.skip', game
      game.skip (err) ->
        return res err if err
        game.save errorOrEvent(res, 'skip')

  actions.startPiece = (gameId) ->
    Game.model.get gameId, (err, game) ->
      return res err if err
      return unless auth.checkRes res, 'Game.startPiece', game
      game.startPiece (err) ->
        return res err if err
        game.save errorOrEvent(res, 'startPiece')

  actions.listGamesOfUser = (userId) ->
    User.model.get userId, (err, user) ->
      return res err if err
      return unless auth.checkRes res, 'Game.listGamesOfUser', user
      listGamesOfUser user, res

  actions

