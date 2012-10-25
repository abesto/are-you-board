async = require 'async'

base = require './base'

Game = require('../../../client/code/app/Game')
Game::_join = (user, res) ->
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

Game::_leave = (user, res) ->
  idx = @userSide user
  if _.isUndefined idx
    winston.warn "leave_not_joined #{user} #{this}"
    return res 'leave_not_joined'
  @players[idx] = null
  winston.info "leave #{user} #{this}"
  true

Game::_nextSide = ->
  for i in [@currentSide+1 ... @players.length].concat [0 .. @currentSide]
    if @players[i] != null
      @currentSide = i
      return true


User = require '../../../client/code/app/User'
LudoBoard = require '../../../client/code/app/LudoBoard'

exports.actions = (req, res, ss) ->
  update = (withUser, fun) -> (gameId, userId) ->
    getters = [(cb) -> Game.model.getObject gameId, cb]
    getters.push((cb) -> User.model.getObject userId, cb) if withUser
    async.parallel getters, (err, args) ->
      return res err if err
      args[0].save res if fun args..., res

  actions = base req, res, ss, Game,
    create: (game) ->
      game.board = new LudoBoard()

  actions.join = update true, (game, user, res) -> game._join user, res
  actions.leave = update true, (game, user, res) -> game._leave user, res
  actions.nextSide = update false, (game) -> game._nextSide()

  actions

