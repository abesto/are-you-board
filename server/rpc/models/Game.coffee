async = require 'async'

base = require './base'

Game = require('../../../client/code/app/Game')
Game::_join = (user, res) ->
  if @state != Game.STATE_JOINING
    winston.warn 'join_started_game'
    return res 'game_started'
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

Game::_rollDice = (res) ->
  if @state != Game.STATE_DICE
    winston.warn "wrong_state rollDice #{Game.STATE_DICE} #{@state}"
    return res 'wrong_state'
  @dice = 1 + Math.floor(Math.random() * 6)
  @state = Game.STATE_MOVE
  true

Game::_start = (res) ->
  if @state != Game.STATE_JOINING
    winston.warn "wrong_state start #{Game.STATE_JOINING} #{@state}"
    return res 'wrong_state'
  @state = Game.STATE_DICE
  @_nextSide()
  true

Game::_move = (res) ->
  if @state != Game.STATE_MOVE
    winston.warn "wrong_state move #{Game.STATE_MOVE} #{@state}"
    return res 'wrong_state'
  @state = Game.STATE_DICE
  @_nextSide()
  true


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
  actions.start = update false, (game) -> game._start res
  actions.rollDice = update false, (game) -> game._rollDice res
  actions.move = update false, (game) -> game._move res

  actions

