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
    idx = _.indexOf @players, null
    if idx == -1
      winston.warn "game_full #{@id} #{user.id}"
      return callback 'game_full'
    @players[idx] = user
    @save (err, res) =>
      winston.info "join #{@id} #{user.id}"
      callback err, res

  leave: (user, callback) ->
    idx = _.indexOf @players, user
    if idx == -1
      winston.warn "leave_not_joined #{@id} #{user.id}"
      return callback 'leave_not_joined'
    @players[idx] = null
    @save (err, res) =>
      winston.info "leave #{@id} #{user.id}"
      callback err, res


  isUserPlaying: (user) -> user in @players

  playerCount: -> (_.filter @players, (o) -> o != null).length


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
