constants = require './constants'


class Validator
  constructor: (@game) ->

  check: (method, items...) ->
    for item in items
      continue if item.check.call this
      item.meta ?= {}
      item.meta.game = @game.id
      item.meta.method = "game.#{method}"
      return [false, item.msg, item.meta]
    [true]

  start: -> @check 'start',
    {
      check: -> @game.playerCount() >= constants.Game.REQUIRED_PLAYERS
      msg: 'not_enough_players'
      meta: actual: @game.playerCount(), minimum: constants.Game.REQUIRED_PLAYERS
    }
    {
      check: -> not @game.isStarted()
      msg: 'wrong_state'
      meta: actual: @game.state, expected: constants.Game.STATE_JOINING
    }

  join: (user) -> @check 'join',
    {
      msg: 'wrong_state'
      meta: actual: @game.state, expected: constants.Game.STATE_JOINING, user: user.id
      check: -> @game.state == constants.Game.STATE_JOINING
    }
    {
      check: -> not @game.isUserPlaying user
      msg: 'already_joined'
      meta: user: user.id
    }
    {
      check: -> @game.playerCount() < 4
      msg: 'game_full'
      meta: user: user.id
    }

  rollDice: -> @check 'rollDice',
    {
      check: -> @game.state == constants.Game.STATE_DICE
      msg: 'wrong_state'
      meta: expected: constants.Game.STATE_DICE, actual: @game.state
    }

  startPiece: (side) ->
    board = @game.board
    field = board.field board.startPosition side
    @check 'startPiece',
      {
        check: -> @game.state == constants.Game.STATE_MOVE
        msg: 'wrong_state'
        meta: expected: constants.Game.STATE_MOVE, actual: @game.state
      }
      {
        check: -> side == @game.currentSide
        msg: 'wrong_side'
        meta: expected: @game.side, actual: side
      }
      {
        check: -> @game.dice == 6
        msg: 'dice_not_6'
      }
      {
        check: -> field.isEmpty() or field.getPiece().player != side
        msg: 'cant_take_own_piece'
      }

  move: (piece) ->
    rangeCheck = @check 'move', {
      check: -> @game.board.paths[piece.player].length > piece.pathPosition + @game.dice
      msg: 'move_past_path'
    }
    return rangeCheck unless rangeCheck[0]
    toField = @game.board.field @game.board.paths[piece.player][piece.pathPosition + @game.dice]
    @check 'move',
      {
        check: -> piece.field.board == @game.board
        msg: 'piece_from_wrong_game'
      }
      {
        check: -> piece.player == @game.currentSide
        msg: "move_not_current_players_piece"
        meta: currentSide: @game.currentSide, pieceSide: piece.player
      }
      {
        check: -> toField.isEmpty() or toField.getPiece().player != piece.player
        msg: 'cant_take_own_piece'
      }

  leave: (user) ->
    @check 'leave',
      {
        check: -> not _.isUndefined @game.userSide user
        msg: 'leave_not_joined'
      }

  skip: ->
    @check 'skip',
      {
        check: -> not @startPiece(@game.currentSide)[0]
        msg: 'valid_move_exists'
        meta: move: 'startPiece'
      }
      {
        check: -> not _.any @game.board.pieces, (p) => @move(p)[0]
        msg: 'valid_move_exists'
        meta: move: 'move'
      }


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
            if not result[0]
              winston.warn result[1], result[2]
              if _.isFunction _.last args
                return _.last(args)(result[1], null)
              else
                throw new Error("#{result[1]}", result[2])
          original.apply this, args


module.exports = LudoRules
