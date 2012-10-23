Game = require '/Game'
User = require '/User'
LudoBoard = require '/LudoBoard'

QUnit.module 'server.models.game'

asyncTest 'can create new game', 2, ->
  Game.model.create (err, game) ->
    ok game instanceof Game
    ok game.board instanceof LudoBoard
    start()

asyncTest 'can get a game by id', 1, ->
  Game.model.create (err, game) ->
    Game.model.get game.id, (err, saved) ->
      deepEqual game, saved
      start()

asyncTest 'user can join a game', 3, ->
  async.parallel [Game.model.create, User.model.create], (err, [game, user]) ->
    game.join user, (err) ->
      strictEqual err, null
      ok game.isUserPlaying user
      strictEqual game.playerCount(), 1
      start()

asyncTest 'user can only join a game once', 1, ->
  async.parallel [Game.model.create, User.model.create], (err, [game, user]) ->
    game.join user, (err, res) -> game.join user, (err, res) ->
      strictEqual err, 'already_joined'
      start()

asyncTest 'at most 4 users can join a game', 12, ->
  expectedPlayerCount = 1
  join = (prevUser, user) -> (game, cb) ->
    ok game.isUserPlaying prevUser
    strictEqual game.playerCount(), expectedPlayerCount
    game.join user, (err, game) ->
      strictEqual err, null
      expectedPlayerCount++
      cb err, game

  async.parallel [
    Game.model.create
    User.model.create
    User.model.create
    User.model.create
    User.model.create
    User.model.create
  ], (err, [game, u0, u1, u2, u3, u4]) -> async.waterfall [
      (cb) ->  game.join u0, (err, res) -> Game.model.get game.id, cb
      join u0, u1
      join u1, u2
      join u2, u3
      (res, cb) -> game.join u4, cb
  ], (err, res) ->
    strictEqual 'game_full', err
    Game.model.get game.id, (err, game) ->
      strictEqual err, null
      strictEqual game.playerCount(), expectedPlayerCount
      start()

asyncTest 'user can leave a game', 5, ->
  async.parallel [Game.model.create, User.model.create], (err, [game, user]) ->
    game.join user, (err) ->
      ok game.isUserPlaying user
      strictEqual err, null
      game.leave user, (err) ->
        strictEqual err, null
        ok not game.isUserPlaying user
        strictEqual game.playerCount(), 0
        start()

asyncTest 'error if leaving a a game without joining first', 1, ->
  async.parallel [Game.model.create, User.model.create], (err, [game, user]) ->
    game.leave user, (err, res) ->
      strictEqual err, 'leave_not_joined'
      start()

asyncTest 'nextSide sets currentSide to the next non-null player', 4, ->
  async.parallel [
    Game.model.create
    User.model.create
    User.model.create
    User.model.create
    User.model.create
  ], (err, [game, u0, u1, u2, u3]) ->
    currentSideIs = (side) -> (cb) ->
      strictEqual game.currentSide, side
      cb null
    join = (u) -> (cb) -> game.join u, cb
    leave = (u) -> (cb) -> game.leave u, cb
    nextSide = (cb) -> game.nextSide cb
    async.series [
      join(u0), join(u1), join(u2), join(u3),
      leave(u0), leave(u2),
      nextSide, currentSideIs(1),
      nextSide, currentSideIs(3),
      nextSide, currentSideIs(1)], (err) ->
        strictEqual err, null
        start()


