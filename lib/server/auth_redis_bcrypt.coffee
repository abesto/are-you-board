# User storage and authentication
# Redis structure:
#  users HASH {name: id}
#  users:id INT (the next free user id)
#  user:<id> HASH {nick, hash}

bcrypt = require 'bcrypt'
async = require 'async'

hash_password = (password, cb) ->
  async.waterfall [
    (cb      ) -> bcrypt.genSalt cb
    (salt, cb) -> bcrypt.hash password, salt, cb
  ], cb

exports.authenticate = ({nick, password}, cb) ->
  id = null
  async.waterfall [
    (          cb) -> R.hget 'users', nick, cb
    (i,        cb) ->
      if i is null
        cb 'User not found.', null 
      else 
        id = i
        cb()
    (          cb) -> R.hget "user:#{id}", 'hash', cb
    (old_hash, cb) -> bcrypt.compare password, old_hash, cb
    (valid,    cb) -> if not valid then cb 'Invalid password.', null else cb()
    (          cb) -> hash_password password, cb
    (new_hash, cb) -> R.hset "user:#{id}", 'hash', new_hash, cb
  ], (err) -> cb err, id

exports.register = ({nick, password}, cb) ->
  user = {nick: nick}
  async.waterfall [
    (       cb) -> hash_password password, cb
    (hash,  cb) -> user.hash = hash; R.hsetnx 'users', user.nick, -1, cb
    (valid, cb) -> if not valid then cb 'Sorry, that nick is already taken.', null else cb()
    (       cb) -> R.incr 'users:id', cb
    (id,    cb) -> user.user_id = id; R.hset 'users', user.nick, user.user_id, cb
    (xx,    cb) -> R.hmset "user:#{user.user_id}", user, cb
  ],(err      ) -> cb err, user

exports.setPassword = ({user_id, password}, cb) ->
  async.waterfall [
    (      cb) -> hash_password password, cb
    (hash, cb) -> R.hset "user:#{user_id}", 'hash', hash, cb
  ], cb

exports.getUserData = (id, cb) -> 
  R.hmget "user:#{id}", 'nick', 'user_id', (err, [nick, user_id]) -> 
    cb err, {nick: nick, user_id: user_id}

exports.hash_password = hash_password