serialization = require './serialization'
model = require './model'
LudoBoard = require './LudoBoard'

class Game
  constructor: (@id, @board) ->
    @createdAt = new Date()

serialization Game, 1,
  1:
    to: -> [@id, @createdAt.getTime(), @board.toSerializable()]
    from: ([id, createdAt, board]) ->
      board = LudoBoard.fromSerializable board
      g = new Game id, board
      g.createdAt = createdAt
      g

model Game, 'game'

module.exports = Game
