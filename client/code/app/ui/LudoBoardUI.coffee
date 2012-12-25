LudoBoard = require '/LudoBoard'
User = require '/User'
Repository = require '/Repository'
Game = require '/Game'

class Field
  @_name = 'Field'

  @get: (table, row, column) -> table.board.find("td[row=#{row}][column=#{column}]").data('uiObject')

  constructor: (@table, @row, @column) ->
    @el = $('<td>').attr(row: row, column: column)
    @el.data('uiObject', this)
    @_decorateEl()
    @piece = null

  hasAnyPiece: -> @piece != null

  hasNonGhostPiece: -> @piece != null and @piece not instanceof GhostPiece

  _decorateEl: ->
    middle = LudoBoard.LAST_ROW / 2
    if _.any([@row, @column], (n) -> n >= middle - 1 and n <= middle + 1)
      @el.addClass('path')
    if @row == middle
      if @column < middle and @column > 0
        @el.addClass(Table.COLORS[0])
      if @column > middle and @column < LudoBoard.LAST_COLUMN
        @el.addClass(Table.COLORS[2])
    if @column == middle
      if @row < middle and @row > 0
        @el.addClass(Table.COLORS[1])
      if @row > middle and @row < LudoBoard.LAST_ROW
        @el.addClass(Table.COLORS[3])
    if @column == middle and @row == middle
      @el.addClass('black')

  put: (piece) ->
    throw "Tried to add piece to field (#{@row},#{@column}), which is not empty" if @hasAnyPiece()
    throw "Piece #{piece.id} is already on field (#{piece.getField().row},#{piece.getField().row})" if piece.getField()
    @el.append(piece.el)
    @piece = piece
    @piece.field = this

  clear: ->
    throw "Tried to remove piece from field (#{@row},#{@column}), which is empty" unless @hasAnyPiece()
    @piece.el.detach()
    @piece.field = null
    @piece = null

  getPiece: -> @piece


class NickLabel
  @_name = 'NickLabel'

  constructor: (@table, @topLeft, @player) ->
    @el = @table.getField(@topLeft.row, @topLeft.column).el
    @table.getField(@topLeft.row, @topLeft.column + 1).el.remove()
    @el.addClass('nick').attr('colspan': 2, id: "nick-#{@player}")

  setLabel: (label) -> @el.text(label)

  setCurrent: ->
    @table.board.find('.nick.current').removeClass('current')
    @el.addClass('current')


class Piece
  @get: (table, id) ->  table.board.find("div.piece[pieceid=#{id}]").data('uiObject')

  constructor: (@table, @player) ->
    @el = $('<div>&nbsp;</div>').addClass('piece').
          addClass(Table.COLORS[player]).
          attr('player': player, 'pieceid': '-1').
          data('uiObject', this)
    @attachHandlers()
    @field = null

  getField: -> @field

  getId: -> parseInt @el.attr('pieceid')
  setId: (id) -> @el.attr('pieceid', id)

  getPlayer: -> parseInt @el.attr('player')

  trigger: (args...) -> @table.trigger args...

  attachHandlers: ->
    @el.click =>
      if @getId() != -1
        @trigger 'move', [@getId()]
      else
        @trigger 'start', [@getPlayer(), @el]


class GhostPiece extends Piece
  constructor: (@table, @player) ->
    super(@table, @player)
    @el.addClass('ghost')

  attachHandlers: ->

  @clear: (table) -> table.board.find('.ghost').data('uiObject')?.getField().clear()


module.exports.Table = class Table
  @_name = 'Table'

  @COLORS = ['red', 'green', 'blue', 'yellow']
  @LIMBO = [
    {row: 1, column: 1}
    {row: 1, column: 8}
    {row: 8, column: 8}
    {row: 8, column: 1}
  ]

  constructor: (@container) ->
    @board = $('<table>').addClass('ludo-board')
    @fields = []
    @nickFields = []
    @limboFields = []
    @bind = _.bind @board.bind, @board
    @unbind = _.bind @board.unbind, @board
    @trigger = _.bind @board.trigger, @board

  nextLimboFieldWithNonGhostPiece: (player) ->
    _.find @limboFields[player], ((field) -> field.hasNonGhostPiece())
  nextLimboFieldWithoutAnyPiece: (player) ->
    _.find @limboFields[player], ((field) -> !field.hasAnyPiece())

  setCurrentPlayer: (player) -> @nickFields[player].setCurrent() if player != -1

  getField: (row, column) -> @fields[row][column]

  getPiece: (id) -> Piece.get(this, id)

  render: (game) ->
    @_createFields()
    @_createNickFields()
    @_createLimboFields()

    for player in [0...4]
      field = @nickFields[player]
      do (field) ->
        if game.players[player] == null
          field.setLabel gettext('ludo.noPlayer')
        else
          Repository.get User, game.players[player], (err, user) ->
            return alert err if err
            field.setLabel user.nick

      for field in @limboFields[player]
        field.put new Piece(this, player)

    for id, piece of game.board.pieces
      uiPiece = @nextLimboFieldWithNonGhostPiece(piece.player).getPiece()
      uiPiece.setId(piece.id)
      @move piece.id, piece.field

    GhostPiece.clear(this)
    @setCurrentPlayer(game.currentSide)
    @container.empty().append(@board)

  start: (side, id) ->
    fromField = @nextLimboFieldWithNonGhostPiece(side)
    piece = fromField.getPiece()
    toFieldSpec = constants.LudoBoard.START_POSITIONS[side]
    toField = @getField toFieldSpec.row, toFieldSpec.column

    GhostPiece.clear(this)

    piece.setId(id)
    fromField.clear()
    toField.put(piece)
    fromField.put new GhostPiece(this, side)

  move: (pieceId, field) ->
    piece = @getPiece(pieceId)
    fromField = piece.getField()
    toField = @getField(field.row, field.column)

    if toField.hasNonGhostPiece()
      takenPiecePlayer = toField.getPiece().getPlayer()
      limboField = @nextLimboFieldWithoutAnyPiece(takenPiecePlayer)
      limboField.put new Piece(this, takenPiecePlayer)
      toField.clear()

    GhostPiece.clear(this)
    fromField.clear()
    toField.put piece
    fromField.put new GhostPiece(this, piece.getPlayer())

  join: (side, user) ->
    @nickFields[side].setLabel(user.nick)

  _createFields: ->
    for row in [0 ... LudoBoard.ROWS]
      $row = $('<tr>')
      @fields.push([])
      for column in [0 ... LudoBoard.COLUMNS]
        field = new Field(this, row, column)
        $row.append field.el
        @fields[row].push field
      @board.append $row

  _createNickFields: -> @nickFields = (new NickLabel(this, {row: Table.LIMBO[i].row - 1, column: Table.LIMBO[i].column}, i) for i in [0...4])
  _createLimboFields: -> @limboFields = (@_limboFields(i) for i in [0...4])

  _limboFields: (player) ->
    fields = []
    topLeft = Table.LIMBO[player]
    for row in [topLeft.row, topLeft.row + 1]
      for column in [topLeft.column, topLeft.column + 1]
        fields.push @getField(row, column)
    fields

