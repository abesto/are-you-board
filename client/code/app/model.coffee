rpcWithDeserialize = (cls, name, method) -> (args...) ->
  callback = args.pop() if _.isFunction _.last(args)
  ss.rpc "models.#{name}.#{method}", args..., (res) ->
    callback? cls.deserialize res

module.exports = (cls, name) ->
  cls.model =
    create: rpcWithDeserialize cls, name, 'create'
    get: rpcWithDeserialize cls, name, 'get'
