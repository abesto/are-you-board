redis = require('redis').createClient()

module.exports = (req, res, ss, cls, decorators={}) ->
  create: (args...) ->
    redis.incr cls.name, (err, id) ->
      obj = new cls id, args...
      decorators.create? obj
      str = obj.serialize()
      redis.set "#{cls.name}:#{id}", str, (err, ok) ->
        res str

  get: (id) ->
    redis.get "#{cls.name}:#{id}", (err, str) ->
      res str

