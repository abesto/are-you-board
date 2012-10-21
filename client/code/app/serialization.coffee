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
  cls.fromSerializable = (obj, args...) -> defs[getFormat(obj)].from obj, args...

  cls::serialize = (format = currentFormat) -> JSON.stringify @toSerializable format
  cls.deserialize = (json, args...) -> cls.fromSerializable JSON.parse(json), args...

