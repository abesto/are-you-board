rpcWithDeserialize = (cls, name, method) -> (args...) ->
  callback = args.pop() if _.isFunction _.last(args)
  rpcMethod = "models.#{name}.#{method}"
  ss.rpc rpcMethod, args..., (err, res) ->
    return console.log "RPC ERROR: #{rpcMethod}(#{args}) -> #{err}" if err
    callback? cls.deserialize res

module.exports = (cls, name) ->
  cls.model =
    create: rpcWithDeserialize cls, name, 'create'
    get: rpcWithDeserialize cls, name, 'get'
    name: name

  cls::save = (callback) ->
    rpcMethod = "models.#{name}.save"
    ss.rpc rpcMethod, @id, @serialize(), (err, res) ->
      return console.log "RPC ERROR: #{rpcMethod}(#{args}) -> #{err}" if err
      callback res
