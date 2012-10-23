module.exports = (req, res, ss, cls, decorators={}) ->
  create: (args...) ->
    redis.incr cls.name, (err, id) ->
      if err
        winston.error "redis_error INCR_#{cls.name} #{err}"
        return res err
      obj = new cls id, args...
      decorators.create? obj
      str = obj.serialize()
      redis.set "#{cls.name}:#{id}", str, (err, ok) ->
        if err
          winston.error "redis_error SET_#{cls.name}:#{id} #{err}"
          return res err
        res null, str
        winston.info "#{cls.model.name} #{id} created"

  get: (id) ->
    redis.get "#{cls.name}:#{id}", (err, str) ->
      if err
        winston.error "redis_error GET_#{cls.name}:#{id}, #{err}"
        return res err
      res null, str

  save: (id, str) ->
    redis.set "#{cls.name}:#{id}", str, (err, ok) ->
      if err
        winston.error "redis_error SET_#{cls.name}:#{id}, #{err}"
        return res err
      res null, ok
