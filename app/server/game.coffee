# Create, edit and view game definitions

msgpack = require 'msgpack2'
buffer = require 'buffer'
async = require 'async'

##########################################
# Helper functions; will be moved to lib #
##########################################

# http://coffeescriptcookbook.com/chapters/classes_and_objects/cloning
clone = (obj) ->
  if not obj? or typeof obj isnt 'object'
    return obj
  newInstance = new obj.constructor()
  for key of obj
    newInstance[key] = clone obj[key]
  return newInstance
#

packFieldsGen = (packedFields) -> (data) -> 
  ret = {}
  for key, value of data
    if key in packedFields then ret[key] = msgpack.pack(data[key]).toString 'binary'
    else ret[key] = value
  ret

unpackFieldsGen = (packedFields) -> (data) -> 
  ret = {}
  for key, value of data
    if key in packedFields then ret[key] = msgpack.unpack new buffer.Buffer data[key], 'binary'
    else ret[key] = value
  ret

wrapAction = (action) -> (args...) ->
  cb = args.pop()
  args.push (err, res) -> cb {success:!err, res:if err then err else res}
  action.apply this, args

actions = (obj) ->
  module.exports.actions = {}
  for name, action of obj
    module.exports.actions[name] = wrapAction action

###########################
# End of helper functions #
###########################

emptyGame = 
  author: null
  name: 'New game'
  boards: []
  moves: []
  rules: []

packedFields = ['boards', 'moves', 'rules']
packFields = packFieldsGen packedFields
unpackFields = unpackFieldsGen packedFields

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

actions rawActions
