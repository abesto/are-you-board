cache = {}

registerEventListeners = (cls, o) ->
  for method in cls.MODEL_METHODS
    do (method) ->
      ss.event.on "#{cls.name}:#{method}:#{o.id}", (args...) ->
        cls.model.disableWrappers()
        o[method].apply o, args
        cls.model.enableWrappers()

module.exports =
  get: (cls, id, cb) ->
    cache[cls.name] = {} unless cls.name of cache
    clsCache = cache[cls.name]
    if id not of clsCache
      cls.model.get id, (err, res) ->
        return cb err if err
        clsCache[id] = res
        registerEventListeners cls, res
        cb null, res
    else
      cb null, clsCache[id]

  delete: (cls, id) ->
