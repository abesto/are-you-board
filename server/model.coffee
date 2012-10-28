redis.withLock = (key, toWrap, cb, lockTimeout=200, retryInterval=3) ->
  lock = "#{key}:lock"
  tryCount = 1
  tryit = ->
    redis.setnx lock, timestamp() + lockTimeout, (err, res) ->
      return winston.error "lock_failed #{lock} #{err}" if err
      if res == 1
        cb (args...) ->
          redis.del lock
          toWrap args...
      else
        redis.get lock, (err, res) ->
          return winston.error "redis_error GET_#{lock} #{err}" if err
          if parseInt(res) < timestamp()
            winston.error "breaking_lock #{lock}"
            redis.del lock, (err, res) ->
              return winston.error "redis_error DEL_#{lock} #{err}" if err
              tryt()
          else
            winston.debug "lock_taken #{lock} #{tryCount++}"
            setTimeout tryit, retryInterval
  tryit()


module.exports = (cls, decorators={}) ->
  cls.model =
    key: (id) -> "#{cls.name}:#{id}"

    create: (args..., cb) ->
      redis.incr cls.name, (err, id) ->
        if err
          winston.error "redis_error INCR_#{cls.name} #{err}"
          return cb err
        obj = new cls id, args...
        decorators.create? obj
        str = obj.serialize()
        redis.set cls.model.key(id), str, (err, ok) ->
          if err
            winston.error "redis_error SET_#{cls.model.key(id)} #{err}"
            return cb err
          cb null, str
          winston.info "new_#{cls.name} #{obj}"

    get: (id, cb) ->
      redis.get "#{cls.name}:#{id}", (err, str) ->
        if err
          winston.error "redis_error GET_#{cls.model.key(id)} #{err}"
          return cb err
        if str == null
          winston.error "redis_not_found GET_#{cls.model.key(id)}"
          return cb 'not_found'
        cb null, str

    getObject: (id, cb) ->
      @get id, (err, str) ->
        return cb err if err
        cb null, cls.deserialize str

    withLock: (id, args...) -> redis.withLock @key(id), args...

  cls::key = -> cls.model.key(@id)

  cls::withLock = (args...) -> cls.model.withLock @id, args...

  cls::save = (cb) ->
    redis.set "#{cls.name}:#{@id}", @serialize(), (err, ok) ->
      if err
        winston.error "redis_error SET_#{@key()}, #{err}"
        return cb err
      cb null, ok

