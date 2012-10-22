Game = require '/Game'
LudoBoard = require '/LudoBoard'

QUnit.module 'server.models.game'

test 'can create new game', ->
  stop()
  Game.model.create (game) ->
    ok game instanceof Game
    ok game.board instanceof LudoBoard
    start()


