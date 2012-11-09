Path = require './Path'
serialization = require './serialization'

class Piece
  constructor: (@player, @id) ->
    @field = null
    @pathPosition = 0

  getPlayer: -> @player
  isOnBoard: -> @field != null
  setField: (f) ->
    @field = f

  move: (n, board) ->
    throw new Error("Piece#move must be called with board as the second argument") unless board == @field.board
    @pathPosition += n
    newField = @field.board.field @field.board.paths[@player][@pathPosition]
    @field.removePiece()
    @setField null
    newField.put this

  remove: -> @field.removePiece()


serialization Piece, 1,
  1:
    to: -> [@id, @player, @pathPosition]
    from: (piece, [id, player, pathPosition]) ->
      piece.id = id
      piece.player = player
      piece.pathPosition = pathPosition


class Field
  constructor: (@board, @row, @column) ->
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

serialization Field, 1,
  1:
    to: ->
      throw "You really don't want to serialize an empty field" if @isEmpty()
      [@row, @column, @piece.toSerializable()]

    from: (field, [row, column, piece], board) ->
      for f in ['row', 'column', 'board']
        field[f] = eval f
      field.put Piece.fromSerializable piece


class Index
  @ROW = 0
  @COLUMN = 1

  constructor: (@board, @index, @type) ->

  row: (subindex) ->
    throw 'Called row on a row index' if @type == Index.ROW
    @board.field(row: subindex, column: @index)

  column: (subindex) ->
    throw 'Called column on a column index' if @type == Index.COLUMN
    @board.field(row: @index, column: subindex)


class LudoBoard
  @SERIALIZATION_FORMAT = 1

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
      (new Field(this, row, column) for column in [0 ... LudoBoard.COLUMNS]) \
      for row in [0 ... LudoBoard.ROWS]
    )
    @pieces = {}
    @buildPaths()
    @pieceCount = 0

  buildPaths: ->
    @paths = []
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
    piece = new Piece(player, @pieceCount++)
    @row(row).column(column).put piece
    @pieces[piece.id] = piece
    piece

  removePiece: (piece) ->
    piece.remove()
    delete @pieces[piece.id]

  startPosition: (player) -> _.find(LudoBoard.START_POSITIONS, (o) -> o.player == player)

  move: (piece, steps) ->
    throw new Error("Piece doesn't belong to this board") unless piece.field.board == this
    piece.move steps


serialization LudoBoard, 1,
  1:
    to: -> (field.toSerializable(1) for field in _.flatten @fields when not field.isEmpty())
    from: (board, fields) ->
      board.pieceCount = 0
      for fieldObj in fields
        field = Field.fromSerializable fieldObj, this
        board.fields[field.row][field.column] = field
        unless field.isEmpty()
          piece = field.getPiece()
          board.pieces[piece.id] = piece
          board.pieceCount = Math.max board.pieceCount, piece.id + 1


module.exports = LudoBoard
module.exports.Field = Field
module.exports.Piece = Piece
