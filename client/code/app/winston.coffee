logUser = ->
  if _.isUndefined(window.user)
    'n/a'
  else
    "#{user.id}:#{user.nick}"

applyMetadataFilters = (filters, args...) ->
  cb = args.pop()
  return args unless _.isObject(_.last(args))
  async.compose(filters...) args.pop(), (err, last) ->
    return cb err if err
    args.push last
    cb null, args

buildLogger = (prefixArgs...) ->
  o = {metadataFilters: []}
  for method in ['log', 'info', 'warn', 'error', 'debug', 'verbose', 'silly']
    o[method] = do (method) ->
      (args...) ->
        finalArgs = applyMetadataFilters this.metadataFilters, prefixArgs..., args..., (err, finalArgs) ->
          console.log "#{method}:", finalArgs...
          ss.rpc "winston.#{method}", "client:#{logUser()}", finalArgs...
  return o

module.exports = buildLogger()
module.exports.getLogger = buildLogger
