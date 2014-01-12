key = (lang) -> "i18n:untranslated:#{lang}"

exports.actions = (req, res, ss) -> {
  registerUntranslated: (lang, stringKey) ->
    redis.sadd key(lang), stringKey

  # the rest should require adminness

  listUntranslated: (lang) ->
    redis.smembers key(lang), (err, list) ->
      res null, list

  flushUntranslated: (lang) ->
    redis.del key(lang)

  removeOneUntranslated: (lang, stringKey) ->
    redis.sdel key(lang), stringKey
}
