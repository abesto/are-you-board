Game = require '/Game'
User = require '/User'
Repository = require '/Repository'
LudoBoard = require '/LudoBoard'
LudoRules = require '/LudoRules'
LudoBoardTableUI = require('./LudoBoardUI').Table

class LudoUI
  @_name = 'LudoUI'

  constructor: (@game) ->
    window.g = @game
    window.l = this
    @rules = new Game.LudoRules(@game)
    @findControls()
    for method in ['updateControls', 'startHandler', 'moveHandler']
      this[method] = _.bind(this[method], this)

  findControls: ->
    @start = $('#start')
    @state = $('#state-text')
    @lastDice = $('#last-dice-value')
    @rollDice = $('#roll-dice')
    @skip = $('#skip')

  updateControls: ->
    myGame = @game.createdBy == window.user.id
    myTurn = @game.players[@game.currentSide] == window.user.id
    @state.text gettext LudoUI.STATE_TEXT[@game.state]
    @start.toggle myGame and @rules.can.start()[0]
    @rollDice.toggleClass('disabled', !(myTurn and @rules.can.rollDice()[0]))
    @skip.toggleClass('disabled', !(myTurn and @rules.can.skip()[0]))
    @board.setCurrentPlayer(@game.currentSide)
    @lastDice.text(@game.dice)

  startHandler: ->
    @board.start @game.getPreviousSide(), _.last(_.toArray(@game.board.pieces)).id
    @updateControls()

  moveHandler: (pieceId) ->
    @board.move pieceId, @game.board.pieces[pieceId].field
    @updateControls()

  bindControls: ->
    for method in Game.MODEL_METHODS
      continue unless method of this
      do (method) =>
        @game.on method, @updateControls
        this[method].click (e) =>
          e.preventDefault()
          return if this[method].hasClass('disabled')
          @game[method] (err) => @alert err if err

    @board.bind 'start', =>
      @game.startPiece (err) => @alert err if err
    @game.on 'startPiece', @startHandler

    @board.bind 'move', (e, pieceId) =>
      @game.move @game.board.pieces[pieceId], (err) => @alert err if err
    @game.on 'move', @moveHandler

    @game.on 'join', ([userId]) =>
      Repository.get User, userId, (err, user) =>
        @alert err if err
        @board.join @game.userSide(user), user
        @updateControls()

  unbindControls: ->
    for method in Game.MODEL_METHODS
      continue unless method of this
      @game.off method, @updateControls
      this[method].unbind()

    @board.unbind('start')
    @game.off 'startPiece', @startHandler

    @board.unbind('move')
    @game.off 'move', @moveHandler

  alert: (err) -> alert gettext "ludo.error.#{err}"

  displayRules: ->
    $rules = $('#rules')
    for field in LudoRules.Flavor.FIELDS
      trans = "ludo.rules.#{field}.#{if @game.flavor[field] then 'on' else 'off'}"
      $rules.append $('<li>').attr('data-trans', trans) if gettext(trans).length

  render: ->
    @board = new LudoBoardTableUI($('#board'))
    @board.render(@game)
    @displayRules()
    @updateControls()
    @bindControls()
constants.apply LudoUI

current = null
self = module.exports =
  render: (gameId) ->
    Repository.get Game, gameId, (err, game) ->
      return alert err if err
      UI.$container.empty().append ss.tmpl['ludo'].render()
      throw 'assertion failed: current should be null' unless current == null
      current = new LudoUI(game)
      current.render()
      setCurrentView self

  destroy: ->
    current.unbindControls()
    current = null
