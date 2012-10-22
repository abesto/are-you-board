module.exports = (req, res, ss, cls, decorators={}) ->
  create: (args...) ->
    redis.incr cls.name, (err, id) ->
      return res err if err
      obj = new cls id, args...
      decorators.create? obj
      str = obj.serialize()
      redis.set "#{cls.name}:#{id}", str, (err, ok) ->
        return res err if err
        res null, str

  get: (id) ->
    redis.get "#{cls.name}:#{id}", (err, str) ->
      return res err if err
      res null, str

  save: (id, str) ->
    redis.set "#{cls.name}:#{id}", str, (err, ok) ->
      return res err if err
      res null, ok
