Authorization = require '../authorization'
User = require '../../client/code/app/User'
Game = require '../../client/code/app/Game'

chai.Assertion.addProperty 'allow', ->
  should.not.exist @_obj[1]
  @_obj[0].should.equal true

chai.Assertion.addMethod 'deny', (msg) ->
  @_obj[0].should.equal false
  @_obj[1].should.equal msg


describe 'Authorization checks that', ->
  before ->
    @req = session: {}
    @authorization = new Authorization @req
    @a = _.bind @authorization.check, @authorization

  describe 'without login', ->
    for method in Game.MODEL_METHODS
      it "can't #{method}", ->
        @a("Game.#{method}").should.deny 'not_logged_in'


  describe "normal user", ->
    before ->
      @req.session.userId = 1

    it "can create new game", ->
      @a('Game.create').should.allow

    it "can join a game", ->
      @a('Game.join', {id:1}).should.allow

    it "can't make another player join a game", ->
      @a('Game.join', {id:2}).should.deny 'wrong_user'

    it "can leave a game", ->
      @a('Game.leave', {id:1}).should.allow

    it "can't make another player leave a game", ->
      @a('Game.leave', {id:2}).should.deny 'wrong_user'

    it "can start a game s/he created earlier", ->
      @a('Game.start', {createdBy: 1}).should.allow

    it "can't start a game created by another player", ->
      @a('Game.start', {createdBy: 2}).should.deny 'not_owner'

  describe "normal player who hasn't joined the game", ->
    before ->
      @req.session.userId = 1
      @game = isUserIdPlaying: -> false


    for method in ['rollDice', 'skip', 'startPiece', 'move']
      it "can't #{method}", ->
        @a("Game.#{method}", @game).should.deny 'not_in_game'

  describe "normal player who has joined the game, but isn't the current player", ->
    before ->
      @req.session.userId = 1
      @game = {isUserIdPlaying: (-> true), currentSide: 0, players: [{id:2}]}

    for method in ['rollDice', 'skip', 'startPiece', 'move']
      it "can't #{method}", ->
        @a("Game.#{method}", @game).should.deny 'not_current_player'

  describe "normal player who has joined the game and is the current player", ->
    before ->
      @req.session.userId = 1
      @game = {isUserIdPlaying: (-> true), currentSide: 0, players: [{id:1}]}

    for method in ['rollDice', 'skip', 'startPiece']
      it "can #{method} ", ->
        @a("Game.#{method}", @game, {player: 1}).should.allow

    it "can move own piece", ->
      @a("Game.move", @game, {player: 1}).should.allow

    it "can't move another players piece", ->
      @a("Game.move", @game, {player: 2}).should.deny 'not_own_piece'

