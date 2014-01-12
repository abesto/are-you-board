User = require '/User'
routes = require './routes'

# TODO: make allKeys not a global, return it instead
allKeys = []
addToAllKeys = (obj, acc=[]) ->
  if _.isString(obj)
    allKeys.push acc.join('.')
  else
    for key, child of obj
      addToAllKeys(child, acc.concat(key))

loadAllKeys = (cb) ->
  async.parallel [
    _.partial(ss.load.code, '/i18n/trans.hu.coffee')
    _.partial(ss.load.code, '/i18n/trans.en.coffee')
  ], ->
    addToAllKeys require('/trans.hu')
    addToAllKeys require('/trans.en')
    cb()


mergeWithUntranslated = (lang, untranslated, cb) ->
  translated = _.cloneDeep(require("/trans.#{lang}"))
  for whole in untranslated.concat(allKeys)
    current = translated
    parts = whole.split('.')
    last = parts.pop()
    for part in parts
      current[part] = {} unless part of current
      current = current[part]
    current[last] ?= "untranslated"
  cb null, JSON.stringify(translated, null, 4)
  # TODO: remove those that we just noticed are already translated

exports.bindRoutes = ->
  routes.admin.matched.add ->
    UI.$container.html 'Loading users'
    User.model.count (err, count) ->
      return alert err if err
      UI.$container.html "Loading #{count} users"
      # This can be generalized if needed
      async.parallel [
        _.partial(User.model.getMulti, [1..count]...),
        _.partial(ss.rpc, 'i18n.listUntranslated', 'hu'),
        _.partial(ss.rpc, 'i18n.listUntranslated', 'en'),
        loadAllKeys
      ],
      (err, [users, untranslatedHu, untranslatedEn]) ->
        async.parallel [
          _.partial(mergeWithUntranslated, 'hu', untranslatedHu),
          _.partial(mergeWithUntranslated, 'en', untranslatedEn)
        ], (err, [jsonHu, jsonEn]) ->
          UI.$container.empty().append ss.tmpl['admin-index'].render({
            users: users
            i18n: [
              {
                lang: 'hu',
                untranslated: untranslatedHu.join(', '),
                json: jsonHu
              }, {
                lang: 'en',
                untranslated: untranslatedEn.join(', '),
                json: jsonEn
              }
            ]
          })
