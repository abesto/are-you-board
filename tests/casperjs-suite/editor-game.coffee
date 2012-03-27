async = require '../../node_modules/async/lib/async'

id = null
newLastModified = lastModified = 0
name = 'Haunted House'
desc = "A haunted house is a house or other building often perceived as
being inhabited by disembodied spirits of the deceased who may have been
former residents or were familiar with the property. Supernatural activity
inside homes is said to be mainly associated with violent or tragic events
in the building's past such as murder, accidental death, or suicide."

casper.then -> 
  casper.test.comment 'Editor - Game creation, deletion, renaming, description'

  async.waterfall [
    (cb)     -> casper.po.navbar.toTab 'editor', cb
    (po, cb) -> 
      po.createGame cb
    (po, cb) ->
      casper.test.assertEquals po.name, 'editor.general', 'Created game, redirected to game editor'
      id = po.getCurrent().id
      po.enterName name
      po.enterDescription desc
      po.save cb
    (po, cb) ->
      casper.test.assertEquals po.getCurrent().name, name, 'Game title updated on editor page after save'
      po.navbar.toTab 'editor', cb
    (po, cb) ->
      game = po.get id
      lastModified = game.lastModified
      casper.test.assertNot (game == ''), 'Game visible in games list'
      casper.test.assertEquals game.name, name, '  ... with the name entered in the editor...'
      casper.test.assertEquals game.description, desc, '  ... and the description entered in the editor.'
      po.edit id, cb
    (po, cb) -> 
      name = 'FOO'
      desc = 'BAR'
      casper.test.assertEquals po.getCurrent().id, id, 'Switched back to game editor'
      po.enterName name
      po.enterDescription desc
      casper.wait 1100, -> po.save cb
    (po, cb) -> po.navbar.toTab 'editor', cb
    (po, cb) ->
      game = po.get id
      newLastModified = game.lastModified
      casper.test.assertNot (game == ''), 'Game still visible in games list'
      casper.test.assertEquals game.name, name, '  ... with the name changed in the editor...'
      casper.test.assertEquals game.description, desc, '  ... and the description changed in the editor.'
      casper.test.assert lastModified < newLastModified, 'Last modified date/time changes after save'
      casper.wait 1100, -> cb null, po
    (po, cb) ->
      casper.test.assert(
       (newLastModified == po.get(id).lastModified),
       'Last modified date/time doesn\'t change by itself')
      po.delete id, cb
    (po, cb) ->
      casper.test.assertEquals po.get(id), '', 'Deleted game'
      cb null, null
  ], (err, res) ->
    casper.test.fail err if err
    casper.test.done()

