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

    getMulti: (cls, ids..., cb) ->
      cache[cls._name] = {} unless cls._name of cache
      clsCache = cache[cls._name]
      items = []
      for id in ids
        if id of clsCache
          items.push clsCache[id]
        else
          items.push id
      async.map items, ((item, cb) ->
        if _.isNumber item
          cls.model.get item, (err, res) ->
            return cb err if err
            clsCache[id] = res
            registerEventListeners cls, res
            cb null, res
        else
          cb null, item
      ), (err, items) ->
        return cb err if err
        cb null, items

    delete: (cls, id) ->
      cache[cls._name] = {} unless cls._name of cache
      delete cache[cls._name][id] if id of cache[cls._name]

else
  module.exports =
    add: (cls, o) ->
    get: (cls, id, cb) -> cls.model.get id, cb
    getMulti: (cls, ids..., cb) -> cls.model.getMulti ids..., cb
    delete: (cls, id) ->
