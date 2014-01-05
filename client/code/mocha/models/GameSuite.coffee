# Integration tests

Game = require '/Game'
User = require '/User'
LudoBoard = require '/LudoBoard'
LudoRules = require '/LudoRules'


chai.Assertion.overwriteMethod 'eql', (_super) -> (other) ->
  if @_obj instanceof Game and other instanceof Game
    assertPropertiesEql ['id', 'createdAt', 'board', 'players', 'currentSide', 'dice', 'state'], @_obj, other

chai.use (_chai, utils) ->
  chai.Assertion.addMethod 'containGame', (game) ->
    list = @_obj
    found = false
    for item in list
      if item.id == game.id
        found = true
        break
    @assert(found,
      "Expected game #{game} to be in list [#{list}]",
      "Expected game #{game} not to be in list [#{list}]"
    )

runGameTests = ->
  it 'can create new game', ->
    @game.should.be.an.instanceof Game
    @game.board.should.be.an.instanceof LudoBoard

  it 'can get a game by id', (done) ->
    Game.model.get @game.id, (err, saved) =>
      @game.should.be.deep.equal saved
      done()

  it 'user can join a game', (done) ->
    @game.join @u0, (err) =>
      Should.not.exist err
      @game.isUserPlaying(@u0).should.equal true
      @game.playerCount().should.equal 1
      done()

  it 'user can only join a game once', (done) ->
    @join @u0, @u0, @u0, @u0, @u0, @u0, @u0, (err, res) =>
      err.should.equal "already_joined"
      done()

  it 'at most 4 users can join a game', (done) ->
    @join @u0, @u1, @u2, @u3, @u4, (err, res) ->
      err.should.equal 'game_full'
      done()

  it 'user can leave a game', (done) ->
    @join @u0, (err, res) =>
      Should.not.exist err
      @game.leave @u0, (err) =>
        Should.not.exist err
        @game.isUserPlaying(@u0).should.equal false
        @game.playerCount().should.equal 0
        done()

  it 'error if leaving a a game without joining first', (done) ->
    @game.leave @u0, (err, res) ->
      err.should.equal 'leave_not_joined'
      done()

  it 'game starts in STATE_JOINING state', ->
    @game.state.should.equal Game.STATE_JOINING

  it 'can only roll dice in STATE_DICE', (done) ->
    @game.rollDice (err) =>
      err.should.equal 'wrong_state'
      async.series [ @join(@u0, @u1), @game.start, @game.rollDice ], (err) =>
        @game.currentSide.should.equal 0
        Should.not.exist err
        @game.rollDice (err) =>
          err.should.equal 'wrong_state'
          done()

  it 'can only start in STATE_JOINING', (done) ->
    async.series [ @join(@u0, @u1), @game.start ], (err) =>
      @game.currentSide.should.equal 0
      Should.not.exist err
      @game.start (err) =>
        err.should.equal 'wrong_state'
        async.series [ @game.rollDice, @game.start ], (err) ->
          err.should.equal 'wrong_state'
          done()

  it "can't start with less than 2 players", (done) ->
    @game.start (err) =>
      err.should.equal 'not_enough_players'
      async.series [ @join(@u0), @game.start ], (err) ->
        err.should.equal 'not_enough_players'
        done()

  it 'no joining after a game has started', (done) ->
    async.series [ @join(@u0, @u1), @game.start, @join(@u2) ], (err) ->
      err.should.equal 'wrong_state'
      done()

  it 'rollDice sets the current dice roll value', (done) ->
    async.series [@join(@u0, @u1), @game.start, @game.rollDice ], (err) =>
      Should.not.exist err
      @game.dice.should.be.within 1, 6
      done()

  it 'startPiece can start a piece if the dice is 6', (done) ->
    rollSix = (cb) => @game.rollDice (err) =>
      Should.not.exist err
      return cb() if @game.dice == 6
      @game.skip (err, res) =>
        Should.not.exist err
        rollSix cb

    async.series [@join(@u0, @u1, @u2, @u3), @game.start], (err) =>
      Should.not.exist err
      rollSix =>
        player = @game.currentSide
        oldPieces = _.clone @game.board.pieces
        @game.startPiece player, (err) =>
          return done err if err
          newPieces = @game.board.pieces
          diff = []
          for id, piece of newPieces
            if _.isUndefined oldPieces[id]
              diff.push piece
          diff.should.have.length 1
          diff[0].player.should.equal player
          done null


