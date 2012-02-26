# This is a critical part of the de/serialization workflow:
#
# MsgPack -\ (server, from DB)
#           ---> builder.coffee ---> game objects
# JSON ----/ (client, from server)

exports.build = (input, apiTreeRoot=SS.shared) ->
  constructorParts = input['_type'].split('.')
  constructor = apiTreeRoot
  while constructorParts.length > 0
    constructor = constructor[node = constructorParts.shift()]
    if not constructor then throw Error "API tree node '#{node}' not found while building '#{input._type}'"
  output = new constructor()
  for key, value of input
    output[key] = value
  return output