Game = require '/Game'
LudoBoard = require '/LudoBoard'

QUnit.module 'server.models.game'

test 'can create new game', ->
  stop()
  ss.rpc 'models.game.create', (response) ->
    game = Game.deserialize response
    ok game instanceof Game
    ok game.board instanceof LudoBoard
    start()
