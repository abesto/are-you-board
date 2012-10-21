LudoBoard = require '/LudoBoard'
Path = require '/Path'

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

QUnit.module 'LudoBoard',
  setup: ->
    @board = new LudoBoard()

test 'constructor creates an instance', ->
  ok @board instanceof LudoBoard

test 'has 11 rows, 11 columns', ->
  strictEqual @board.fields.length, 11
  for row in @board.fields
    strictEqual row.length, 11

test 'fields can be accessed via the field method', ->
  strictEqual @board.field(row: 1, column: 1), @board.fields[1][1]
  strictEqual @board.field(row: 2, column: 2), @board.fields[2][2]
  notEqual @board.field(row: 1, column: 1), @board.fields[2][2]

test 'row, column methods can be used to access fields', ->
  strictEqual @board.row(0).column(0), @board.field(row: 0, column: 0)
  strictEqual @board.row(1).column(2), @board.field(row: 1, column: 2)
  strictEqual @board.column(2).row(1), @board.field(row: 1, column: 2)

test 'each field is initially empty', ->
  ((ok @board.row(row).column(column).isEmpty() for column in [0 ... 11]) for row in [0 ... 11])

test 'pieces can be started', ->
  for {player, row, column} in startingPositions
    strictEqual @board.start(player).player, player
    ok !@board.row(row).column(column).isEmpty()
    strictEqual @board.row(row).column(column).getPiece().getPlayer(), player

test 'piece can be removed', ->
  @board.start(0)
  field =  @board.row(4).column(0)
  ok !field.isEmpty()
  field.removePiece()
  ok field.isEmpty()

test 'paths are correct', ->
  for player in [0 ... 4]
    startingPosition = _.find startingPositions, (o) -> o.player == player
    expected = new Path
      string: '4r4u2r4d4r2d4l4d2l4u4lu4r'
      rotation: player * 90
      origin:
        row: startingPosition.row
        column: startingPosition.column
    deepEqual _.toArray(@board.paths[player]), _.toArray(expected)

test 'piece can move a number of fields along the path of its player', ->
  for player in [1 ... 4]
    piece = @board.start player
    pos = _.find startingPositions, (o) -> o.player == player
    field = @board.row(pos.row).column(pos.column)

    piece.move(1)
    ok field.isEmpty()
    pos = @board.paths[player][1]
    field = @board.row(pos.row).column(pos.column)
    strictEqual piece, field.getPiece()

    piece.move(2)
    ok field.isEmpty()
    pos = @board.paths[player][3]
    field = @board.row(pos.row).column(pos.column)
    strictEqual piece, field.getPiece()

test 'serialization format v1', ->
  @board.start 0
  @board.start 1
  serialized = @board.serialize()
  ok _.isString serialized
  deserialized = LudoBoard.deserialize serialized
  deepEqual @board, deserialized
