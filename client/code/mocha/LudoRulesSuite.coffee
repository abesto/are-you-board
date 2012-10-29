LudoRules = require '/LudoRules'
LudoBoard = require '/LudoBoard'
Game = require '/Game'
User = require '/User'


chai.Assertion.addProperty 'allow', -> @_obj[0].should.equal true

chai.Assertion.addMethod 'deny', (msg) ->
  @_obj[0].should.equal false
  @_obj[1].should.equal msg


describe 'LudoRules', ->
  beforeEach ->
    @game = new Game()
    @game.board = new LudoBoard()
    @rules = new LudoRules @game

  describe 'a new game without players', ->
    it "can't be started", ->
      @rules.can.start().should.deny "not_enough_players 0 2"
    it "can be joined", ->
      @rules.can.join().should.allow
    it "doesn't allow any pieces to be started", ->
      for side in [0 ... 4]
        @rules.can.startPiece(side).should.deny "wrong_state"

  describe "a new game with 2 players", ->
    beforeEach ->
      @game.players[0] = new User()
      @game.players[1] = new User()

    it "can be started", ->
      @rules.can.start().should.allow
    it "can be joined", ->
      @rules.can.join().should.allow
    it "doesn't allow rolling the dice", ->
      @rules.can.rollDice().should.deny "wrong_state"
    it "doesn't allow any pieces to be started", ->
      for side in [0 ... 4]
        @rules.can.startPiece(side).should.deny "wrong_state"

  describe "a new game with 4 players", ->
    beforeEach ->
      @game.players[i] = new User() for i in [0 ... 4]

    it "can be started", ->
      @rules.can.start().should.allow
    it "can't be joined", ->
      @rules.can.join().should.deny "game_full"
    it "doesn't allow rolling the dice", ->
      @rules.can.rollDice().should.deny "wrong_state"
    it "doesn't allow any pieces to be started", ->
      for side in [0 ... 4]
        @rules.can.startPiece(side).should.deny "wrong_state"

  describe "a game with 3 players in STATE_DICE", ->
    beforeEach ->
      @game.players[i + 1] = new User() for i in [0 ... 3]
      @game.state = Game.STATE_DICE

    it "can't be started", ->
      @rules.can.start().should.deny "wrong_state"
    it "can't be joined", ->
      @rules.can.join().should.deny "wrong_state"
    it "allows rolling the dice", ->
      @rules.can.rollDice().should.allow
    it "doesn't allow any pieces to be started", ->
      for side in [0 ... 4]
        @rules.can.startPiece(side).should.deny "wrong_state"

  describe "a game with 3 players in STATE_MOVE with current side 2", ->
    beforeEach ->
      @game.players[i] = new User() for i in [0 ... 4]
      @game.state = Game.STATE_MOVE
      @game.currentSide = 2

    it "can't be started", ->
      @rules.can.start().should.deny "wrong_state"
    it "can't be joined", ->
      @rules.can.start().should.deny "wrong_state"
    it "doesn't allow rolling the dice", ->
      @rules.can.rollDice().should.deny "wrong_state"

    it "doesn't allow any pieces to be started, except for side 2 when the last dice roll was 6", ->
      for side in [0,1,3]
        @rules.can.startPiece(side).should.deny "start_not_current_players_piece"
      for dice in [1..5]
        @game.dice = dice
        @rules.can.startPiece(2).should.deny "dice_not_6"
      @game.dice = 6
      @rules.can.startPiece(2).should.allow

    it "doesn't allow starting a piece if doing so would put it on a field occupied by a piece of the same player", ->
      @game.dice = 6
      board = @game.board
      field = board.field(board.startPosition(2))
      field.put new LudoBoard.Piece(2)
      @rules.can.startPiece(2).should.deny "cant_take_own_piece"

    it "allows starting a piece if doing so would put it on a field occupied by a piece of another player", ->
      @game.dice = 6
      board = @game.board
      field = board.field(board.startPosition(2))
      field.put new LudoBoard.Piece(3)
      @rules.can.startPiece(2).should.allow

    it "only allows moving pieces of the current player", ->
      @game.dice = 1
      for side in [0...4]
        piece = new LudoBoard.Piece side
        @game.board.field(@game.board.startPosition(side)).put piece
        res = @rules.can.move(piece)
        if side == 2
          res.should.allow
        else
          res.should.deny "move_not_current_players_piece"

    it "allows moving a piece to take an opposing piece", ->
      @game.dice = 4
      piece = @game.board.start(2)
      @game.board.field(@game.board.paths[2][4]).put new LudoBoard.Piece 3
      @rules.can.move(piece).should.allow

    it "doesn't allow moving a piece to a field with a piece of the same player", ->
      @game.dice = 4
      piece = @game.board.start(2)
      @game.board.field(@game.board.paths[2][4]).put new LudoBoard.Piece 2
      @rules.can.move(piece).should.deny "cant_take_own_piece"


  describe "action start", ->
    it "throws exception if start is not allowed", ->
      @rules.can.start = -> false
      (=> @game.start()).should.throw("start not allowed: not_enough_players 0 2")
