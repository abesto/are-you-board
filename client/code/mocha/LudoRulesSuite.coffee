LudoRules = require '/LudoRules'
LudoBoard = require '/LudoBoard'
Game = require '/Game'
User = require '/User'


chai.Assertion.addProperty 'allow', -> @_obj.valid.should.equal true

chai.Assertion.addMethod 'deny', (msg) ->
  @_obj.valid.should.equal false
  @_obj.message.should.equal msg


describe 'LudoRules', ->
  before ->
    Game.model.disableWrappers()
    @user = new User(1)
  after -> Game.model.enableWrappers()

  beforeEach ->
    @game = new Game()
    @game.board = new LudoBoard()
    @rules = new LudoRules @game

  describe 'a new game without players', ->
    it "can't be started", ->
      @rules.can.start().should.deny "not_enough_players"
    it "can be joined", ->
      @rules.can.join(@user).should.allow
    it "doesn't allow any pieces to be started", ->
      for side in [0 ... 4]
        @game.currentSide = side
        @rules.can.startPiece(@game.currentSide).should.deny "wrong_state"

  describe "a new game with 2 players", ->
    beforeEach ->
      @game.players[0] = new User()
      @game.players[1] = new User()

    it "can be started", ->
      @rules.can.start().should.allow
    it "can be joined", ->
      @rules.can.join(@user).should.allow
    it "doesn't allow rolling the dice", ->
      @rules.can.rollDice().should.deny "wrong_state"
    it "doesn't allow any pieces to be started", ->
      for side in [0 ... 4]
        @game.currentSide = side
        @rules.can.startPiece(@game.currentSide).should.deny "wrong_state"

  describe "a new game with 4 players", ->
    beforeEach ->
      @game.players[i] = new User() for i in [0 ... 4]

    it "can be started", ->
      @rules.can.start().should.allow
    it "can't be joined", ->
      @rules.can.join(@user).should.deny "game_full"
    it "doesn't allow rolling the dice", ->
      @rules.can.rollDice().should.deny "wrong_state"
    it "doesn't allow any pieces to be started", ->
      for side in [0 ... 4]
        @game.currentSide = side
        @rules.can.startPiece(@game.currentSide).should.deny "wrong_state"

  describe "a game with 3 players in STATE_DICE", ->
    beforeEach ->
      @game.players[i + 1] = new User() for i in [0 ... 3]
      @game.state = Game.STATE_DICE

    it "can't be started", ->
      @rules.can.start().should.deny "wrong_state"
    it "can't be joined", ->
      @rules.can.join(@user).should.deny "wrong_state"
    it "allows rolling the dice", ->
      @rules.can.rollDice().should.allow
    it "doesn't allow any pieces to be started", ->
      for side in [0 ... 4]
        @game.currentSide = side
        @rules.can.startPiece(@game.currentSide).should.deny "wrong_state"

  describe "a game with 3 players in STATE_MOVE with current side 2", ->
    beforeEach ->
      @game.players[i] = new User() for i in [0 ... 4]
      @game.state = Game.STATE_MOVE
      @game.currentSide = 2

    it "can't be started", ->
      @rules.can.start().should.deny "wrong_state"
    it "can't be joined", ->
      @rules.can.start(@user).should.deny "wrong_state"
    it "doesn't allow rolling the dice", ->
      @rules.can.rollDice().should.deny "wrong_state"

    it "doesn't allow any pieces to be started, except for when the last dice roll was 6", ->
      for dice in [1..5]
        @game.rolled dice
        @rules.can.startPiece(@game.currentSide).should.deny "dice_not_6"
      @game.rolled 6
      @rules.can.startPiece(@game.currentSide).should.allow

    it "doesn't allow starting a piece if doing so would put it on a field occupied by a piece of the same player", ->
      @game.rolled 6
      board = @game.board
      field = board.field(board.startPosition(2))
      field.put new LudoBoard.Piece(2)
      @rules.can.startPiece(@game.currentSide).should.deny "cant_take_own_piece"

    it "allows starting a piece if doing so would put it on a field occupied by a piece of another player", ->
      @game.rolled 6
      board = @game.board
      field = board.field(board.startPosition(2))
      field.put new LudoBoard.Piece(3)
      @rules.can.startPiece(@game.currentSide).should.allow

    it "only allows moving pieces of the current player", ->
      @game.rolled 1
      for side in [0...4]
        piece = new LudoBoard.Piece side
        @game.board.field(@game.board.startPosition(side)).put piece
        res = @rules.can.move(piece)
        if side == 2
          res.should.allow
        else
          res.should.deny "move_not_current_players_piece"

    it "allows moving a piece to take an opposing piece", ->
      @game.rolled 4
      piece = @game.board.start(2)
      @game.board.field(@game.board.paths[2][4]).put new LudoBoard.Piece 3
      @rules.can.move(piece).should.allow

    it "doesn't allow moving a piece to a field with a piece of the same player", ->
      @game.rolled 4
      piece = @game.board.start(2)
      @game.board.field(@game.board.paths[2][4]).put new LudoBoard.Piece 2
      @rules.can.move(piece).should.deny "cant_take_own_piece"

    it "doesn't allow moving past the end of the path", ->
      @game.rolled @game.board.paths[0].length - 1
      piece = @game.board.start(2)
      @game.move piece
      @game.rolled 1
      @game.state = Game.STATE_MOVE
      @game.currentSide = 2
      (=> @game.move piece).should.throw 'move_past_path'

    it "allows skipping iff the current player doesn't have valid moves", ->
      @game.rolled 3
      @rules.can.skip().should.allow
      @game.rolled 6
      @rules.can.skip().should.deny 'valid_move_exists'

      piece0 = @game.board.start(2)
      @game.rolled 3
      @rules.can.skip().should.deny 'valid_move_exists'

    it "doesn't allow starting a new piece if 4 pieces of the player are already in play", ->
      @game.rolled 6
      @game.board.pieceCountOf = -> 4
      @rules.can.startPiece(@game.currentSide).should.deny 'no_more_pieces_to_start'

    it "doesn't allow starting a piece of a non-current player", ->
      @game.rolled 6
      for player in [0, 1, 2, 3]
        continue if player == @game.currentSide
        @rules.can.startPiece(player).should.deny 'move_not_current_players_piece'

    describe "flavors", ->
      it "with startOnOneAndSix it can start a piece iff the dice is 1 or 6", ->
        @game.flavor.startOnOneAndSix = true
        @game.rolled 1
        @rules.can.startPiece(@game.currentSide).should.allow
        @game.rolled 6
        @rules.can.startPiece(@game.currentSide).should.allow
        for dice in [2..5]
          @game.rolled dice
          @rules.can.startPiece(@game.currentSide).should.deny 'dice_not_1_or_6'

      it 'can take on starting field iff takeOnStartingField', ->
        @game.rolled 4
        piece = @game.board.start(2)
        @game.board.field(@game.board.paths[2][4]).put new LudoBoard.Piece 3

        @game.flavor.takeOnStartingField = true
        @rules.can.move(piece).should.allow

        @game.flavor.takeOnStartingField = false
        @rules.can.move(piece).should.deny 'cant_take_on_starting_field'


  describe "action start", ->
    it "throws exception if start is not allowed", ->
      @rules.can.start = -> false
      (=> @game.start()).should.throw("not_enough_players")

