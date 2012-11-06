# Dangerous methods that are exposed only in development mode, for use by tests / test setup

if require('socketstream').env != 'production'
  console.log 'Starting Redis monitor connection...'
  monitorBuffer = []
  monitorConnection = require('redis').createClient()
  monitorConnection.monitor()
  monitorConnection.on 'monitor', (timestamp, args) ->
    monitorBuffer.push args.join ' '

exports.actions = (req, res, ss) ->
  return {} if ss.env == 'production'
  flushdb: -> redis.flushdb res if ss.env != 'production'
  redis: (method, args...) -> redis[method] args..., res
  monitor: ->
    ret = monitorBuffer[0 ... monitorBuffer.length]
    monitorBuffer = []
    res ret

