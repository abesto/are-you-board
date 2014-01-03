logTimestamp = ->
  date = new Date()
  date.getFullYear() + '-' + date.getPaddedMonths() + '-' + date.getPaddedDays() + ' ' +\
  date.getPaddedHours() + ':' + date.getPaddedMinutes() + ':' + date.getPaddedSeconds() + '.' + date.getMilliseconds()
logUser = ->
  if _.isUndefined(window.user)
    'n/a'
  else
    "#{user.id}:#{user.nick}"
module.exports = do ->
  o = {}
  for method in ['log', 'info', 'warn', 'error', 'debug', 'verbose', 'silly']
    o[method] = do (method) ->
      (args...) ->
        console.log "#{method}:", "[#{logTimestamp()}]", "user:#{logUser()}", args...
        ss.rpc "winston.#{method}", "[#{logTimestamp()}]", "user:#{logUser()}", args...
  return o
