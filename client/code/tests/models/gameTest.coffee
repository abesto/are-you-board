Game = require '/Game'
User = require '/User'
LudoBoard = require '/LudoBoard'

QUnit.module 'server.models.game'

test 'can create new game', ->
  stop()
  Game.model.create (game) ->
    ok game instanceof Game
    ok game.board instanceof LudoBoard
    start()

test 'can get a game by id', ->
  stop()
  Game.model.create (game) ->
    Game.model.get game.id, (saved) ->
      deepEqual game, saved
      start()

test 'user can join a game', ->
  stop()
  Game.model.create (game) ->
    User.model.create 'testuser' + (new Date()).getTime(), (user) ->
      game.join user, (res) ->
        ok game.isUserPlaying user
        Game.model.get game.id, (saved) ->
          deepEqual game, saved
          start()
