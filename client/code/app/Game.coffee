serialization = require './serialization'
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
  _join: (user, res) ->
    if @isUserPlaying user
      winston.warn "already_joined #{user} #{this}"
      return res 'already_joined'
    idx = @firstFreeSide()
    if _.isUndefined idx
      winston.warn "game_full #{user} #{this}"
      return res 'game_full'
    @players[idx] = user
    winston.info "join #{user} #{this}"
    true

  _leave: (user, res) ->
    idx = @userSide user
    if _.isUndefined idx
      winston.warn "leave_not_joined #{user} #{this}"
      return res 'leave_not_joined'
    @players[idx] = null
    winston.info "leave #{user} #{this}"
    true

  _nextSide: ->
    for i in [@currentSide+1 ... @players.length].concat [0 .. @currentSide]
      if @players[i] != null
        @currentSide = i
        return true


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
