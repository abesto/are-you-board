# Dangerous methods that are exposed only in development mode, for use by tests / test setup

if require('socketstream').env != 'production'
  console.log 'Patching redis client to log commands and results...'
  monitorBuffer = []

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
  flushdb: -> redis.flushdb res if ss.env != 'production'
  redis: (method, args...) -> redis[method] args..., res
  monitor: ->
    ret = monitorBuffer[0 ... monitorBuffer.length]
    monitorBuffer = []
    res ret

