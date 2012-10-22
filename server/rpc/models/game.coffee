base = require './base'
Game = require '../../../client/code/app/Game'
LudoBoard = require '../../../client/code/app/LudoBoard'

exports.actions = (req, res, ss) ->
  actions = base req, res, ss, Game,
    create: (game) ->
      game.board = new LudoBoard()

