redis = require('redis').createClient()
Game = require '../../../client/code/app/Game'
LudoBoard = require '../../../client/code/app/LudoBoard'

exports.actions = (req, res, ss) ->
  create: ->
    redis.incr 'game', (err, id) ->
      game = new Game id, new LudoBoard()
      str = game.serialize()
      res str
      redis.set "game:#{id}", str

