casper.po.run ->
  @then ->
    @test.comment "Game - create, rename, modify description, delete"
    @po.navbar.toTab 'editor'

  @then -> @po.editor.list.createGame()

  name = desc = id = null
  @then -> 
    name = 'Haunted House'
    desc = "A haunted house is a house or other building often perceived as
    being inhabited by disembodied spirits of the deceased who may have been
    former residents or were familiar with the property. Supernatural activity
    inside homes is said to be mainly associated with violent or tragic events
    in the building's past such as murder, accidental death, or suicide."
    @test.assert @po.editor.game.here(), 'Created game, redirected to game editor'
    id = @po.editor.game.get().id
    @po.editor.game.rename name
    @po.editor.game.describe desc
    @po.editor.save()

  @then -> @test.assertEquals @po.editor.game.get().name, name, 'Game title updated on editor page after save'
    
  @then -> @po.navbar.toTab 'editor'

  @then ->
    game = @po.editor.list.get id
    @test.assertNot (game == ''), 'Game visible in games list'
    @test.assertEquals game.name, name, '  ... with the name entered in the editor...'
    @test.assertEquals game.description, desc, '  ... and the description entered in the editor.'
    name = 'FOO'
    desc = 'BAR'
    @po.editor.list.edit id

  @then ->
    @test.assertEquals @po.editor.game.get().id, id, 'Switched back to game editor'
    @po.editor.game.rename name
    @po.editor.game.describe desc
    @po.editor.save()

  @then -> @po.navbar.toTab 'editor', ->
    game = @po.editor.list.get id
    @test.assertNot (game == ''), 'Game still visible in games list'
    @test.assertEquals game.name, name, '  ... with the name changed in the editor...'
    @test.assertEquals game.description, desc, '  ... and the description changed in the editor.'

    @po.editor.list.delete id

  @then -> @test.assertEquals @po.editor.list.get(id), '', 'Deleted game'
