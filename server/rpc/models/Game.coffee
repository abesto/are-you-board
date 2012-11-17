async = require 'async'

base = require './base'

Game = require('../../../client/code/app/Game')
User = require '../../../client/code/app/User'
LudoBoard = require '../../../client/code/app/LudoBoard'

exports.actions = (req, res, ss) ->
  req.use 'session'

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

  actions.join = (gameId, userId) -> Game.model.withLock gameId, res, (res) ->
    async.parallel [
      (cb) -> Game.model.get gameId, cb
      (cb) -> User.model.get userId, cb
    ], (err, [game, user]) ->
      return res err if err
      game.join user, (err) ->
        return res err if err
        req.session.channel.subscribe "game:#{gameId}"
        game.save res

  actions.start = (gameId) -> Game.model.withLock gameId, res, (res) ->
    Game.model.get gameId, (err, game) ->
      return res err if err
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
        req.session.channel.unsubscribe "game:#{gameId}"
        game.save res

  actions.rollDice = (gameId) -> Game.model.withLock gameId, res, (res) ->
    Game.model.get gameId, (err, game) ->
      return res err if err
      game.rollDice (err) ->
        return res err if err
        game.save res

  actions.move = (gameId, pieceId) ->
    Game.model.get gameId, (err, game) ->
      return res err if err
      game.move game.getPiece(pieceId), (err) ->
        return res err if err
        game.save res

  actions.skip = (gameId) ->
    Game.model.get gameId, (err, game) ->
      return res err if err
      game.skip (err) ->
        return res err if err
        game.save res

  actions.startPiece = (gameId) ->
    Game.model.get gameId, (err, game) ->
      return res err if err
      game.startPiece (err) ->
        return res err if err
        game.save res

  actions

