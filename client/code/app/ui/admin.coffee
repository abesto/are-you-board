User = require '/User'
routes = require './routes'
constants = require '/constants'

class I18nKeys
  constructor: ->
    @keys = []

  addTree: (obj, acc=[]) =>
    if _.isString(obj)
      @keys.push acc.join('.')
    else
      for key, child of obj
        @addTree(child, acc.concat(key))

  addKey: (key) -> @keys.push(key)

  addKeys: (keys) -> @keys = @keys.concat(keys)

  loadTranslatedKeys: (cb) =>
    loaders = (_.partial(ss.load.code, "/i18n/trans.#{lang}.coffee") for lang in constants.i18n.supportedLanguages)
    async.parallel loaders, =>
      @addTree(require("/trans.#{lang}")) for lang in constants.i18n.supportedLanguages
      cb()

  loadUntranslatedKeys: (cb) =>
    ss.rpc 'i18n.listUntranslated', (err, untranslated) =>
      @addKeys(untranslated)
      cb()

  getTreeExpandedWithAllKeys: (lang) =>
    tree = _.cloneDeep(require("/trans.#{lang}"))
    untranslated = []
    for whole in @keys
      current = tree
      parts = whole.split('.')
      last = parts.pop()
      for part in parts
        current[part] = {} unless part of current
        current = current[part]
      unless last of current
        current[last] = "untranslated"
        untranslated.push whole
    {tree: tree, untranslated: untranslated}
    # TODO: remove those that we just noticed are already translated in all languages

exports.bindRoutes = ->
  routes.admin.matched.add ->
    UI.$container.html 'Loading users'
    User.model.count (err, count) ->
      return alert err if err
      UI.$container.html "Loading #{count} users"
      # This can be generalized if needed
      i18nKeys = new I18nKeys()
      async.parallel [
        _.partial(User.model.getMulti, [1..count]...),
        i18nKeys.loadTranslatedKeys,
        i18nKeys.loadUntranslatedKeys
      ], (err, [users]) ->
        context = {users: users, i18n: []}
        for lang in constants.i18n.supportedLanguages
          {tree, untranslated} = i18nKeys.getTreeExpandedWithAllKeys(lang)
          context.i18n.push {
            lang: lang,
            untranslated: untranslated.join(', '),
            json: JSON.stringify(tree, null, 4)
          }
        UI.$container.empty().append ss.tmpl['admin-index'].render(context)
