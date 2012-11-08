Authorization = require '../authorization'
User = require '../../client/code/app/User'
Game = require '../../client/code/app/Game'

chai.Assertion.addProperty 'allow', -> @_obj[0].should.equal true

chai.Assertion.addMethod 'deny', (msg) ->
  @_obj[0].should.equal false
  @_obj[1].should.equal msg


describe 'Authorization checks', ->
  before ->
    @rpcStub = sinon.stub ss, 'rpc'
    @req = session: {}
    @authorization = new Authorization @req
    @a = _.bind @authorization.check, @authorization

  describe 'Without login', ->
    for method in Game.MODEL_METHODS
      it "can't #{method}", ->
        @a("Game.#{method}").should.deny 'not_logged_in'


  describe "Normal user", ->
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
      @a('Game.start', {createdBy: 1})

    for method in ['rollDice', 'move', 'skip', 'startPiece']
      it "can #{method} in a joined game", ->
        @a("Game.#{method}", {isUserPlaying: -> true}).should.allow

      it "can't #{method} in a not joined game", ->
        @a("Game.#{method}", {isUserPlaying: -> false}).should.deny 'not_in_game'

