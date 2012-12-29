constants = require './constants'
serialization = require './serialization'


class Flavor
  @FIELDS = ['takeOnStartingField', 'startOnOneAndSix', 'reRollAfterSix', 'skipAfterRollingThreeSixes']
  constructor: (opts={}) ->
    @takeOnStartingField = opts.takeOnStartingField || true
    @startOnOneAndSix = opts.startOnOneAndSix || false
    @reRollAfterSix = opts.reRollAfterSix || false
    @skipAfterRollingThreeSixes = opts.skipAfterRollingThreeSixes || false


serialization Flavor, 1,
  1:
    to: ->  (this[field] for field in Flavor.FIELDS)

    from: (flavor, args, cb) ->
      for field, id in Flavor.FIELDS
        flavor[field] = args[id]
      cb? null, flavor


class ValidationResult
  constructor: (@valid, @message, @meta={}, moreMeta={}) ->
    _.extend @meta, moreMeta
  @valid: new ValidationResult(true)
  @invalid: (message, meta) -> new ValidationResult false, message, meta


class Validator
  constructor: (@game) ->

  check: (method, items...) ->
    failedCheck = _.find items, (item) => not item.check.call(this)
    return ValidationResult.valid unless failedCheck?
    meta =
      game: @game.toString()
      method: "game.#{method}"
    return ValidationResult.invalid failedCheck.msg.call(this), failedCheck.meta, meta

  start: -> @check 'start',
    {
      check: -> @game.playerCount() >= constants.Game.REQUIRED_PLAYERS
      msg: -> 'not_enough_players'
      meta: actual: @game.playerCount(), minimum: constants.Game.REQUIRED_PLAYERS
    }
    {
      check: -> not @game.isStarted()
      msg: -> 'wrong_state'
      meta: actual: @game.state, expected: constants.Game.STATE_JOINING
    }

  join: (user) -> @check 'join',
    {
      msg: -> 'wrong_state'
      meta: actual: @game.state, expected: constants.Game.STATE_JOINING, user: user.toString()
      check: -> @game.state == constants.Game.STATE_JOINING
    }
    {
      check: -> not @game.isUserPlaying user
      msg: -> 'already_joined'
      meta: user: user.toString()
    }
    {
      check: -> @game.playerCount() < 4
      msg: -> 'game_full'
      meta: user: user.toString()
    }

  rollDice: -> @check 'rollDice',
    {
      check: -> @game.state == constants.Game.STATE_DICE
      msg: -> 'wrong_state'
      meta: expected: constants.Game.STATE_DICE, actual: @game.state
    }

  startPiece: ->
    board = @game.board
    field = board.field board.startPosition @game.currentSide
    @check 'startPiece',
      {
        check: -> @game.state == constants.Game.STATE_MOVE
        msg: -> 'wrong_state'
        meta: expected: constants.Game.STATE_MOVE, actual: @game.state
      }
      {
        check: -> @game.dice == 6 or (@game.flavor.startOnOneAndSix and @game.dice == 1)
        msg: -> if @game.flavor.startOnOneAndSix then 'dice_not_1_or_6' else 'dice_not_6'
      }
      {
        check: -> field.isEmpty() or field.getPiece().player != @game.currentSide
        msg: -> 'cant_take_own_piece'
      }
      {
        check: -> board.pieceCountOf(@game.currentSide) < 4
        msg: -> 'no_more_pieces_to_start'
      }

  move: (piece) ->
    rangeCheck = @check 'move', {
      check: -> @game.board.paths[piece.player].length > piece.pathPosition + @game.dice
      msg: -> 'move_past_path'
    }
    return rangeCheck unless rangeCheck.valid
    toField = @game.board.field @game.board.paths[piece.player][piece.pathPosition + @game.dice]
    @check 'move',
      {
        check: -> @game.state == constants.Game.STATE_MOVE
        msg: -> 'wrong_state'
        meta: expected: constants.Game.STATE_MOVE, actual: @game.state
      }
      {
        check: -> piece.field.board == @game.board
        msg: -> 'piece_from_wrong_game'
      }
      {
        check: -> piece.player == @game.currentSide
        msg: -> "move_not_current_players_piece"
        meta: currentSide: @game.currentSide, pieceSide: piece.player
      }
      {
        check: -> toField.isEmpty() or toField.getPiece().player != piece.player
        msg: -> 'cant_take_own_piece'
      }

  leave: (user) ->
    @check 'leave',
      {
        check: -> not _.isUndefined @game.userSide user
        msg: -> 'leave_not_joined'
      }

  skip: ->
    @check 'skip',
      {
        check: -> @game.state == constants.Game.STATE_MOVE
        msg: -> 'must_roll_dice'
      }
      {
        check: -> not @startPiece(@game.currentSide).valid
        msg: -> 'valid_move_exists'
        meta: move: 'startPiece'
      }
      {
        check: -> not _.any @game.board.pieces, (p) => @move(p).valid
        msg: -> 'valid_move_exists'
        meta: move: 'move'
      }


class LudoRules
  @wrappersDisabled = false
  @disableWrappers = -> LudoRules.wrappersDisabled = true
  @enableWrappers = -> LudoRules.wrappersDisabled = false

  constructor: (@game) ->
    @can = new Validator @game

  check: (method, args) ->
    return ValidationResult.valid if LudoRules.wrappersDisabled or not _.isFunction(@can[method])
    @can[method] args...

  @signalError: (result, args) ->
    winston.warn result.message, result.meta
    if _.isFunction _.last args
      _.last(args)(result.message, null)
    else
      throw new Error("#{result.message}", result.meta)

  @wrap: (cls, methods...) ->
    cls.LudoRules = LudoRules
    for method in methods
      do (method) ->
        cls.prototype[method] = _.wrap cls.prototype[method], (original, args...) ->
          @rule ?= new LudoRules(this)
          result = @rule.check(method, args)
          return LudoRules.signalError(result, args) unless result.valid
          original.apply this, args


module.exports = LudoRules
module.exports.Flavor = Flavor
