async = require 'async'
G = require('../../app/server/game').actions

module.exports =
  setUp: (cb) -> 
    @session = user_id: 100
    cb()

  'Game can be created and read': (test) ->
    test.expect 3
    G.create.call this, ({err, res:created}) ->
      test.equal null, err
      G.get created.id, ({err, res:read}) ->
        test.equal null, err
        test.deepEqual created, read
        test.done()

  'Created game has expected data': (test) ->
    test.expect 2
    G.create.call this, ({err, res:game}) =>
      test.equal null, err
      expected =
        id: 1
        author: @session.user_id
        name: 'New game'
        boards: []
        moves: []
        rules: []
        lastModified: game.lastModified
      test.deepEqual expected, game
      test.done()

  'Last modified date remains the same unless the game is modified': (test) ->
    test.expect 3
    G.create.call this, ({err, res:created}) ->
      test.equal null, err
      setTimeout( ->
        G.get created.id, ({err, res:read}) ->
          test.equal null, err
          test.equal created.lastModified, read.lastModified
          test.done()
      ,1500)

  'Game can be renamed, last modified date is updated': (test) ->
    test.expect 4
    G.create.call this, ({res:old}) ->
      G.update {id: old.id, name: 'Changed'}, ({err}) ->
        test.equal null, err
        G.get old.id, ({err, res:renamed}) ->
          test.equal null, err
          test.equal 'Changed', renamed.name
          test.ok renamed.lastModified >= old.lastModified
          test.done()

  'Change multiple fields of a game': (test) ->
    test.expect 3
    G.create.call this, ({res:game}) =>
      data =
        id: game.id
        name: 'Other'
        boards: [1, 2, 'foo']
        moves: [{a:3}]
      expected =
        author: 100
        id: game.id
        name: 'Other'
        boards: [1, 2, 'foo']
        moves: [{a:3}]
        rules: []

      G.update data, ({err}) ->
        test.equal null, err
        G.get game.id, ({err, res:game}) ->
          expected.lastModified = game.lastModified
          test.equal null, err
          test.deepEqual expected, game
          test.done()

  'Games by user': (test) ->
    test.expect 5
    create = (id, cb) -> G.create.call {session:{user_id:id}}, ({res:game}) -> cb null, game
    async.map [1, 1, 2], create, (err, games) ->
      G.getByUser 1, ({res:one}) ->
        test.equal 2, one.length
        G.getByUser 2, ({res:two}) ->
          test.equal 1, two.length
          test.deepEqual games[0], one[0]
          test.deepEqual games[1], one[1]
          test.deepEqual games[2], two[0]
          test.done()

  'Game can be deleted, no junk left': (test) ->
    test.expect 6
    G.create.call this, ({err, res:game}) ->
      test.equal null, err
      G.delete game.id, ({err, res}) ->
        test.equal null, err
        R.exists "game:#{game.id}", (err, res) ->
          test.equal null, err
          test.equal false, res
          R.sismember "games-of:100", game.id, (err, res) ->
            test.equal null, err
            test.equal false, res
            test.done()

