constants = require './constants'

class Validator
  constructor: (@game) ->

  check: (items...) ->
    for item in items
      return item unless item[0]
    [true]

  start: -> @check(
    [@game.playerCount() >= constants.Game.REQUIRED_PLAYERS, "not_enough_players #{@game.playerCount()} #{constants.Game.REQUIRED_PLAYERS}"],
    [not @game.isStarted(), "wrong_state"])

  join: -> @check(
    [@game.playerCount() < 4, "game_full"],
    [not @game.isStarted(), "wrong_state"])

  rollDice: -> @check [@game.state == constants.Game.STATE_DICE, "wrong_state"]

  startPiece: (side) ->
    board = @game.board
    field = board.field board.startPosition side
    @check(
      [@game.state == constants.Game.STATE_MOVE, "wrong_state"],
      [side == @game.currentSide, "start_not_current_players_piece" ],
      [@game.dice == 6, "dice_not_6"],
      [field.isEmpty() or field.getPiece().player != side, "cant_take_own_piece"])

  move: (piece) ->
    toField = @game.board.field @game.board.paths[piece.player][piece.pathPosition + @game.dice]
    @check(
      [piece.player == @game.currentSide, "move_not_current_players_piece"],
      [toField.isEmpty() or toField.getPiece().player != piece.player, "cant_take_own_piece"])


class LudoRules
  @wrappersDisabled = false
  @disableWrappers = -> LudoRules.wrappersDisabled = true
  @enableWrappers = -> LudoRules.wrappersDisabled = false

  constructor: (@game) ->
    @can = new Validator @game

  @wrap: (cls, methods...) ->
    cls.LudoRules = LudoRules
    for method in methods
      do (method) ->
        original = cls.prototype[method]
        cls.prototype[method] = (args...) ->
          @rule ?= new LudoRules(this)
          if not LudoRules.wrappersDisabled and _.isFunction(@rule.can[method])
            result = @rule.can[method] args...
            unless result[0]
              winston.warn result[1]
              throw new Error("#{method} not allowed: #{result[1]}")
          original.call this, args...


module.exports = LudoRules
