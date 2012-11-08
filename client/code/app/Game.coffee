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

  userSide: (user) ->
    userInGame = _.find @players, (u) -> u != null and u.id == user.id
    return if _.isUndefined userInGame
    _.indexOf @players, userInGame

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

  getPiece: (id) -> @board.pieces[id]

  skip: (cb) ->
    @state = Game.STATE_DICE
    @nextSide()
    cb? null, this

  move: (piece, cb) ->
    @state = Game.STATE_DICE
    piece.move @dice, @board
    @nextSide()
    cb? null, this

  join: (user, cb) ->
    idx = @firstFreeSide()
    @players[idx] = user
    winston.info "join", @logMeta {user: user.toString()}
    cb? null, this

  leave: (user, cb) ->
    idx = @userSide user
    @players[idx] = null
    winston.info "leave", @logMeta {user: user.toString()}
    cb? null, this

  rollDice: (cb) ->
    @dice = 1 + Math.floor(Math.random() * 6)
    winston.debug "rollDice", @logMeta {dice: @dice}
    @state = Game.STATE_MOVE
    cb? null, this

  start: (cb) ->
    @state = Game.STATE_DICE
    @nextSide()
    cb? null, this

  startPiece: (cb) ->
    winston.info "startPiece", @logMeta()
    @state = Game.STATE_DICE
    @nextSide()
    cb null, @board.start(@currentSide)

  logMeta: (obj={}) ->
    _.defaults obj, {side: @currentSide, user: @players[@currentSide]?.toString(), game: @toString()}


serialization Game, 1,
  1:
    to: -> [
      @id
      @createdAt.getTime(),
      @createdBy.id,
      @board.toSerializable()
      ((if _.isNull(player) then null else player.id) for player in @players)
      @currentSide
      @dice
      @state
    ]

    from: (game, [id, createdAt, createdBy, board, players, currentSide, dice, state], cb) ->
      game.id = id
      game.createdAt = new Date createdAt
      game.board = LudoBoard.fromSerializable board
      game.currentSide = currentSide
      game.dice = dice
      game.state = state

      getters = [(cb) -> User.model.get createdBy, cb]
      for player in players
        do (player) ->
          if _.isNull player
            getters.push (cb) -> cb null, null
          else
            getters.push (cb) -> User.model.get player, cb

      async.parallel getters, (err, players) ->
        return cb err if err
        game.createdBy = players.shift()
        game.players = players
        cb null, game


constants.apply Game
model Game
LudoRules.wrap Game, Game.MODEL_METHODS...

module.exports = Game
