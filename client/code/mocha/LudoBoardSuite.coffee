LudoBoard = require '/LudoBoard'
Path = require '/Path'

chai.Assertion.overwriteMethod 'eql', (_super) -> (other) ->
  if @_obj instanceof LudoBoard and other instanceof LudoBoard
    assertBoardEql @_obj, other
  else if @_obj instanceof LudoBoard.Field and other instanceof LudoBoard.Field
    assertPropertiesEql ['row', 'column', 'piece'], @_obj, other
  else if @_obj instanceof LudoBoard.Piece and other instanceof LudoBoard.Piece
    assertPropertiesEql ['player', 'pathPosition'], @_obj, other
  else
    _super.call this, other

assertBoardEql = (one, other) ->
  for row in [0 ... LudoBoard.ROWS]
    for column in [0 ... LudoBoard.COLUMNS]
      one.row(row).column(column).should.eql other.row(row).column(column)

startingPositions = [
  {
  player: 0
  row: 4
  column: 0
  }, {
  player: 1
  row: 0
  column: 6
  }, {
  player: 2
  row: 6
  column:10
  }, {
  player: 3
  row: 10
  column: 4
  }
]

describe 'LudoBoard', ->

  beforeEach -> @board = new LudoBoard()

  it '#constructor creates an instance', ->
    @board.should.be.an.instanceof LudoBoard

  it 'has 11 rows, 11 columns', ->
    @board.fields.should.have.length 11
    for row in @board.fields
      row.should.have.length 11

  it '#field', ->
    @board.field(row: 1, column: 1).should.equal @board.fields[1][1]
    @board.field(row: 2, column: 2).should.equal @board.fields[2][2]
    @board.field(row: 1, column: 1).should.not.equal @board.fields[2][2]

  it '#row, #column', ->
    @board.row(0).column(0).should.equal @board.field(row: 0, column: 0)
    @board.row(1).column(2).should.equal @board.field(row: 1, column: 2)
    @board.column(2).row(1).should.equal @board.field(row: 1, column: 2)

  it 'each field is initially empty', ->
    for row in [0 ... 11]
      for column in [0 ... 11]
        @board.row(row).column(column).isEmpty().should.be.true

  it 'pieces can be started', ->
    for {player, row, column} in startingPositions
      piece = @board.start(player)
      piece.player.should.equal player
      @board.row(row).column(column).isEmpty().should.be.false
      @board.row(row).column(column).getPiece().getPlayer().should.equal player
      @board.row(row).column(column).getPiece().should.equal piece
      piece.pathPosition.should.equal 0
      @board.hasPiece(piece).should.be.true

  it 'starting pieces create pieces with ids incremented by 1', ->
    position = startingPositions[0]
    for i in [0..3]
      piece = @board.start(0)
      piece.id.should.equal i
      @board.move piece, i

  it 'piece can be removed', ->
    piece = @board.start(0)
    field =  @board.row(4).column(0)
    field.should.equal piece.field
    field.isEmpty().should.be.false
    @board.removePiece(piece)
    field.isEmpty().should.be.true
    Should.not.exist piece.field
    @board.hasPiece(piece).should.be.false

  it 'pieces can be captured', ->
    piece0 = @board.start(0)
    piece1 = @board.start(1)
    @board.move piece0, 10
    @board.hasPiece(piece1).should.be.false
    @board.hasPiece(piece0).should.be.true

  it 'paths are correct', ->
    for player in [0 ... 4]
      startingPosition = _.find startingPositions, (o) -> o.player == player
      expected = new Path
        string: '4r4u2r4d4r2d4l4d2l4u4lu4r'
        rotation: player * 90
        origin:
          row: startingPosition.row
          column: startingPosition.column
      @board.paths[player].should.deep.equal expected

  it 'piece can move a number of fields along the path of its player', ->
    for player in [1 ... 4]
      piece = @board.start player
      pos = _.find startingPositions, (o) -> o.player == player
      field = @board.row(pos.row).column(pos.column)

      piece.move 1, @board
      field.isEmpty().should.be.true
      pos = @board.paths[player][1]
      field = @board.row(pos.row).column(pos.column)
      piece.should.equal field.getPiece()

      piece.move 2, @board
      field.isEmpty().should.be.true
      pos = @board.paths[player][3]
      field = @board.row(pos.row).column(pos.column)
      piece.should.equal field.getPiece()

  it 'serialization format v1', ->
    @board.start 0
    @board.start 1
    serialized = @board.serialize()
    serialized.should.be.a 'string'
    deserialized = LudoBoard.deserialize serialized
    @board.should.deep.equal deserialized
