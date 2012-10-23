async = require 'async'

base = require './base'
model = require '../../model'

Game = require '../../../client/code/app/Game'
User = require '../../../client/code/app/User'
LudoBoard = require '../../../client/code/app/LudoBoard'

exports.actions = (req, res, ss) ->
  actions = base req, res, ss, Game,
    create: (game) ->
      game.board = new LudoBoard()

  actions.join = (gameId, userId) ->
    async.parallel [
      (cb) -> model(Game).getObject gameId, cb
      (cb) -> model(User).getObject userId, cb
    ], (err, [game, user]) ->
      return res err if err
      if game.isUserPlaying user
        winston.warn "already_joined #{user} #{game}"
        return res 'already_joined'
      idx = game.firstFreeSide()
      if _.isUndefined idx
        winston.warn "game_full #{user} #{game}"
        return res 'game_full'
      game.players[idx] = user
      winston.info "join #{user} #{game}"
      actions.save game.id, game.serialize()

  actions.leave = (gameId, userId) ->
    async.parallel [
      (cb) -> model(Game).getObject gameId, cb
      (cb) -> model(User).getObject userId, cb
    ], (err, [game, user]) ->
      return res err if err
      idx = game.userSide user
      if _.isUndefined idx
        winston.warn "leave_not_joined #{user} #{game}"
        return res 'leave_not_joined'
      game.players[idx] = null
      winston.info "leave #{user} #{game}"
      actions.save game.id, game.serialize()

  actions.nextSide = (gameId) ->
    model(Game).getObject gameId, (err, game) ->
      return res err if err
      game._nextSide()
      actions.save game.id, game.serialize()

  actions

