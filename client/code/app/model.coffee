Repository = require '/Repository'

rpcWithDeserialize = (cls, method, deserialize=null) -> (args..., callback) ->
  deserialize ||= cls.deserialize
  rpcMethod = "models.#{cls._name}.#{method}"
  ss.rpc rpcMethod, args..., (err, res) ->
    if err
      winston.error "#{err} rpc:#{rpcMethod}(#{args})" if err
      callback err
    else
      deserialize res, (err, deserialized) ->
        return  callback err if err
        Repository.add cls, deserialized
        callback err, deserialized

module.exports = (cls) ->
  cls.model =
    wrappersDisabled: false
    disableWrappers: -> cls.model.wrappersDisabled = true
    enableWrappers: -> cls.model.wrappersDisabled = false
    create: rpcWithDeserialize cls, 'create'
    get: rpcWithDeserialize cls, 'get'
    getMulti: (ids..., cb) ->
      failed = null
      items = []
      rpcWithDeserialize(cls, 'getMulti', cls.multiDeserialize)  ids..., (err, item) ->
        failed = err if err
        return cb failed if failed
        items.push item
        cb null, items if items.length == ids.length
    count: (cb) -> ss.rpc "models.#{cls._name}.count", cb

  cls::on = (event, fun) ->
    ss.event.on "#{cls._name}:#{event}:#{@id}", fun
  cls::off = (event, fun) ->
    ss.event.off "#{cls._name}:#{event}:#{@id}", fun
  cls::once = (event, fun) ->
    ss.event.once "#{cls._name}:#{event}:#{@id}", fun

  for method in cls.MODEL_METHODS
    do (method) ->
      original = cls.prototype[method]
      cls.prototype[method] = (args...) ->
        if cls.model.wrappersDisabled
          original.call this, args...
        else
          callback = args.pop() if _.isFunction _.last args
          args = ((if arg.id? then arg.id else arg) for arg in args)
          listener = -> callback null
          @once method, listener
          ss.rpc "models.#{cls._name}.#{method}", @id, args..., (err) =>
            if err
              @off method, listener
              callback err

