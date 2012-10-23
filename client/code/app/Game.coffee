serialization = require './serialization'
model = require './model'
LudoBoard = require './LudoBoard'
User = require './User'


class Game
  constructor: (@id) ->
    @createdAt = new Date()
    @board = null
    @players = [null, null, null, null]
    @currentSide = -1

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

  # Logic for RPC classes; not used on the client
  _nextSide: ->
    for i in [@currentSide+1 ... @players.length].concat [0 .. @currentSide]
      if @players[i] != null
        @currentSide = i
        return


serialization Game, 1,
  1:
    to: -> [
      @id
      @createdAt.getTime()
      @board.toSerializable()
      ((if _.isNull(player) then null else player.toSerializable()) for player in @players)
      @currentSide
    ]

    from: (game, [id, createdAt, board, players, currentSide]) ->
      game.id = id
      game.createdAt = new Date createdAt
      game.board = LudoBoard.fromSerializable board
      game.players = ((if _.isNull(player) then null else User.fromSerializable player) for player in players)
      game.currentSide = currentSide


model Game, 'join', 'leave', 'nextSide'


module.exports = Game
