ss = require 'socketstream'
async = window?.async || require 'async'

logUserOrServerHost = ->
  if typeof(window) == 'undefined'
    return require('os').hostname()
  if _.isUndefined(window.user)
    'User(not_logged_in)'
  else
    window.user.toString()

identityMetadataFilter = (x, cb) -> cb(null, x)
applyMetadataFilters = (filters, args...) ->
  cb = args.pop()
  return cb(null, args) unless _.isObject(_.last(args))
  async.compose(identityMetadataFilter, filters...) args.pop(), (err, last) ->
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
          ss.rpc? "winston.#{method}", "client:#{logUserOrServerHost()}", finalArgs...
  return o

exports.getLogger = buildLogger
