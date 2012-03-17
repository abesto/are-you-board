# Create, edit and view game definitions
# TODO: permission checks

async = require 'async'
A = require '../../lib/server/action_helpers'

# http://coffeescriptcookbook.com/chapters/classes_and_objects/cloning
clone = (obj) ->
  if not obj? or typeof obj isnt 'object'
    return obj
  newInstance = new obj.constructor()
  for key of obj
    newInstance[key] = clone obj[key]
  return newInstance
#

emptyGame = 
  author: null
  name: 'New game'
  boards: []
  moves: []
  rules: []

packedFields = ['boards', 'moves', 'rules', '_css']
packFields = A.packFieldsGen packedFields
unpackFields = A.unpackFieldsGen packedFields

A.actions module, actions =
  create: (cb) ->
    game = clone emptyGame
    game.lastModified = Date.now()
    game.author = @session.user_id
    async.waterfall [
      (cb    ) -> R.incr 'games:id', cb
      (id, cb) -> game.id = id; cb null
      (cb    ) -> R.sadd "games-of:#{game.author}", game.id, cb
      (xx, cb) -> R.hmset "game:#{game.id}", packFields(game), cb
      (xx, cb) -> cb null, game
    ], cb

  get: (id, cb) ->
    async.waterfall [
      (cb)       -> R.hgetall "game:#{id}", cb
      (data, cb) -> cb null, unpackFields(data)
    ], cb

  getByUser: (userId, cb) ->
    async.waterfall [
      (cb)      -> R.smembers "games-of:#{userId}", cb
      (ids, cb) -> 
        multi = R.multi()
        multi.hgetall "game:#{id}" for id in ids
        multi.exec cb
      (data, cb) -> cb null, (unpackFields(game) for game in data)
    ], cb

  update: (game, cb) ->
    game.lastModified = Date.now()
    R.hmset "game:#{game.id}", packFields(game), cb

  delete: (id, cb) ->
    async.waterfall [
      (cb) -> actions.get id, cb
      (game, cb) -> R.srem "games-of:#{game.author}", id, cb
      (xx,   cb) -> R.del "game:#{id}", cb
    ], cb