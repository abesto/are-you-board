Game = require '/Game'
Repository = require '/Repository'
LudoBoard = require '/LudoBoard'
LudoBoardTableUI = require('./LudoBoardUI').Table

class LudoUI
  @_name = 'LudoUI'

  constructor: (@game) ->
    window.g = @game
    window.l = this
    @rules = new Game.LudoRules(@game)
    @findControls()

  findControls: ->
    @start = $('#start')
    @state = $('#state-text')
    @lastDice = $('#last-dice-value')
    @rollDice = $('#roll-dice')
    @skip = $('#skip')

  updateControls: ->
    myGame = @game.createdBy == window.user.id
    myTurn = @game.players[@game.currentSide] == window.user.id
    @state.text LudoUI.STATE_TEXT[@game.state]
    @start.hide() unless myGame and @rules.can.start()[0]
    @rollDice.toggleClass('disabled', !(myTurn and @rules.can.rollDice()[0]))
    @skip.toggleClass('disabled', !(myTurn and @rules.can.skip()[0]))
    @board.setCurrentPlayer(@game.currentSide)
    @lastDice.text(@game.dice)

  bindControls: ->
    for method in Game.MODEL_METHODS
      continue unless method of this
      do (method) =>
        @game.on method, _.bind(@updateControls, this)
        this[method].click (e) =>
          e.preventDefault()
          return if this[method].hasClass('.disabled')
          @game[method] (err) => alert err if err

    @board.bind 'start', =>
      @game.startPiece (err) => alert err if err
    @game.on 'startPiece', () =>
      @board.start @game.getPreviousSide(), _.last(_.toArray(@game.board.pieces)).id
      @updateControls()

    @board.bind 'move', (e, pieceId) =>
      @game.move @game.board.pieces[pieceId], (err) => alert err if err
    @game.on 'move', (pieceId) =>
      @board.move pieceId, @game.board.pieces[pieceId].field
      @updateControls()

  render: ->
    @board = new LudoBoardTableUI($('#board'))
    @board.render(@game)
    @updateControls()
    @bindControls()
constants.apply LudoUI

module.exports =
  render: (gameId) ->
    Repository.get Game, gameId, (err, game) ->
      return alert err if err
      UI.$container.empty().append ss.tmpl['ludo'].render()
      ludoUi = new LudoUI(game)
      ludoUi.render()

