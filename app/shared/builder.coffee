# This is a critical part of the de/serialization workflow:
#
# MsgPack -\ (server, from DB)
#           ---> builder.coffee ---> game objects
# JSON ----/ (client, from server)

exports.build = (input) ->
  constructorParts = input['_type'].split('.')
  constructor = SS.shared
  while constructorParts.length > 0
    constructor = constructor[constructorParts.shift()]
  output = new constructor()
  for key, value of input
    output[key] = value
  return output