cache = {}

registerEventListeners = (cls, o) ->
  for method in cls.MODEL_METHODS
    do (method) ->
      ss.event.on "#{cls._name}:#{method}:#{o.id}", (args) ->
        cls.model.disableWrappers()
        method += 'Listener' if "#{method}Listener" of o
        o[method].apply o, args
        cls.model.enableWrappers()

if window?
  module.exports =
    add: (cls, o) ->
      cache[cls._name] = {} unless cls._name of cache
      registerEventListeners cls, o
      cache[cls._name][o.id] = o

    get: (cls, id, cb) ->
      cache[cls._name] = {} unless cls._name of cache
      clsCache = cache[cls._name]
      if id not of clsCache
        cls.model.get id, (err, res) ->
          return cb err if err
          clsCache[id] = res
          registerEventListeners cls, res
          cb null, res
      else
        cb null, clsCache[id]

    delete: (cls, id) -> # TODO

else
  module.exports =
    add: (cls, o) ->
    get: (cls, id, cb) -> cls.model.get id, cb
    delete: (cls, id) ->
