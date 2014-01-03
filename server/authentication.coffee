# User storage and authentication
# Redis structure:
#  users HASH {name: id}
#  users:id INT (the next free user id)
#  User:<id> HASH {nick, hash}

bcrypt = require 'bcrypt'
async = require 'async'
User = require '../client/code/app/User'

exports.hashPassword = hashPassword = (password, cb) ->
  async.waterfall [
    (cb      ) -> bcrypt.genSalt cb
    (salt, cb) -> bcrypt.hash password, salt, cb
  ], cb

exports.authenticate = (nick, password, cb) ->
  id = null
  async.waterfall [
    (          cb) -> redis.hget 'users_by_nick', nick, cb
    (i,        cb) ->
      if i is null
        winston.debug 'login_no_such_user', nick
        bcrypt.compare 'avoid', 'timing', ->
          hashPassword 'attacks', ->
            cb 'invalid_credentials', null
      else 
        id = i
        cb()
    (          cb) -> redis.get "User:#{id}:hash", cb
    (old_hash, cb) -> bcrypt.compare password, old_hash, cb
    (valid,    cb) -> if not valid then cb 'invalid_credentials', null else cb()
    (          cb) -> hashPassword password, cb
    (new_hash, cb) -> redis.set "User:#{id}:hash", new_hash, cb
  ], (err) ->
    winston.info 'login', {err: err, nick: nick, id: id}
    cb err, id

exports.setPassword = (user_id, password, cb) ->
  async.waterfall [
    (      cb) -> hashPassword password, cb
    (hash, cb) -> redis.set "User:#{user_id}:hash", hash, cb
  ], cb

