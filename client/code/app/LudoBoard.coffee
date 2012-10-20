Path = require '/Path'

class Piece
  constructor: (player) ->
    @player = player
    @field = null
    @pathPosition = 0

  getPlayer: -> @player
  isOnBoard: -> @field != null
  setField: (f) -> @field = f

  move: (n) ->
    @pathPosition += n
    newField = @field.board.field @field.board.paths[@player][@pathPosition]
    @field.removePiece()
    @setField null
    newField.put this


class Field
  constructor: (board) ->
    @board = board
    @piece = null

  isEmpty: -> @piece == null

  put: (piece) ->
    throw 'Tried to put a piece on an empty field' unless @isEmpty()
    throw 'Tried to place a piece that\'s already on another field' if piece.isOnBoard()
    @piece = piece
    @piece.setField this

  removePiece: ->
    @piece.setField null
    @piece = null

  getPiece: -> @piece


class Index
  @ROW = 0
  @COLUMN = 1

  constructor: (board, index, type) ->
    @board = board
    @index = index
    @type = type

  row: (subindex) ->
    throw 'Called row on a row index' if @type == Index.ROW
    @board.field(row: subindex, column: @index)

  column: (subindex) ->
    throw 'Called column on a column index' if @type == Index.COLUMN
    @board.field(row: @index, column: subindex)


class LudoBoard
  @ROWS = 11
  @COLUMNS = 11
  @LAST_ROW = 10
  @LAST_COLUMN = 10

  @START_POSITIONS: [
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

  constructor: ->
    @fields = (
      (new Field(this) for column in [0 ... LudoBoard.COLUMNS]) \
      for row in [0 ... LudoBoard.ROWS]
    )
    @paths = []
    @buildPaths()

  buildPaths: ->
    for player in [0 ... 4]
      {row, column} = @startPosition player
      @paths.push new Path
        origin:
          row: row
          column: column
        string: '4r4u2r4d4r2d4l4d2l4u4lu4r'
        rotation: 90 * player

  field: ({row, column}) -> @fields[row][column]

  row: (index) -> new Index(this, index, Index.ROW)
  column: (index) -> new Index(this, index, Index.COLUMN)

  start: (player) ->
    {row:row, column:column} = @startPosition player
    piece = new Piece(player)
    @row(row).column(column).put piece
    piece

  startPosition: (player) -> _.find(LudoBoard.START_POSITIONS, (o) -> o.player == player)


module.exports = LudoBoard