module.exports = (cls, decorators={}) ->
  create: (args..., cb) ->
    redis.incr cls.name, (err, id) ->
      if err
        winston.error "redis_error INCR_#{cls.name} #{err}"
        return cb err
      obj = new cls id, args...
      decorators.create? obj
      str = obj.serialize()
      redis.set "#{cls.name}:#{id}", str, (err, ok) ->
        if err
          winston.error "redis_error SET_#{cls.name}:#{id} #{err}"
          return cb err
        cb null, str
        winston.info "new_#{cls.name} #{obj}"

  get: (id, cb) ->
    redis.get "#{cls.name}:#{id}", (err, str) ->
      if err
        winston.error "redis_error GET_#{cls.name}:#{id}, #{err}"
        return cb err
      cb null, str

  save: (id, str, cb) ->
    redis.set "#{cls.name}:#{id}", str, (err, ok) ->
      if err
        winston.error "redis_error SET_#{cls.name}:#{id}, #{err}"
        return cb err
      cb null, ok
