rpcWithDeserialize = (cls, method) -> (args...) ->
  callback = args.pop() if _.isFunction _.last(args)
  rpcMethod = "models.#{cls.name}.#{method}"
  ss.rpc rpcMethod, args..., (err, res) ->
    if err
      console.log "RPC ERROR: #{rpcMethod}(#{args}) -> #{err}" if err
      callback? err
    callback? err, cls.deserialize res

module.exports = (cls) ->
  cls.model =
    create: rpcWithDeserialize cls, 'create'
    get: rpcWithDeserialize cls, 'get'

  cls::save = (callback) ->
    rpcMethod = "models.#{cls.name}.save"
    ss.rpc rpcMethod, @id, @serialize(), (err, res) ->
      console.log "RPC ERROR: #{rpcMethod}(#{args}) -> #{err}" if err
      callback err, res
