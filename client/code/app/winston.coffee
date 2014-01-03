logUser = ->
  if _.isUndefined(window.user)
    'n/a'
  else
    "#{user.id}:#{user.nick}"

applyMetadataFilters = (filters, args...) ->
  # TODO: use callbacks. in the general case the filter may be async
  return args unless _.isObject(_.last(args))
  last = args.pop()
  for filter in filters
    last = filter(last)
  args.push(last)
  return args

buildLogger = (prefixArgs...) ->
  o = {metadataFilters: []}
  for method in ['log', 'info', 'warn', 'error', 'debug', 'verbose', 'silly']
    o[method] = do (method) ->
      (args...) ->
        finalArgs = applyMetadataFilters(this.metadataFilters, prefixArgs..., args...)
        console.log "#{method}:", finalArgs...
        ss.rpc "winston.#{method}", "client:#{logUser()}", finalArgs...
  return o

module.exports = buildLogger()
module.exports.getLogger = buildLogger
