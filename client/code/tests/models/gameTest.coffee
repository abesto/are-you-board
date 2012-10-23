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
        strictEqual game.playerCount(), 1
        start()

asyncTest 'at most 4 users can join a game', 10, ->
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
      (res, cb) -> ok game.isUserPlaying u0; strictEqual game.playerCount(), 1; game.join u1, cb
      (res, cb) -> ok game.isUserPlaying u1; strictEqual game.playerCount(), 2; game.join u2, cb
      (res, cb) -> ok game.isUserPlaying u2; strictEqual game.playerCount(), 3; game.join u3, cb
      (res, cb) -> ok game.isUserPlaying u3; strictEqual game.playerCount(), 4; game.join u4, cb
    ], (err, res) ->
      strictEqual game.playerCount(), 4
      strictEqual 'game_full', err
      start()

asyncTest 'user can leave a game', 3, ->
  async.parallel [Game.model.create, User.model.create], (err, [game, user]) ->
    game.join user, (err, res) ->
      ok !err
      game.leave user, (err, res) ->
        ok !game.isUserPlaying user
        strictEqual game.playerCount(), 0
        start()

asyncTest 'error if leaving a a game without joining first', 1, ->
  async.parallel [Game.model.create, User.model.create], (err, [game, user]) ->
    game.leave user, (err, res) ->
      strictEqual err, 'leave_not_joined'
      start()

