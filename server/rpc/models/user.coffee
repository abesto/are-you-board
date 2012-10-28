base = require './base'
User = require '../../../client/code/app/User.coffee'

exports.actions = (req, res, ss) ->
  actions = base req, res, ss, User,
    validateCreate: (nick) ->
      return 'nick_required' unless nick
      for c in [':']
        return "nick_forbidden_char #{c}" if c in nick


