exports.definition = class RectangleBoardDefinition
  constructor: (opts) ->
    @_type = 'boards.rectangle.definition'
    (this[key] = val) for key, val of opts

    @_css ?= {}
    @name ?= 'Rectangle board'

    @__defineGetter__ 'fields', -> @rows * @columns

  _checkRowColumn: (row, column) -> 
    row >= 0 && column >= 0 && row < @rows && column < @columns

  css: (opts) ->
    {row, column} = opts
    idx = "#{row},#{column}"
    return @_css[idx] or {} unless opts.style
    @_css[idx] = opts.style


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

exports.editor = class RectangleBoardEditor
  constructor: (@$previewContainer, @$propertiesContainer) ->

  setBoard: (@board) ->
    @$preview = $('<table>').addClass('rectangle-board')
    @$properties = $('#editor-properties-rectangle').tmpl board:@board

    @$properties.find('.field-color').colorpicker().on 'changeColor', (event) =>
      @css 'background-color': event.color.toHex()

    editor = this
    @$properties.find('input[name=name]').change -> 
      editor.board.name = $(this).val()

    {rows, columns} = @board
    @board.rows = @board.columns = 0
    @addRow() while @board.rows < rows
    @addColumn() while @board.columns < columns

    # Add, remove rows and columns
    for type in ['row', 'column']
      do (type) =>
        $counter = @$properties.find(".#{type}-count")
        for action in ['add', 'delete']
          do (action) =>
            @$properties.find(".#{action}-#{type}").click =>
              this[action + type[0].toUpperCase() + type[1..]]()
              $counter.html @board[type+'s']

    @selecting = false
    @$previewContainer.html @$preview
    @$propertiesContainer.html @$properties

  _makeField: (row, column) -> 
    editor = this
    $field = $("<td data-row=\"#{row}\" data-column=\"#{column}\" class=\"field\"></td>")
      .mousedown (e) ->
        $this = $(this)
        editor.$preview.find('.selected').removeClass 'selected' unless e.ctrlKey
        $this.toggleClass 'selected'
        editor.selecting = true
        false
      .mouseover ->
        $(this).toggleClass 'selected' if editor.selecting
        false
      .mouseup ->
        editor.selecting = false
        false
    css = @board.css {row:row, column:column}
    $field.css css if css
    $field

  addRow: ->
    $row = $('<tr>').attr('data-row', @board.rows).addClass('row')
    $row.append @_makeField @board.rows, column for column in [0...@board.columns]
    @$preview.append $row
    @board.rows++

  addColumn: ->
    editor = this
    @$preview.find('.row').each ->
      $this = $(this)
      $this.append editor._makeField $this.attr('data-row'), editor.board.columns
    @board.columns++ 

  deleteRow: ->
    throw 'Can not delete the last row' if @board.rows == 1
    @$preview.find('.row:last-child').remove()
    @board.rows--

  deleteColumn: ->
    throw 'Can not delete the last column' if @board.columns == 1
    @$preview.find(".field[data-column=#{--@board.columns}]").remove()

  css: (styles) ->
    editor = this
    @$preview.find('.field.selected').each ->
      $this = $(this)
      $this.css styles
      editor.board.css
        row: $this.attr('data-row')
        column: $this.attr('data-column')
        style: styles