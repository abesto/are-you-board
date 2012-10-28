Game = require '/Game'
User = require '/User'
LudoBoard = require '/LudoBoard'

QUnit.module 'server.models.game'

asyncTestWithGameAndUsers = (name, assertCount, playerCount, cb) ->
  cmds = [Game.model.create].concat (User.model.create for i in [0 ... playerCount])
  asyncTest name, assertCount + 1, ->
    async.parallel cmds, (err, items) ->
      strictEqual err, null
      game = items[0]
      _.bindAll game
      @join = (u) -> (cb) -> game.join u, cb
      @leave = (u) -> (cb) -> game.leave u, cb
      @stateIs = (s) -> (cb) ->
        strictEqual game.state, s, "state is #{s}"
        cb null
      @sideIs = (side) -> (cb) ->
        strictEqual game.currentSide, side, "side is #{side}"
        cb null
      @move = (piece) -> (cb) -> game.move piece, cb
      cb items...

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

asyncTestWithGameAndUsers 'user can join a game', 3, 1, (game, user) ->
  game.join user, (err) ->
    strictEqual err, null
    ok game.isUserPlaying user
    strictEqual game.playerCount(), 1
    start()

asyncTestWithGameAndUsers 'user can only join a game once', 1, 1, (game, user) ->
  game.join user, (err, res) -> game.join user, (err, res) ->
    strictEqual err, 'already_joined'
    start()

asyncTestWithGameAndUsers 'at most 4 users can join a game', 12, 5, (game, u0, u1, u2, u3, u4) ->
  expectedPlayerCount = 1
  join = (prevUser, user) -> (game, cb) ->
    ok game.isUserPlaying prevUser
    strictEqual game.playerCount(), expectedPlayerCount
    game.join user, (err, game) ->
      strictEqual err, null
      expectedPlayerCount++
      cb err, game
  async.waterfall [
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

asyncTestWithGameAndUsers 'game starts in STATE_JOINING state', 1, 0, (game) ->
  strictEqual game.state, Game.STATE_JOINING
  start()

asyncTestWithGameAndUsers 'can only move in STATE_MOVE', 2, 2, (game, u0, u1) ->
  async.series [ @join(u0), @join(u1), @move(0) ], (err) ->
    strictEqual err, 'wrong_state'
    async.series [ game.start, @move(0)], (err) ->
      strictEqual err, 'wrong_state'
      start()

asyncTestWithGameAndUsers 'can roll dice only in STATE_DICE', 2, 2, (game, u0, u1) ->
  async.series [ @join(u0), @join(u1), game.rollDice ], (err) ->
    strictEqual err, 'wrong_state'
    async.series [ game.start, game.rollDice, game.rollDice ], (err) ->
      strictEqual err, 'wrong_state'
      start()

asyncTestWithGameAndUsers 'can start only in STATE_JOINING', 2, 2, (game, u0, u1) ->
  async.series [ @join(u0), @join(u1), game.start, game.start ], (err) ->
    strictEqual err, 'wrong_state'
    async.series [ game.rollDice, game.start ], (err) ->
      strictEqual err, 'wrong_state'
      start()

asyncTestWithGameAndUsers 'can\'t start with less than 2 players', 1, 1, (game, user) ->
  async.series [ @join(user), game.start ], (err) ->
    strictEqual err, 'not_enough_players 1 2'
    start()


asyncTestWithGameAndUsers 'no joining after a game has started', 1, 3, (game, u0, u1, u2) ->
  async.series [
    @join(u0), @join(u1),
    game.start,
    @join(u2)
  ], (err) ->
    strictEqual err, 'game_started'
    start()

asyncTestWithGameAndUsers 'rollDice sets the current dice roll value', 2, 2, (game, u0, u1) ->
  async.series [@join(u0), @join(u1), game.start, game.rollDice ], (err) ->
    strictEqual err, null
    ok (game.dice <= 6 and game.dice >= 1)
    start()

asyncTestWithGameAndUsers 'rollDice, move step the game through states and sides', 15, 3, (game, u0, u1, u2) ->
  async.series [
    @join(u0), @join(u1), @join(u2)
    game.start,    @stateIs(Game.STATE_DICE), @sideIs(0),
    game.rollDice, @stateIs(Game.STATE_MOVE), @sideIs(0),
    @move(0),      @stateIs(Game.STATE_DICE), @sideIs(1),
    game.rollDice, @stateIs(Game.STATE_MOVE), @sideIs(1),
    @move(0),      @stateIs(Game.STATE_DICE), @sideIs(2),
    game.rollDice, @stateIs(Game.STATE_MOVE), @sideIs(2),
    @move(0),      @stateIs(Game.STATE_DICE), @sideIs(0)
  ], (err) ->
    strictEqual err, null
    start()
