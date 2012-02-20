# User storage and authentication
# Redis structure:
#  users HASH {name: id}
#  users:id INT (the next free user id)
#  user:<id> HASH {nick, hash}

bcrypt = require 'bcrypt'

hash_password = (password, cb) ->
  bcrypt.genSalt (err, salt) ->
    return cb err, null if err
    bcrypt.hash password, salt, (err, hash) ->
      return cb err, null if err
      cb null, hash

exports.authenticate = ({nick, password}, cb) ->
  R.hget 'users', nick, (err, id) ->
    return cb {success: false, info: err} if err
    # If user doesn't exist: simulate the time it takes to validate the password and return
    if id is null
      return hash_password password, (err, res) -> cb {success: false, info: err || 'User not found.'}
    R.hget "user:#{id}", 'hash', (err, old_hash) ->
      return cb {success: false, info: err} if err
      bcrypt.compare password, old_hash, (err, res) ->
        return cb {success: false, info: err or 'Invalid password.'} if err or not res
        cb {success: true, user_id: id}
        hash_password password, (err, new_hash) -> R.hset "user:#{id}", 'hash', new_hash

exports.register = ({nick, password}, cb) ->
  hash_password password, (err, hash) ->
    return cb {success: false, info: err} if err
    R.hsetnx 'users', nick, -1, (err, res) ->
      return cb {success: false, info: err or 'Nick already taken.'} if err or not res
      R.incr 'users:id', (err, id) ->
        if err
          R.hdel 'users', nick
          return cb {success: false, info: err}
        R.multi().hset('users', nick, id).hmset("user:#{id}",
          id: id
          nick: nick
          hash: hash
        ).exec (err, res) ->
          if err
            R.hdel 'users', nick
            R.del "user:#{nick}"
            return cb {success: false, info: err}
          cb {success: true, user_id: id}

exports.getUserData = (id, cb) -> R.hmget "user:#{id}", 'nick', 'id', (err, [nick, id]) -> cb {nick: nick, id: id}

exports.hash_password = hash_password