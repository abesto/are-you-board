serialization = require './serialization'
LudoBoard = require './LudoBoard'
User = require './User'
LudoRules = require './LudoRules'
Repository = require './Repository'


class Game
  @_name = 'Game'

  constructor: (@id) ->
    @createdAt = new Date()
    @createdBy = null
    @board = null
    @players = [null, null, null, null]
    @currentSide = -1
    @dice = 0
    @state = Game.STATE_JOINING
    @flavor = new LudoRules.Flavor()
    @_createLogger()

  firstFreeSide: ->
    joinOrder = [0, 2, 1, 3]
    for idx in joinOrder
      return idx if @players[idx] == null

  userSideS:[TC.Instance(User)]
  userSide: (user) -> @userIdSide user.id

  userIdSideS: [TC.Number]
  userIdSide: (userId) ->
    side = @players.indexOf userId
    return if side == -1
    side

  isUserPlayingS:[TC.Instance(User)]
  isUserPlaying: (user) -> @isUserIdPlaying user.id

  isUserIdPlayingS: [TC.Number]
  isUserIdPlaying: (userId) ->
    not _.isUndefined @userIdSide userId

  playerCount: ->
    (_.filter @players, (o) -> o != null).length

  toString: -> @id

  isStarted: -> @state != Game.STATE_JOINING

  getPreviousSide: ->
    for i in [0 ... @currentSide].reverse().concat [@players.length-1 .. @currentSide]
      if @players[i] != null
        return i

  nextSide: ->
    for i in [@currentSide+1 ... @players.length].concat [0 .. @currentSide]
      if @players[i] != null
        return @currentSide = i

  getPieceS:[TC.Number]
  getPiece: (id) -> @board.pieces[id]

  skipS:[TC.Callback]
  skip: (cb) ->
    @state = Game.STATE_DICE
    @nextSide()
    cb? null, this

  moveS:[TC.Instance(LudoBoard.Piece), TC.Callback]
  move: (piece, cb) ->
    @logger.info "move", {pieceId: piece.id, dice: @dice}
    @state = Game.STATE_DICE
    piece.move @dice, @board
    @nextSide()
    cb? null, this
  moveListener: (pieceId, cb) ->
    @move @board.pieces[pieceId], cb

  joinS:[TC.Instance(User), TC.Callback]
  join: (user, cb) ->
    return if @isUserPlaying user
    idx = @firstFreeSide()
    @players[idx] = user.id
    @logger.info "join", {user: user.toString()}
    cb? null, this

  rejoin: (cb) ->
    ss.rpc 'models.Game.rejoin', @id, (err) =>
      return cb? err if err
      @logger.info "rejoin", {user: window.user.toString()}
      cb? null, this

  leaveS:[TC.Instance(User), TC.Callback]
  leave: (user, cb) ->
    idx = @userSide user
    @players[idx] = null
    @logger.info "leave", {user: user.toString()}
    Repository.delete Game, this
    cb? null, this

  rollDiceS:[TC.Callback]
  rollDice: (cb) ->
    @dice = 1 + Math.floor(Math.random() * 6)
    @logger.debug "rollDice", {dice: @dice}
    @state = Game.STATE_MOVE
    cb? null, this

  rollDiceListenerS:[TC.Number, TC.Callback]
  rollDiceListener: (dice, cb) ->
    @dice = dice
    @state = Game.STATE_MOVE
    cb? null, null

  startS:[TC.Callback]
  start: (cb) ->
    @logger.info "start"
    @state = Game.STATE_DICE
    @nextSide()
    cb? null, this

  startPieceS:[TC.Number, TC.Callback]
  startPiece: (side, cb) ->
    @logger.info "startPiece"
    @state = Game.STATE_DICE
    @board.start(side)
    @nextSide()
    cb? null, this

  _addBasicDataToLogMeta: (meta, cb) =>
    meta.gameId = @id
    meta.state += "[#{Game.STATE_NAMES[@state]}]" if 'state' of meta
    meta.currentSide = "Side(id=#{@currentSide},color=#{Game.SIDE_NAMES[@currentSide]})"
    meta.currentUser = @players[@currentSide]
    cb null, meta

  _addUserDataToLogMeta: (meta, cb) =>
    playerId = @players[@currentSide]
    return cb(null, meta) if _.isUndefined(playerId) || playerId == null
    Repository.get User, playerId, (err, currentUser) =>
      if err
        winston.getLogger(@logPrefix).error 'logger_failed_to_get_current_user', {userId: @players[@currentSide], gameId: @id, side: @currentSide, err: err}
        meta.currentUser = new User(@players[@currentSide], 'N/A').toString()
      else
        meta.currentUser = currentUser.toString()
      cb null, meta

  _addSideDataToLogMeta: (meta, cb) =>
    return cb(null, meta) unless 'side' of meta
    userId = @players[meta.side]
    return cb(null, meta) if _.isUndefined(userId) || userId == null
    meta.side = "Side(id=#{meta.side},color=#{Game.SIDE_NAMES[meta.side]})"
    Repository.get User, userId, (err, user) =>
      if err
        winston.getLogger(@logPrefix).error 'logger_failed_to_get_side_user', {userId: userId, side: meta.side, err: err}
        meta.user = new User(userId, 'N/A').toString()
      else
        meta.user = user.toString()
      cb null, meta

  _createLogger: ->
    @logPrefix = "Ludo"
    @logger = winston.getLogger @logPrefix
    @logger.metadataFilters.push @_addBasicDataToLogMeta
    @logger.metadataFilters.push @_addUserDataToLogMeta
    @logger.metadataFilters.push @_addSideDataToLogMeta

serialization Game, 2,
  1:
    to: -> [
      @id
      @createdAt.getTime()
      @createdBy
      @board.toSerializable()
      @players
      @currentSide
      @dice
      @state
    ]

    from: (game, [id, createdAt, createdBy, board, players, currentSide, dice, state, flavor], cb) ->
      game.id = id
      game.createdAt = new Date createdAt
      game.createdBy = createdBy
      game.board = LudoBoard.fromSerializable board
      game.players = players
      game.currentSide = currentSide
      game.dice = dice
      game.state = state
      cb null, game

  2:
    to: ->
      ret = _.toArray @toSerializable(1)
      ret.push @flavor.toSerializable()
      ret

    from: (game, args, cb) ->
      flavor = args.pop()
      game.loadWithFormat 1, args, ->
        game.flavor = LudoRules.Flavor.fromSerializable(flavor)
        cb null, game


TypeSafe Game
constants.apply Game
model Game
LudoRules.wrap Game, Game.MODEL_METHODS...


Game.model.listGamesOfUser = TC('Game.model.listGamesOfUser', TC.Instance(User), TC.Callback) (user, cb) ->
  ss.rpc 'models.Game.listGamesOfUser', user.id, (err, gameIds) ->
    return cb err if err
    Repository.getMulti Game, gameIds..., cb

Game.model.listOpenGames = (cb) ->
  ss.rpc 'models.Game.listOpenGames', (err, gameIds) ->
    return cb err if err
    Repository.getMulti Game, gameIds..., cb

module.exports = Game

