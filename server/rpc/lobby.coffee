Authorization = require('../authorization')

bindHeartbeatListeners = (ss) ->
  ss.heartbeat.on 'disconnect', (session) ->
    session.channel.unsubscribe 'lobby'
    ss.publish.channel 'lobby', 'User:disconnect', session.userId if session.userId
  ss.heartbeat.on 'connect', (session) ->
    session.channel.subscribe "lobby"
    ss.publish.channel 'lobby', 'User:connect', session.userId if session.userId
  bindHeartbeatListeners = ->

exports.actions = (req, res, ss) ->
  bindHeartbeatListeners(ss)

  req.use 'session'
  auth = new Authorization(req)

  getOnlineUserIds: ->
    return unless auth.checkRes res, 'lobby.listUsers'
    ss.heartbeat.allConnected (sessions) ->
      res null, _.uniq(parseInt(session.userId) for session in sessions when session.userId)
