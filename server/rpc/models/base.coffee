module.exports = (req, res, ss, cls, decorators={}) ->
  cls.model.decorators = decorators
  create: (args...) -> cls.model.create args..., res
  get: (id) -> cls.model.get id, res

