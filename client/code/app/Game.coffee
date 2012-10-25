serialization = require './serialization'
LudoBoard = require './LudoBoard'
User = require './User'


class Game
  @STATE_JOINING = 1
  @STATE_DICE = 2
  @STATE_MOVE = 3

  constructor: (@id) ->
    @createdAt = new Date()
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

serialization Game, 1,
  1:
    to: -> [
      @id
      @createdAt.getTime()
      @board.toSerializable()
      ((if _.isNull(player) then null else player.toSerializable()) for player in @players)
      @currentSide
      @dice
      @state
    ]

    from: (game, [id, createdAt, board, players, currentSide, dice, state]) ->
      game.id = id
      game.createdAt = new Date createdAt
      game.board = LudoBoard.fromSerializable board
      game.players = ((if _.isNull(player) then null else User.fromSerializable player) for player in players)
      game.currentSide = currentSide
      game.dice = dice
      game.state = state


model Game, 'join', 'leave', 'nextSide', 'start', 'rollDice', 'move'


module.exports = Game
