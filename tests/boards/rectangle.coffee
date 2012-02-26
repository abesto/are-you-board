board = require '../../app/shared/boards/rectangle'

module.exports =
  setUp: (cb) ->
    @definition = new board.definition
      rows: 8
      columns: 8
    @instance = new board.instance @definition
    cb()

  definition:
    'Number of fields is computed and updated correctly':  (test) ->
      test.expect 2
      test.equal 64, @definition.fields
      @definition.rows = 2
      test.equal 16, @definition.fields
      test.done()

  instance:
    'Row and column number is mirrored from definition': (test) ->
      test.expect 6
      test.equal @definition.fields, @instance.fields
      test.equal @definition.rows, @instance.rows
      test.equal @definition.columns, @instance.columns
      @definition.rows = 2
      test.equal @definition.fields, @instance.fields
      test.equal @definition.rows, @instance.rows
      test.equal @definition.columns, @instance.columns
      test.done()

    'All fields are accessible and initially empty':  (test) ->
      test.expect 2 * @instance.fields
      for row in [0 ... @instance.rows]
        for column in [0 ... @instance.columns]
          test.deepEqual [], @instance.field(row, column).getPieces()
          test.ok(@instance.field(row, column).isEmpty())
      test.done()

    'Pieces can be added, other fields are unaffected':  (test) ->
      test.expect 2
      @instance.row(0).column(0).addPiece 'P'
      test.deepEqual ['P'], @instance.row(0).column(0).getPieces()
      test.ok @instance.row(1).column(0).isEmpty()
      test.done()

    'Pieces can be removed, other fields are unaffected':  (test) ->
      test.expect 2
      @instance.field(0,0).addPiece(0)
      @instance.field(0,0).addPiece(1)
      @instance.field(1,1).addPiece(2)
      @instance.field(0,0).removePiece(1)
      test.deepEqual [0], @instance.field(0,0).getPieces()
      test.deepEqual [2], @instance.field(1,1).getPieces()
      test.done()

    'Field can be accessed via both board.field(row, column) and board.row(r).column(c)':  (test) ->
      test.expect 1
      @instance.row(0).column(1).addPiece 'P'
      test.deepEqual ['P'], @instance.field(0, 1).getPieces()
      test.done()

    'Invalid field indices return undefined as field':  (test) ->
      test.expect 4
      test.ok typeof @instance.field(-1, 0) == 'undefined'
      test.ok typeof @instance.field(9, 0) == 'undefined'
      test.ok typeof @instance.field(0, -1) == 'undefined'
      test.ok typeof @instance.field(0, 9) == 'undefined'
      test.done()
