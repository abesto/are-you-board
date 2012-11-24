base = require './base'
User = require '../../../client/code/app/User'
authentication = require '../../authentication'
Authorization = require '../../authorization'

exports.actions = (req, res, ss) ->
  req.use 'session'
  authorization = new Authorization req

  actions = base req, res, ss, User,
    validateCreate: (nick, password) ->
      return 'nick_required' unless nick
      for c in [':']
        return "nick_forbidden_char #{c}" if c in nick
      return 'password_too_short' unless password and password.length >= 3

    create: (user, cb, nick, password) ->
      redis.hset 'users_by_nick', user.nick, user.id, (err, res) ->
        return cb err if err
        return unless authorization.checkRes res, 'User.create'
        authentication.setPassword user.id, password, cb

  actions.login = (nick, password) ->
    return unless authorization.checkRes res, 'User.login'
    authentication.authenticate nick, password, (err, id) ->
      return res err if err
      req.session.setUserId id
      User.model.get id, (err, user) ->
        if err
          req.sesion.setUserId null
          return res err if err
        req.session.isSuperuser = user.isSuperuser
        res err, user.serialize()

  actions.getCurrent = ->
    return res 'not_logged_in' unless req.session.userId
    User.model.getSerialized req.session.userId, res

  actions.logout = ->
    return unless authorization.checkRes res, 'User.logout'
    req.session.setUserId null
    req.session.channel.reset()
    res null, null

  actions