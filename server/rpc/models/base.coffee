module.exports = (req, res, ss, cls, decorators={}) ->
  model = require('../../model')(cls, decorators)
  create: (args...) -> model.create args..., res
  get: (id) -> model.get id, res
  save: (id, str) -> model.save id, str, res

