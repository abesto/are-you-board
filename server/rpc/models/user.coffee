redis = require('redis').createClient()
User = require '../../../client/code/app/User.coffee'

exports.actions = (req, res, ss) ->
  create: (nick) ->
    redis.incr 'user', (err, id) ->
      user = new User id, nick
      str = user.serialize()
      redis.set "user:#{id}", str, (err, ok) ->
        res str

  get: (id) ->
    redis.get "user:#{id}", (err, str) ->
      res str

