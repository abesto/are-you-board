Game = require '/Game'
User = require '/User'
Repository = require '/Repository'
LudoBoard = require '/LudoBoard'
LudoRules = require '/LudoRules'
LudoBoardTableUI = require('./LudoBoardUI').Table
routes = require '/ui/routes'

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
    @lastDice = $('#last-dice-value')
    @rollDice = $('#roll-dice')
    @skip = $('#skip')
    stateIds = [1, 2, 3, 'ui-skip']
    @states = _.zipObject stateIds, ($("#state-container .state[data-state=#{id}]") for id in stateIds)

  setState: (state) ->
    $('.state.active').removeClass('active')
    @states[state].addClass('active')

  updateControls: () ->
    myGame = @game.createdBy == window.user.id
    myTurn = @game.players[@game.currentSide] == window.user.id
    @setState(@game.state)
    @start.toggle myGame and @rules.can.start().valid
    @rollDice.toggleClass('disabled', !(myTurn and @rules.can.rollDice().valid))
    @skip.toggleClass('disabled', !(myTurn and @rules.can.skip().valid))
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
        if method != 'skip'
          gameEventHandler = @updateControls
        else
          gameEventHandler = =>
            @setState 'ui-skip'
            @game.logger.debug 'ui-skip', 'start'
            setTimeout(
              (=> @game.logger.debug 'ui-skip', 'finish'; @updateControls()),
              2000
            )
        @game.on method, gameEventHandler
        this[method].click (e) =>
          e.preventDefault()
          return if this[method].hasClass('disabled')
          @game[method] (err) => @alert err if err

    @board.bind 'start', (e, side) =>
      @game.startPiece side, (err) => @alert err if err
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

exports.bindRoutes = ->
  routes.ludo.matched.add (gameId) ->
    Repository.get Game, gameId, (err, game) ->
      return alert err if err
      UI.$container.empty().append ss.tmpl['ludo'].render()
      throw 'assertion failed: current should be null' unless current == null
      current = new LudoUI(game)
      current.render()

  routes.ludo.switched.add ->
    current?.unbindControls()
    current = null
