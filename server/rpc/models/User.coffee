base = require './base'
User = require '../../../client/code/app/User.coffee'
auth = require '../../authentication'

exports.actions = (req, res, ss) ->
  req.use 'session'

  actions = base req, res, ss, User,
    validateCreate: (nick, password) ->
      return 'nick_required' unless nick
      for c in [':']
        return "nick_forbidden_char #{c}" if c in nick
      return 'password_too_short' unless password and password.length >= 3

    create: (user, cb, nick, password) ->
      redis.hset 'users_by_nick', user.nick, user.id, (err, res) ->
        return cb err if err
        auth.setPassword user.id, password, cb

  actions.login = (nick, password) ->
    auth.authenticate nick, password, (err, id) ->
      return res err if err
      req.session.setUserId id
      User.model.get id, (err, user) ->
        return res err if err
        req.session.isSuperuser = user.isSuperuser
        res err, user.serialize()

  actions.getCurrent = ->
    return res 'not_logged_in' unless req.session.userId
    User.model.getSerialized req.session.userId, res

  actions.logout = ->
    req.session.setUserId null
    res null, null

  actions