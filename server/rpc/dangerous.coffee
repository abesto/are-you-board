# Dangerous methods that are exposed only in development mode, for use by tests / test setup

exports.actions = (req, res, ss) ->
  return {} if ss.env == 'production'
  flushdb: -> redis.flushdb res if ss.env != 'production'
