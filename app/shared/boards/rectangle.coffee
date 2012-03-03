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

exports.editor = (definition, $container) ->
  $html = $('<table>').addClass('rectangle-board')

  makeField = (row, column) -> "<td data-row=\"#{row}\" data-column=\"#{column}\" class=\"field\"></td>"

  actions =
    addRow: (viewOnly=false) ->
      $row = $('<tr>').attr('data-row', definition.rows).addClass('row')
      $row.append (makeField definition.rows, column for column in [0...definition.columns]).join('')
      $html.append $row
      definition.rows++ unless viewOnly

    addColumn: (viewOnly=false) ->
      $html.find('.row').each ->
        $(this).append(makeField $(this).attr('data-row'), definition.columns)
      definition.columns++ unless viewOnly

    deleteRow: ->
      throw 'Can not delete the last row' if definition.rows == 1
      $html.find('.row:last-child').remove()
      definition.rows--

    deleteColumn: ->
      throw 'Can not delete the last column' if definition.columns == 1
      $html.find(".field[data-column=#{--definition.columns}]").remove()
      definition.columns--

  actions.addRow true for row in [0...definition.rows]

  $container.html $html

  window.e = actions
