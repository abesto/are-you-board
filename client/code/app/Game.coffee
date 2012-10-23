serialization = require './serialization'
model = require './model'
LudoBoard = require './LudoBoard'
User = require './User'


model class Game
  constructor: (@id) ->
    @createdAt = new Date()
    @board = null
    @players = [null, null, null, null]

  join: (user, callback) ->
    ss.rpc 'models.Game.join', @id, user.id, callback

  leave: (user, callback) ->
    ss.rpc 'models.Game.leave', @id, user.id, callback

  userSide: (user) ->
    userInGame = _.find @players, (u) -> u != null and u.id == user.id
    return if _.isUndefined userInGame
    _.indexOf @players, userInGame

  isUserPlaying: (user) ->
    not _.isUndefined @userSide user

  playerCount: ->
    console.log @players
    (_.filter @players, (o) -> o != null).length

  toString: -> @id

serialization Game, 1,
  1:
    to: -> [
      @id
      @createdAt.getTime()
      @board.toSerializable()
      ((if _.isNull(player) then null else player.toSerializable()) for player in @players)
    ]

    from: ([id, createdAt, board, players]) ->
      g = new Game id
      g.createdAt = new Date createdAt
      g.board = LudoBoard.fromSerializable board
      g.players = ((if _.isNull(player) then null else User.fromSerializable player) for player in players)
      g

module.exports = Game
