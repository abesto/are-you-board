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
    (          cb) -> redis.hget 'users', nick, cb
    (i,        cb) ->
      if i is null
        cb 'User not found.', null 
      else 
        id = i
        cb()
    (          cb) -> redis.hget "user:#{id}", 'hash', cb
    (old_hash, cb) -> bcrypt.compare password, old_hash, cb
    (valid,    cb) -> if not valid then cb 'Invalid password.', null else cb()
    (          cb) -> hash_password password, cb
    (new_hash, cb) -> redis.hset "user:#{id}", 'hash', new_hash, cb
  ], (err) -> cb err, id

exports.register = ({nick, password}, cb) ->
  user = {nick: nick}
  async.waterfall [
    (       cb) -> hash_password password, cb
    (hash,  cb) -> user.hash = hash; redis.hsetnx 'users', user.nick, -1, cb
    (valid, cb) -> if not valid then cb 'Sorry, that nick is already taken.', null else cb()
    (       cb) -> redis.incr 'users:id', cb
    (id,    cb) -> user.user_id = id; redis.hset 'users', user.nick, user.user_id, cb
    (xx,    cb) -> redis.hmset "user:#{user.user_id}", user, cb
    (xx,    cb) -> exports.getUserData user.user_id, cb
  ], cb

exports.setPassword = ({user_id, password}, cb) ->
  async.waterfall [
    (      cb) -> hash_password password, cb
    (hash, cb) -> redis.hset "user:#{user_id}", 'hash', hash, cb
  ], cb

exports.getUserData = (id, cb) -> 
  redis.hmget "user:#{id}", 'nick', 'user_id', (err, [nick, user_id]) ->
    cb err, {nick: nick, user_id: user_id}

exports.hash_password = hash_password