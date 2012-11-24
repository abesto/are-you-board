module.exports = (req, res, ss, cls, decorators={}) ->
  cls.model.decorators = decorators
  create: (args...) -> cls.model.create args..., res
  get: (id) -> cls.model.getSerialized id, res
  getMulti: (ids...) -> cls.model.getMultiSerialized ids, res
  count: -> cls.model.count res

