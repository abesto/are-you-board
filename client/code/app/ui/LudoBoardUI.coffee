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
    @shownPathStep = null

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
    $oldShownPathStep = @el.find('span.path-step-label')
    @el.append(piece.el)
    @piece = piece
    @piece.field = this
    @piece.el.append $oldShownPathStep

  clear: ->
    throw "Tried to remove piece from field (#{@row},#{@column}), which is empty" unless @hasAnyPiece()
    @piece.el.detach()
    @piece.field = null
    @piece = null

  getPiece: -> @piece

  showPathStep: (n, byDice=false) ->
    @shownPathStep = n
    return if n == null
    @el.find('span.path-step-label').remove()
    $step = $('<span>').addClass('path-step-label').text(n)
    $step.addClass('by-dice') if byDice
    if @hasAnyPiece()
      @piece.el.append $step
    else
      @el.append $step

  @hidePathSteps: -> $('span.path-step-label').remove()


class NickLabel
  @_name = 'NickLabel'

  constructor: (@table, @topLeft, @player) ->
    @el = @table.getField(@topLeft.row, @topLeft.column).el
    for columnOffset in [-1, 1, 2]
      @table.getField(@topLeft.row, @topLeft.column + columnOffset).el.remove()
    @label = $('<span>').hide()
    @label.addClass('nick').addClass(Table.COLORS[@player])
    @el.attr('colspan': 4, id: "nick-#{@player}").append @label

  setLabel: (label) -> @label.text(label)

  setCurrent: ->
    @table.board.find('.nick.current').removeClass('current')
    @label.addClass('current')

  show: -> @label.css('display', 'inline')


class Piece
  @get: (table, id) ->  table.board.find("div.piece[pieceid=#{id}]").data('uiObject')

  constructor: (@table, @player, show) ->
    @el = $('<div>&nbsp;</div>').addClass('piece').
          addClass(Table.COLORS[player]).
          attr('player': player, 'pieceid': '-1').
          data('uiObject', this)
    @el.hide() unless show
    @attachHandlers()
    @field = null

  getField: -> @field

  getId: -> parseInt @el.attr('pieceid')
  setId: (id) -> @el.attr('pieceid', id)

  getPlayer: -> parseInt @el.attr('player')

  trigger: (args...) -> @table.trigger args...

  nextPathFields: ->
    path = @table.game.board.paths[@player]
    currentIndex = _.indexOf(path, _.find(path, (s) => s.row == @field.row && s.column == @field.column))
    ret = []
    from = currentIndex + 1
    to = if @field in @table.limboFields[@player] then from else Math.min(currentIndex + 6, path.length - 1)
    for i in [from .. to]
      position = path[i]
      ret.push @table.getField position.row, position.column
    ret

  attachHandlers: ->
    @el.click =>
      if @getId() != -1
        @table.logger.debug 'piece_clicked', {pieceId: @getId(), side: @player, triggeredEvent: 'move'}
        @trigger 'move', [@getId()]
      else
        @table.logger.debug 'piece_clicked', {pieceId: @getId(), side: @player, triggeredEvent: 'start'}
        @trigger 'start', [@getPlayer(), @el]
      Field.hidePathSteps()

    showPathSteps = => field.showPathStep(index+1, index+1 == @table.game.dice) for field, index in @nextPathFields()
    @el.hover showPathSteps, Field.hidePathSteps

  show: -> @el.show()


class GhostPiece extends Piece
  constructor: (@table, @player) ->
    super(@table, @player, true)
    @el.addClass('ghost')

  attachHandlers: ->

  @clear: (table) ->
    piece = table.board.find('.ghost').data('uiObject')
    if !_.isUndefined(piece)
      field = piece.getField()
      field.clear()
      table.logger.debug 'removing_ghost_piece', {
        side: piece.player,
        row: field.row, column: field.column
      }


