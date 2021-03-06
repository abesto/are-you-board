cache = {}

setWrappersEnabled = (cls, to) ->
  method = if to then 'enableWrappers' else 'disableWrappers'
  for wrapper in ['model', 'LudoRules']
    cls[wrapper]?[method]()

repositoryEventListenersRegistered = '__rELR'
registerEventListeners = (cls, o) ->
  return if o[repositoryEventListenersRegistered]
  for method in cls.MODEL_METHODS
    do (method) ->
      ss.event.on "#{cls._name}:#{method}:#{o.id}", (args) ->
        setWrappersEnabled cls, false
        method += 'Listener' if "#{method}Listener" of o
        o[method].apply o, args
        setWrappersEnabled cls, true
  o[repositoryEventListenersRegistered] = true

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
      indicesToFetch = []
      for id, idx in ids
        if id of clsCache
          items.push clsCache[id]
        else
          items.push null
          indicesToFetch.push idx
      return cb null, items if indicesToFetch.length == 0
      uniques = {}
      for idx in indicesToFetch
        id = ids[idx]
        uniques[id] = [] unless id of uniques
        uniques[id].push idx
      uniqueKeys = _.keys(uniques)
      cls.model.getMulti uniqueKeys..., (err, res) ->
        return cb err if err
        for [id, item] in _.zip(uniqueKeys, res)
          for idx in uniques[id]
            items[idx] = item
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

module.exports.cache = cache