serialization = require './serialization'
LudoBoard = require './LudoBoard'
User = require './User'
LudoRules = require './LudoRules'


class Game
  constructor: (@id) ->
    @createdAt = new Date()
    @createdBy = null
    @board = null
    @players = [null, null, null, null]
    @currentSide = -1
    @dice = 0
    @state = Game.STATE_JOINING

  firstFreeSide: ->
    idx = _.indexOf @players, null
    return if idx == -1
    idx

  userSideS:[TC.Instance(User)]
  userSide: (user) ->
    userInGame = _.find @players, (u) -> u != null and u == user.id
    return if _.isUndefined userInGame
    _.indexOf @players, userInGame

  isUserPlayingS:[TC.Instance(User)]
  isUserPlaying: (user) ->
    not _.isUndefined @userSide user

  playerCount: ->
    (_.filter @players, (o) -> o != null).length

  toString: -> @id

  isStarted: -> @state != Game.STATE_JOINING

  nextSide: ->
    for i in [@currentSide+1 ... @players.length].concat [0 .. @currentSide]
      if @players[i] != null
        return @currentSide = i

  getPieceS:[TC.Number]
  getPiece: (id) -> @board.pieces[id]

  skipS:[TC.Callback]
  skip: (cb) ->
    @state = Game.STATE_DICE
    @nextSide()
    cb? null, this

  moveS:[TC.Instance(LudoBoard.Piece), TC.Callback]
  move: (piece, cb) ->
    @state = Game.STATE_DICE
    piece.move @dice, @board
    @nextSide()
    cb? null, this

  joinS:[TC.Instance(User), TC.Callback]
  join: (user, cb) ->
    idx = @firstFreeSide()
    @players[idx] = user.id
    winston.info "join", @logMeta {user: user.toString()}
    cb? null, this

  leaveS:[TC.Instance(User), TC.Callback]
  leave: (user, cb) ->
    idx = @userSide user
    @players[idx] = null
    winston.info "leave", @logMeta {user: user.toString()}
    cb? null, this

  rollDiceS:[TC.Callback]
  rollDice: (cb) ->
    @dice = 1 + Math.floor(Math.random() * 6)
    winston.debug "rollDice", @logMeta {dice: @dice}
    @state = Game.STATE_MOVE
    cb? null, this

  startS:[TC.Callback]
  start: (cb) ->
    @state = Game.STATE_DICE
    @nextSide()
    cb? null, this

  startPieceS:[TC.Callback]
  startPiece: (cb) ->
    winston.info "startPiece", @logMeta()
    @state = Game.STATE_DICE
    piece = @board.start(@currentSide)
    @nextSide()
    cb? null, this

  logMetaS:[TC.Maybe TC.Object]
  logMeta: (obj={}) ->
    _.defaults obj, {side: @currentSide, user: @players[@currentSide]?.toString(), game: @toString()}


serialization Game, 1,
  1:
    to: -> [
      @id
      @createdAt.getTime()
      @createdBy
      @board.toSerializable()
      @players
      @currentSide
      @dice
      @state
    ]

    from: (game, [id, createdAt, createdBy, board, players, currentSide, dice, state], cb) ->
      game.id = id
      game.createdAt = new Date createdAt
      game.createdBy = createdBy
      game.board = LudoBoard.fromSerializable board
      game.players = players
      game.currentSide = currentSide
      game.dice = dice
      game.state = state
      cb null, game


TypeSafe Game
constants.apply Game
model Game
LudoRules.wrap Game, Game.MODEL_METHODS...

module.exports = Game
