key = "i18n:untranslated"

exports.actions = (req, res, ss) -> {
  registerUntranslated: (stringKey) ->
    redis.sadd key, stringKey

  # the rest should require adminness

  listUntranslated: ->
    redis.smembers key, (err, list) ->
      res null, list

  flushUntranslated: ->
    redis.del key

  removeOneUntranslated: (stringKey) ->
    redis.sdel key, stringKey
}
