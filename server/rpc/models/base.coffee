module.exports = (req, res, ss, cls, decorators={}) ->
  require('../../model')(cls, decorators)
  create: (args...) -> cls.model.create args..., res
  get: (id) -> cls.model.get id, res

