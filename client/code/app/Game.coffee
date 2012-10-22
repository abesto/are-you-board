serialization = require './serialization'
model = require './model'
LudoBoard = require './LudoBoard'

class Game
  constructor: (@id) ->
    @createdAt = new Date()
    @board = null

serialization Game, 1,
  1:
    to: -> [@id, @createdAt.getTime(), @board.toSerializable()]
    from: ([id, createdAt, board]) ->
      g = new Game id
      g.board = LudoBoard.fromSerializable board
      g.createdAt = createdAt
      g

model Game, 'game'

module.exports = Game
