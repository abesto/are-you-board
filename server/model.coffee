redis.withLock = (key, toWrap, cb, lockTimeout=200, retryInterval=3) ->
  lock = "#{key}:lock"
  tryCount = 1
  tryit = ->
    redis.setnx lock, timestamp() + lockTimeout, (err, res) ->
      return winston.error "lock_failed", {lock: lock, err: err} if err
      if res == 1
        cb (args...) ->
          redis.del lock
          toWrap args...
      else
        redis.get lock, (err, res) ->
          return winston.error "redis_error", {op: "GET #{lock}", err: err} if err
          if parseInt(res) < timestamp()
            winston.error "breaking_lock", {lock: lock}
            redis.del lock, (err, res) ->
              return winston.error "redis_error", {op: "DEL #{lock}", err: err} if err
              tryit()
          else
            winston.debug "lock_taken", {lock: lock, tryCount: tryCount}
            setTimeout tryit, retryInterval
  tryit()


module.exports = (cls) ->
  cls.model =
    decorators: {}

    key: (id) -> "#{cls.name}:#{id}"

    create: (args..., cb) ->
      redis.incr cls.name, (err, id) ->
        if err
          winston.error "redis_error", {op: "INCR #{cls.name}", err: err}
          return cb err
        if _.isFunction cls.model.decorators.validateCreate
          err = cls.model.decorators.validateCreate args...
          return cb err if err
        obj = new cls id, args...
        cls.model.decorators.create? obj
        str = obj.serialize()
        redis.set cls.model.key(id), str, (err, ok) ->
          if err
            winston.error "redis_error", {op: "SET #{cls.model.key(id)}", err: err}
            return cb err
          cb null, str
          winston.info "new_#{cls.name}", {id: obj.id}

    get: (id, cb) ->
      redis.get "#{cls.name}:#{id}", (err, str) ->
        if err
          winston.error "redis_error", {op: "GET #{cls.model.key(id)}", err: err}
          return cb err
        if str == null or _.isUndefined str
          winston.error "redis_not_found", {op: "GET #{cls.model.key(id)}"}
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
        winston.error "redis_error", {op: "SET #{@key()}", err: err}
        return cb err
      cb null, ok

