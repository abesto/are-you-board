LudoBoard = require '/LudoBoard'
User = require '/User'
Repository = require '/Repository'

module.exports.Table = class Table
  @COLORS = ['red', 'green', 'blue', 'yellow']
  @LIMBO = [
    {row: 1, column: 1}
    {row: 1, column: 8}
    {row: 8, column: 8}
    {row: 8, column: 1}
  ]

  constructor: (@$container) ->

  decorateField: ($field, row, column) ->
    middle = LudoBoard.LAST_ROW / 2
    if _.any([row, column], (n) -> n >= middle - 1 and n <= middle + 1)
      $field.addClass('path')
    if row == middle
      if column < middle and column > 0
        $field.addClass(Table.COLORS[0])
      if column > middle and column < LudoBoard.LAST_COLUMN
        $field.addClass(Table.COLORS[2])
    if column == middle
      if row < middle and row > 0
        $field.addClass(Table.COLORS[1])
      if row > middle and row < LudoBoard.LAST_ROW
        $field.addClass(Table.COLORS[3])
    if column == middle and row == middle
      $field.addClass('black')

  getField: (row, column) -> @$table.find("td[row=#{row}][column=#{column}]")

  getNickField: (player) ->
    return $() if player < 0 or player >= Table.LIMBO.length
    limbo = Table.LIMBO[player]
    return @getField(limbo.row - 1, limbo.column)

  getPiece: (id) -> @$table.find("div.piece[pieceId=#{id}]")

  newPiece: (player, row, column) ->
    $piece = $('<div>&nbsp;</div>').addClass('piece').
             addClass(Table.COLORS[player]).
             attr('player': player, 'pieceid': '-1')
    @getField(row, column).empty().append($piece)
    $piece

  addPieceHandlers: ($piece) ->
    $piece.click =>
      if $piece.attr('pieceid') != '-1'
        @trigger 'move', [$piece.attr('pieceid')]
      else
        @trigger 'start', [$piece.attr('player'), $piece]

  nextLimboField: (player) ->
    topLeft = Table.LIMBO[player]
    for row in [topLeft.row, topLeft.row + 1]
      for column in [topLeft.column, topLeft.column + 1]
        return {row: row, column: column} if @getField(row, column).children().length == 0
    throw "No empty limbo field for player #{player}"

  setCurrentPlayer: (player) ->
    @$table.find('.nick.current').removeClass('current')
    @getNickField(player).addClass('current')

  render: (game) ->
    @$table = $table = $('<table>').addClass('ludo-board')
    @bind = _.bind $table.bind, $table
    @unbind = _.bind $table.unbind, $table
    @trigger = _.bind $table.trigger, $table
    for row in [0 ... LudoBoard.ROWS]
      $row = $('<tr>')
      for column in [0 ... LudoBoard.COLUMNS]
        $field = $('<td>&nbsp;</td>').attr(row: row, column: column)
        @decorateField $field, row, column
        $row.append $field
      $table.append $row
    for topleft, player in Table.LIMBO
      $field = @getNickField(player).attr(colspan: 2, id: "nick-#{player}").
               addClass('nick')
      do ($field) ->
        if game.players[player] == null
          $field.text gettext 'ludo.noPlayer'
        else
          Repository.get User, game.players[player], (err, user) ->
            return alert err if err
            $field.text user.nick
      @getField(topleft.row-1, topleft.column+1).remove()
      for row in [topleft.row, topleft.row + 1]
        for column in [topleft.column, topleft.column + 1]
          @addPieceHandlers @newPiece player, row, column
    @setCurrentPlayer(game.currentSide)
    @$container.empty().append($table)
    for id, piece of game.board.pieces
      @start piece.player, piece.id, false
      @move piece.id, piece.field unless piece.pathPosition == 0
    $('.ghost').remove()

  start: (side, id, movePieceEl = true) ->
    topleft = Table.LIMBO[side]
    for row in [topleft.row, topleft.row + 1]
      for column in [topleft.column, topleft.column + 1]
        $piece = @getField(row, column).find('div.piece')
        break if $piece.length > 0
      break if $piece.length > 0
    field = constants.LudoBoard.START_POSITIONS[side]
    $piece.attr('pieceid', id)
    $piece.detach().appendTo(@getField(field.row, field.column).empty()) if movePieceEl

  move: (pieceId, field) ->
    $piece = @getPiece(pieceId)
    $fromField = $piece.parent()
    $toField = @getField(field.row, field.column)
    if $toField.children('.piece:not(.ghost)').length > 0
      takenPiecePlayer = $toField.children().attr('player')
      limboField = @nextLimboField(takenPiecePlayer)
      @newPiece(takenPiecePlayer, limboField.row, limboField.column)
    $piece.detach().appendTo($toField.empty())
    $('.piece.ghost').remove()
    @newPiece($piece.attr('player'), $fromField.attr('row'), $fromField.attr('column')).addClass('ghost')
