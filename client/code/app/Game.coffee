serialization = require './serialization'
model = require './model'
LudoBoard = require './LudoBoard'
User = require './User'

class Game
  constructor: (@id) ->
    @createdAt = new Date()
    @board = null
    @players = [null, null, null, null]

  join: (user, callback) ->
    @players.push user
    @save callback

  isUserPlaying: (user) -> user in @players

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
      g.board = LudoBoard.fromSerializable board
      g.createdAt = new Date createdAt
      g.players = ((if _.isNull(player) then null else User.fromSerializable player) for player in players)
      g

model Game, 'game'

module.exports = Game
