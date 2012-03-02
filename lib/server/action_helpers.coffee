msgpack = require 'msgpack2'
buffer = require 'buffer'
cs = require 'coffee-script'

# Convert a node.js-style callback parameter to a socketstream-style callback
# node.js style: cb(err, res)
# socketstream style: cb({err:err, res:res}) because only a single return value is supported
wrapAction = (action) -> 
  # This hackery is needed because SocketStream checks the number of
  # expected parameters of a function via fun.length
  signature = '(' + ('p'+i for i in [0...action.length]).join(',') + ')'
  fun = cs.compile """
#{signature} ->
  args = Array.prototype.slice.call arguments, 0
  cb = args.pop()
  args.push (err, res) -> cb {err:err, res:res}
  action.apply this, args
""", {bare:true}
  eval fun


module.exports =
  packFieldsGen: (packedFields) -> (data) -> 
    ret = {}
    for key, value of data
      if key in packedFields then ret[key] = msgpack.pack(data[key]).toString 'binary'
      else ret[key] = value
    ret

  unpackFieldsGen: (packedFields) -> (data) -> 
    ret = {}
    for key, value of data
      if key in packedFields then ret[key] = msgpack.unpack new buffer.Buffer data[key], 'binary'
      else ret[key] = value
    ret

  actions: (module, obj) ->
    module.exports.actions = {}
    for name, action of obj
      module.exports.actions[name] = wrapAction action