describe 'Game', ->
  userCount = 0
  before (done) ->
    @join = (users...) =>
      f = (u) => (asyncCb) => @game.join u, asyncCb
      doJoins = (cb) -> async.series (f(u) for u in users), cb
      return doJoins users.pop() if _.isFunction _.last users
      doJoins
    @move = (piece, cb) =>
      if _.isUndefined cb
        (cb) => @game.move piece, cb
      else
        @game.move piece, cb
    createUser = (cb) =>
      User.model.create "test-GameModel-#{userCount++}", 'pwd', cb
    async.series [
      createUser, createUser, createUser, createUser, createUser
    ], (err, [@u0, @u1, @u2, @u3, @u4]) =>
      @creator = @u0
      User.model.login @creator.nick, "pwd", done

  after (done) -> User.model.logout done

  describe 'Offline: rule-checks and updates client', ->
    before (done) ->
      Game.model.disableWrappers()
      Game.model.create (err, @game) =>
        _.bindAll @game
        Should.not.exist err
        serialized = @game.serialize()
        @serializedEmptyGame = -> JSON.parse serialized
        done err, @game

    beforeEach (done) ->
      @game.load @serializedEmptyGame(), done

    after -> Game.model.enableWrappers()

    runGameTests()

  describe 'Online: rule-checks and updates on server', ->
    beforeEach (done) ->
      Game.model.create (err, @game) =>
        Should.not.exist err
        _.bindAll @game
        done err
    before (done) ->
      Game.LudoRules.disableWrappers()
      ss.rpc 'dangerous.disableAuthorization', done
    after (done) ->
      Game.LudoRules.enableWrappers()
      ss.rpc 'dangerous.enableAuthorization', done

    runGameTests()

    it 'can create new games with flavor', ->
      flavor = new LudoRules.Flavor({startOnOneAndSix: true})
      Game.model.create flavor.serialize(), (err, game) =>
        game.flavor.startOnOneAndSix.should.equal true

    it 'lists open games, in the order they were created', (done) ->
      Game.model.create (err, game2) =>
        Should.not.exist err
        @game.join @creator, (err) =>
          Should.not.exist err
          game2.join @creator, (err) =>
            Should.not.exist err
            Game.model.listOpenGames (err, openGames) =>
              Should.not.exist err
              openGames.pop().id.should.equal game2.id
              openGames.pop().id.should.equal @game.id
              done()

    describe '- pub/sub event', ->
      it 'joining a game subscribes to, leaving unsubscribes from game pubsub channel', (done) ->
        async.waterfall [
          (cb   ) => @game.join @u0, cb
          (   cb) => ss.rpc 'dangerous.listPubsubChannels', cb
          (l, cb) => l.should.include "game:#{@game.id}"; cb()
          (   cb) => @game.leave @u0, cb
          (   cb) => ss.rpc 'dangerous.listPubsubChannels', cb
          (l, cb) => l.should.not.include "game:#{@game.id}"; cb()
        ], done

      it 'join', (done) ->
        ss.event.once "Game:join:#{@game.id}", ([userId]) =>
          userId.should.equal @u0.id
          done()
        @game.join @u0, (err) => Should.not.exist err

    describe 'Game.model.listGamesOfUser', ->
      it "doesn't return not joined, not created games", (done) ->
        Game.model.listGamesOfUser @u1, (err, games) =>
          Should.not.exist err
          games.should.not.containGame @game
          done()

      it 'returns a game just created', (done) ->
        Game.model.listGamesOfUser @creator, (err, games) =>
          Should.not.exist err
          games.should.containGame @game
          done()

      it 'returns a joined game', (done) ->
        @join @u2, (err) =>
          Should.not.exist err
          Game.model.listGamesOfUser @u2, (err, games) =>
            Should.not.exist err
            games.should.containGame @game
            done()

      it "doesn't return a left game", (done) ->
        @game.join @u3, (err) =>
          Should.not.exist err
          @game.leave @u3, (err) =>
            Should.not.exist err
            Game.model.listGamesOfUser @u3, (err, games) =>
              Should.not.exist err
              games.should.not.containGame games
              done()