module.exports.Table = class Table
  @_name = 'Table'

  @COLORS = ['red', 'green', 'yellow', 'blue']
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

  render: (@game) ->
    @_createLogger()
    @_createFields()
    @_createNickFields()
    @_createLimboFields()

    for player in [0...4]
      field = @nickFields[player]
      if @game.players[player] != null
        do (field) =>
          Repository.get User, @game.players[player], (err, user) =>
            return alert err if err
            field.setLabel user.nick
            field.show()

      for field in @limboFields[player]
        field.put new Piece(this, player, @game.players[player] != null)

    for id, piece of @game.board.pieces
      uiPiece = @nextLimboFieldWithNonGhostPiece(piece.player).getPiece()
      uiPiece.setId(piece.id)
      @move piece.id, piece.field

    GhostPiece.clear(this)
    @setCurrentPlayer(@game.currentSide)
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
    @_putGhostPiece(side, fromField)

    @logger.info 'start_piece', {
      side: side, id: id,
      fromRow: fromField.row, fromColumn: fromField.column,
      toRow: toField.row, toColumn: toField.column
    }

  move: (pieceId, field) ->
    piece = @getPiece(pieceId)
    fromField = piece.getField()
    toField = @getField(field.row, field.column)

    if toField.hasNonGhostPiece()
      takenPiece = toField.getPiece()
      takenPiecePlayer = toField.getPiece().getPlayer()
      limboField = @nextLimboFieldWithoutAnyPiece(takenPiecePlayer)
      limboField.put new Piece(this, takenPiecePlayer, true)
      toField.clear()

    GhostPiece.clear(this)
    fromField.clear()
    toField.put piece
    @_putGhostPiece(piece.getPlayer(), fromField)

    @logger.info 'move_piece', {
      pieceId: pieceId,
      fromRow: fromField.row, fromColumn: fromField.column,
      toRow: toField.row, toColumn: toField.column,
      capturedPieceId: if _.isUndefined(takenPiece) then null else takenPiece.id,
      capturedPieceSide: if _.isUndefined(takenPiecePlayer) then null else takenPiecePlayer
    }

  join: (side, user) ->
    @nickFields[side].setLabel(user.nick)
    @nickFields[side].show()
    field.getPiece().show() for field in @limboFields[side]
    @logger.info 'player_joined', {side: side, userId: user.id}

  _putGhostPiece: (side, field) ->
    field.put new GhostPiece(this, side)
    @logger.debug 'put_ghost_piece', {side: side, row: field.row, column: field.column}

  _createLogger: ->
    @logPrefix = "Ludo(id=#{@game.id})"
    @logger = winston.getLogger @logPrefix
    @logger.metadataFilters.push (o) =>
      if 'side' of o
        o.user = @game.players[o.side]
        Repository.get(User, o.user, (err, user) -> o.user = user.toString())
        o.side = "Side(id=#{o.side},color=#{Game.SIDE_NAMES[o.side]})"
      o.state += "[#{Game.STATE_NAMES[@game.state]}]" if 'state' of o
      o.currentSide = "Side(id=#{@game.currentSide},color=#{Game.SIDE_NAMES[@game.currentSide]})"
      o.currentUser = @game.players[@game.currentSide]
      Repository.get(User, @game.players[@game.currentSide], (err, user) -> o.currentUser = user.toString())
      return o

  _createFields: ->
    for row in [0 ... LudoBoard.ROWS]
      $row = $('<tr>')
      @fields.push([])
      for column in [0 ... LudoBoard.COLUMNS]
        field = new Field(this, row, column)
        $row.append field.el
        @fields[row].push field
      @board.append $row

  _createNickFields: ->
    rowOffset = [2, 2, -1, -1]
    @nickFields = (new NickLabel(this, {row: Table.LIMBO[i].row + rowOffset[i], column: Table.LIMBO[i].column}, i) for i in [0...4])
  _createLimboFields: -> @limboFields = (@_limboFields(i) for i in [0...4])

  _limboFields: (player) ->
    fields = []
    topLeft = Table.LIMBO[player]
    for row in [topLeft.row, topLeft.row + 1]
      for column in [topLeft.column, topLeft.column + 1]
        fields.push @getField(row, column)
    fields
