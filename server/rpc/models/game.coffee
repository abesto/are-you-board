base = require './base'
Game = require '../../../client/code/app/Game'
User = require '../../../client/code/app/User'
LudoBoard = require '../../../client/code/app/LudoBoard'

exports.actions = (req, res, ss) ->
  actions = base req, res, ss, Game,
    create: (game) ->
      game.board = new LudoBoard()

  actions.join = (gameId, userId) ->
    redis.get "Game:#{gameId}", (err, gameStr) ->
      return res err if err
      game = Game.deserialize gameStr
      redis.get "User:#{userId}", (err, userStr) ->
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
        gameStr = game.serialize()
        actions.save game.id, gameStr

  actions

