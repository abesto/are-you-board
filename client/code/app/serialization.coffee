getFormat = (o) ->
  return o.shift() if _.isArray o
  if _.isObject o
    format = o.format
    delete o.format
    format

withFormat = (format, o) ->
  o.unshift format if _.isArray o
  if _.isObject o
    throw "Can't serialize an object that has a field called 'format'" if 'format' of o
    o.format = format
  o

module.exports = (cls, currentFormat, defs) ->
  cls::toSerializable = (format = currentFormat) -> withFormat format, defs[format].to.call this
  cls.fromSerializable = (obj, args...) ->
    ret = new cls()
    defs[getFormat(obj)].from ret, obj, args...
    return ret

  cls::serialize = (format = currentFormat) -> JSON.stringify @toSerializable format
  cls.deserialize = (json, args...) -> cls.fromSerializable JSON.parse(json), args...

  cls::load = (callback, args...) ->
    throw 'model must also be applied for load to work' unless cls.hasOwnProperty 'model'
    cls.model.get @id, (err, obj) =>
      return callback err if err
      serialized = obj.toSerializable()
      defs[getFormat(serialized)].from this, serialized, args...
      callback null, this
