Game = require '/Game'
User = require '/User'
LudoBoard = require '/LudoBoard'

userCount = 0
chai.Assertion.overwriteMethod 'eql', (_super) -> (other) ->
  if @_obj instanceof Game and other instanceof Game
    assertPropertiesEql ['id', 'createdAt', 'board', 'players', 'currentSide', 'dice', 'state'], @_obj, other

suite 'Game model', ->
  before ->
    @join = (users...) =>
      f = (u) => (asyncCb) => @game.join u, asyncCb
      doJoins = (cb) -> async.parallel (f(u) for u in users), cb
      return doJoins users.pop() if _.isFunction _.last users
      doJoins
    @move = (piece, cb) =>
      if _.isUndefined cb
        (cb) => @game.move piece, cb
      else
        @game.move piece, cb

  beforeEach (done) ->
    createUser = (cb) =>
      User.model.create "test-GameModel-#{userCount++}", cb
    async.parallel [
      Game.model.create,
      createUser, createUser, createUser, createUser, createUser
    ], (err, [@game, @u0, @u1, @u2, @u3, @u4]) =>
      _.bindAll @game
      done err

  test 'can create new game', ->
    @game.should.be.an.instanceof Game
    @game.board.should.be.an.instanceof LudoBoard

  test 'can get a game by id', (done) ->
    Game.model.get @game.id, (err, saved) =>
      @game.should.be.deep.equal saved
      done()

  test 'user can join a game', (done) ->
    @game.join @u0, (err) =>
      Should.not.exist err
      @game.isUserPlaying(@u0).should.equal true
      @game.playerCount().should.equal 1
      done()

  test 'user can only join a game once', (done) ->
    @join @u0, @u0, (err, res) =>
      err.should.equal 'already_joined'
      @game.playerCount().should.equal 1
      done()

  test 'at most 4 users can join a game', (done) ->
    @join @u0, @u1, @u2, @u3, @u4, (err, res) ->
      err.should.equal 'game_full'
      done()

  test 'user can leave a game', (done) ->
    @join @u0, (err, res) =>
      Should.not.exist err
      @game.leave @u0, (err) =>
        Should.not.exist err
        @game.isUserPlaying(@u0).should.equal false
        @game.playerCount().should.equal 0
        done()

  test 'error if leaving a a game without joining first', (done) ->
    @game.leave @u0, (err, res) ->
      err.should.equal 'leave_not_joined'
      done()

  test 'game starts in STATE_JOINING state', ->
    @game.state.should.equal Game.STATE_JOINING

  test 'can only move in STATE_MOVE', (done) ->
    @move 0, (err) =>
      err.should.equal 'wrong_state'
      async.series [ @join(@u0, @u1), @game.start, @move(0)], (err) =>
        err.should.equal 'wrong_state'
        async.series [@game.rollDice, @move(0)], done

  test 'can only roll dice in STATE_DICE', (done) ->
    @game.rollDice (err) =>
      err.should.equal 'wrong_state'
      async.series [ @join(@u0, @u1), @game.start, @game.rollDice ], (err) =>
        Should.not.exist err
        @game.rollDice (err) =>
          err.should.equal 'wrong_state'
          done()

  test 'can only start in STATE_JOINING', (done) ->
    async.series [ @join(@u0, @u1), @game.start ], (err) =>
      Should.not.exist err
      @game.start (err) =>
        err.should.equal 'wrong_state'
        async.series [ @game.rollDice, @game.start ], (err) ->
          err.should.equal 'wrong_state'
          done()

  test "can't start with less than 2 players", (done) ->
    @game.start (err) =>
      err.should.equal 'not_enough_players 0 2'
      async.series [ @join(@u0), @game.start ], (err) ->
        err.should.equal 'not_enough_players 1 2'
        done()

  test 'no joining after a game has started', (done) ->
    async.series [ @join(@u0, @u1), @game.start, @join(@u2) ], (err) ->
      err.should.equal 'game_started'
      done()

  test 'rollDice sets the current dice roll value', (done) ->
    async.series [@join(@u0, @u1), @game.start, @game.rollDice ], (err) =>
      Should.not.exist err
      @game.dice.should.be.within 1, 6
      done()

  test 'rollDice, move step the game through states and sides', (done) ->
    stateIs = (s) => (cb) =>
      @game.state.should.equal s
      cb()
    sideIs = (s) => (cb) =>
      @game.currentSide.should.equal s
      cb()
    async.series [
      @join(@u0, @u1, @u2),
      @game.start,    stateIs(Game.STATE_DICE), sideIs(0),
      @game.rollDice, stateIs(Game.STATE_MOVE), sideIs(0),
      @move(0),       stateIs(Game.STATE_DICE), sideIs(1),
      @game.rollDice, stateIs(Game.STATE_MOVE), sideIs(1),
      @move(0),       stateIs(Game.STATE_DICE), sideIs(2),
      @game.rollDice, stateIs(Game.STATE_MOVE), sideIs(2),
      @move(0),       stateIs(Game.STATE_DICE), sideIs(0)
    ], done
