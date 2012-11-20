async = require 'async'

base = require './base'

Game = require('../../../client/code/app/Game')
User = require '../../../client/code/app/User'
LudoBoard = require '../../../client/code/app/LudoBoard'

Authorization = require '../../authorization'

exports.actions = (req, res, ss) ->
  req.use 'session'
  auth = new Authorization req, res

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
        cb()

  originalCreate = actions.create
  actions.create = (args...) ->
    return unless auth.checkRes 'Game.create'
    originalCreate args...

  originalGet = actions.get
  actions.get = (args...) ->
    return unless auth.checkRes 'Game.get'
    originalGet args...

  actions.join = (gameId, userId) -> Game.model.withLock gameId, res, (res) ->
    async.parallel [
      (cb) -> Game.model.get gameId, cb
      (cb) -> User.model.get userId, cb
    ], (err, [game, user]) ->
      return res err if err
      return unless auth.checkRes 'Game.join', user
      game.join user, (err) ->
        return res err if err
        req.session.channel.subscribe "game:#{gameId}"
        ss.publish.channel "game:#{gameId}", "Game:join:#{gameId}", userId
        game.save res

  actions.start = (gameId) -> Game.model.withLock gameId, res, (res) ->
    Game.model.get gameId, (err, game) ->
      return res err if err
      return unless auth.checkRes 'Game.start', game
      game.start (err) ->
        return res err if err
        game.save res

  update ((cb) -> cb null, null), 'start'

  actions.leave = (gameId, userId) -> Game.model.withLock gameId, res, (res) ->
    async.parallel [
      (cb) -> Game.model.get gameId, cb
      (cb) -> User.model.get userId, cb
    ], (err, [game, user]) ->
      return res err if err
      game.leave user, (err) ->
        return res err if err
        return unless auth.checkRes 'Game.leave', user
        req.session.channel.unsubscribe "game:#{gameId}"
        game.save res

  actions.rollDice = (gameId) -> Game.model.withLock gameId, res, (res) ->
    Game.model.get gameId, (err, game) ->
      return res err if err
      return unless auth.checkRes 'Game.rollDice', game
      game.rollDice (err) ->
        return res err if err
        game.save res

  actions.move = (gameId, pieceId) ->
    Game.model.get gameId, (err, game) ->
      return res err if err
      piece = game.getPiece pieceId
      return unless auth.checkRes 'Game.move', game, piece
      game.move piece, (err) ->
        return res err if err
        game.save res

  actions.skip = (gameId) ->
    Game.model.get gameId, (err, game) ->
      return res err if err
      return unless auth.checkRes 'Game.skip', game
      game.skip (err) ->
        return res err if err
        game.save res

  actions.startPiece = (gameId) ->
    Game.model.get gameId, (err, game) ->
      return res err if err
      return unless auth.checkRes 'Game.startPiece', game
      game.startPiece (err) ->
        return res err if err
        game.save res

  actions

