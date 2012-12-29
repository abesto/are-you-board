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

  cls.multiToSerializable = (objs, format = currentFormat) ->
    (obj.toSerializable(format) for obj in objs)
  cls.multiFromSerializable = (objs, args...) ->
    (cls.fromSerializable(obj, args...) for obj in objs)

  cls.multiSerialize = (objs, format = currentFormat) -> JSON.stringify cls.multiToSerializable(objs, format)
  cls.multiDeserialize = (json, args...) -> cls.multiFromSerializable JSON.parse(json), args...

  cls::load = (serialized, args...) ->
    defs[getFormat(serialized)].from this, serialized, args...

  cls::loadWithFormat = (format, serialized, args...) ->
    getFormat(serialized)  # To remove it from the data object
    defs[format].from this, serialized, args...

