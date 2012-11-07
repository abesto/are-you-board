# Dangerous methods that are exposed only in development mode, for use by tests / test setup

if require('socketstream').env != 'production'
  console.log 'Patching redis client to log commands and results...'

  monitoringStarted = false
  monitorBuffer = []
  monitorBuffer.push = (item) ->
    Array::push.call this, item if monitoringStarted


  for cmd in require('redis/lib/commands')
    do (cmd) ->
      original = redis[cmd]
      redis[cmd] = (args...) ->
        cb = args.pop() if _.isFunction _.last args
        original.call this, args..., (err, res) ->
          line = "    #{cmd} #{args.join ' '}\n    "
          if err
            monitorBuffer.push(line + 'err: ' + err)
          else
            monitorBuffer.push(line + res)
          cb? err, res

exports.actions = (req, res, ss) ->
  return {} if ss.env == 'production'
  flushdb: -> redis.flushdb res
  redis: (method, args...) -> redis[method] args..., res
  startMonitoring: -> res null, monitoringStarted = true
  monitor: ->
    ret = monitorBuffer[0 ... monitorBuffer.length]
    monitorBuffer.length = 0
    res ret

