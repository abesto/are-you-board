Game = require '/Game'
User = require '/User'
LudoBoard = require '/LudoBoard'

QUnit.module 'server.models.game'

asyncTest 'can create new game', ->
  Game.model.create (err, game) ->
    ok game instanceof Game
    ok game.board instanceof LudoBoard
    start()

asyncTest 'can get a game by id', ->
  Game.model.create (err, game) ->
    Game.model.get game.id, (err, saved) ->
      deepEqual game, saved
      start()

asyncTest 'user can join a game', ->
  async.parallel [Game.model.create, User.model.create], (err, [game, user]) ->
    game.join user, (err, res) ->
      ok game.isUserPlaying user
      Game.model.get game.id, (err, saved) ->
        deepEqual game, saved
        start()

asyncTest 'at most 4 users can join a game', 5, ->
  async.parallel [
    Game.model.create
    User.model.create
    User.model.create
    User.model.create
    User.model.create
    User.model.create
  ], (err, [game, u0, u1, u2, u3, u4]) ->
    async.waterfall [
      (     cb) -> game.join u0, cb
      (res, cb) -> ok game.isUserPlaying u0; game.join u1, cb
      (res, cb) -> ok game.isUserPlaying u1; game.join u2, cb
      (res, cb) -> ok game.isUserPlaying u2; game.join u3, cb
      (res, cb) -> ok game.isUserPlaying u3; game.join u4, cb
    ], (err, res) ->
      strictEqual 'game_full', err
      start()

