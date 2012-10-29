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
    create: rpcWithDeserialize cls, 'create'
    get: rpcWithDeserialize cls, 'get'

  cls::save = (callback) ->
    rpcMethod = "models.#{cls.name}.save"
    ss.rpc rpcMethod, @id, @serialize(), (err, res) ->
      winston.error "RPC ERROR: #{rpcMethod}(#{args}) -> #{err}" if err
      callback err, res

  for method in cls.MODEL_METHODS
    do (method) ->
      cls.prototype[method] = (args...) ->
        callback = args.pop() if _.isFunction _.last args
        args = (arg.id for arg in args)
        ss.rpc "models.#{cls.name}.#{method}", @id, args..., (err, ok) =>
          return callback err if err
          @load callback

