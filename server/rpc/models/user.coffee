base = require './base'
User = require '../../../client/code/app/User.coffee'

exports.actions = (req, res, ss) ->
  actions = base req, res, ss, User

