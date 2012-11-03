base = require './base'
User = require '../../../client/code/app/User.coffee'

exports.actions = (req, res, ss) ->
  actions = base req, res, ss, User,
    validateCreate: (nick, password) ->
      return 'nick_required' unless nick
      for c in [':']
        return "nick_forbidden_char #{c}" if c in nick
      return 'password_too_short' unless password and password.length >= 3


    create: (user, cb) ->
      redis.hset 'users_by_nick', user.nick, user.id, cb


