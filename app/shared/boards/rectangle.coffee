exports.definition = class RectangleBoardDefinition
  constructor: ({rows: @rows, columns: @columns}) ->
    @_type = 'boards.rectangle.definition'
    @__defineGetter__ 'fields', -> @rows * @columns
    @css = {}

  _checkRowColumn: (row, column) -> row >= 0 && column >= 0 && row < @rows && column < @columns

  css: ({row, column, style}) ->
    idx = "#{row},#{column}"
    throw "row,col index (#{idx}}) out of bounds" unless @_checkRowColumn(row, column)
    return @css[idx] unless style
    @css[idx] = style


class RectangleField
  constructor: (@board, @row, @column) ->
    @_pieces = []

  addPiece: (piece) -> @_pieces.push piece
  removePiece: (piece) -> @_pieces.splice i, 1 if (i = @_pieces.indexOf(piece)) > -1
  isEmpty: -> @_pieces.length == 0
  getPieces: -> @_pieces

exports.instance = class RectangleBoardInstance
  constructor: (@definition) ->
    @_fields = {}
    # Getters mirrored from definition for convenience
    @__defineGetter__ 'rows', -> @definition.rows
    @__defineGetter__ 'columns', -> @definition.columns
    @__defineGetter__ 'fields', -> @definition.fields

  row: (r) -> {column: (c) => @field(r, c)}
  column: (c) -> {row: (r) => @field(r, c)}

  field: (r, c) ->
    if not @definition._checkRowColumn(r,c) then return undefined
    key = "#{r},#{c}"
    if key not of @_fields then @_fields[key] = new RectangleField(this, r, c)
    @_fields[key]
