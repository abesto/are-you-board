rpcWithDeserialize = (cls, method) -> (args...) ->
  callback = args.pop() if _.isFunction _.last(args)
  rpcMethod = "models.#{cls.name}.#{method}"
  ss.rpc rpcMethod, args..., (err, res) ->
    if err
      winston.error "#{err} rpc:#{rpcMethod}(#{args})" if err
      callback? err
    else
      callback? err, cls.deserialize res

module.exports = (cls) ->
  cls.model =
    wrappersDisabled: false
    disableWrappers: -> cls.model.wrappersDisabled = true
    enableWrappers: -> cls.model.wrappersDisabled = false
    create: rpcWithDeserialize cls, 'create'
    get: rpcWithDeserialize cls, 'get'

  for method in cls.MODEL_METHODS
    do (method) ->
      original = cls.prototype[method]
      cls.prototype[method] = (args...) ->
        callback = _.last args if _.isFunction _.last args
        if cls.model.wrappersDisabled
          original.call this, args...
        else
          args = ((if arg.constructor.model? then arg.id else arg) for arg in args)
          ss.rpc "models.#{cls.name}.#{method}", @id, args..., (err, res) =>
            return callback err if err
            @load JSON.parse res
            callback err, this

