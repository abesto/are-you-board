module.exports = (cls, name) ->
  cls.model =
    create: (args...) ->
      callback = args.pop() if _.isFunction _.last(args)
      ss.rpc "models.#{name}.create", args..., (res) ->
        callback? cls.deserialize res

