async = require 'async'
base = require './base'
Game = require '../../../client/code/app/Game'
User = require '../../../client/code/app/User'
LudoBoard = require '../../../client/code/app/LudoBoard'

model = require '../../model'

exports.actions = (req, res, ss) ->
  actions = base req, res, ss, Game,
    create: (game) ->
      game.board = new LudoBoard()

  actions.join = (gameId, userId) ->
    model(Game).get gameId, (err, gameStr) ->
      return res err if err
      game = Game.deserialize gameStr
      model(User).get userId, (err, userStr) ->
        return res err if err
        user = User.deserialize userStr
        if game.isUserPlaying user
          winston.warn "already_joined #{user} #{game}"
          return res 'already_joined'
        idx = _.indexOf game.players, null
        if idx == -1
          winston.warn "game_full #{user} #{game}"
          return res 'game_full'
        game.players[idx] = user
        winston.info "join #{user} #{game}"
        actions.save game.id, game.serialize()

  actions.leave = (gameId, userId) ->
    async.parallel [
      (cb) -> model(Game).get gameId, cb
      (cb) -> model(User).get userId, cb
    ], (err, [gameStr, userStr]) ->
      game = Game.deserialize gameStr
      user = User.deserialize userStr
      idx = game.userSide user
      if _.isUndefined idx
        winston.warn "leave_not_joined #{user} #{game}"
        return res 'leave_not_joined'
      game.players[idx] = null
      winston.info "leave #{user} #{game}"
      actions.save game.id, game.serialize()

  actions

