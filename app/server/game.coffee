# Create, edit and view game definitions

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

packedFields = ['boards', 'moves', 'rules']
packFields = A.packFieldsGen packedFields
unpackFields = A.unpackFieldsGen packedFields

rawActions =
  create: (cb) ->
    game = clone emptyGame
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
      (ids, cb) -> async.map ids, rawActions.get, cb
    ], cb

  update: (game, cb) ->
    R.hmset "game:#{game.id}", packFields(game), cb

A.actions module, rawActions
