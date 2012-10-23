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
    if _.contains @players, user
      winston.warn "already_joined #{this} #{user}"
      return callback 'already_joined'
    idx = _.indexOf @players, null
    if idx == -1
      winston.warn "game_full #{this} #{user}"
      return callback 'game_full'
    @players[idx] = user
    @save (err, res) =>
      winston.info "join #{this} #{user}"
      callback err, res

  leave: (user, callback) ->
    idx = _.indexOf @players, user
    if idx == -1
      winston.warn "leave_not_joined #{this} #{user}"
      return callback 'leave_not_joined'
    @players[idx] = null
    @save (err, res) =>
      winston.info "leave #{this} #{user}"
      callback err, res

  isUserPlaying: (user) -> user in @players

  playerCount: -> (_.filter @players, (o) -> o != null).length

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
      g.board = LudoBoard.fromSerializable board
      g.createdAt = new Date createdAt
      g.players = ((if _.isNull(player) then null else User.fromSerializable player) for player in players)
      g

model Game, 'game'

module.exports = Game
