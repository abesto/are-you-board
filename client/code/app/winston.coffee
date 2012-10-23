proxy = (method) -> (args...) -> ss.rpc "winston.#{method}", args...
module.exports = do ->
  o = {}
  for method in ['log', 'info', 'warn', 'error']
    o[method] = proxy method
  return o

