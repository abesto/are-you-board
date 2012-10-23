async = require 'async'

base = require './base'

Game = require '../../../client/code/app/Game'
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

