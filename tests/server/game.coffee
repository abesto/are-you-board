async = require 'async'
G = require('../../app/server/game').actions

module.exports =
  setUp: (cb) -> 
    @session = user_id: 100
    cb()

  'Game can be created and read': (test) ->
    test.expect 3
    G.create.call this, ({success, res:created}) ->
      test.ok success
      G.get created.id, ({success, res:read}) ->
        test.ok success
        test.deepEqual created, read
        test.done()

  'Created game has expected data': (test) ->
    test.expect 2
    G.create.call this, ({success, res:game}) =>
      test.ok success
      expected =
        id: 1
        author: @session.user_id
        name: 'New game'
        boards: []
        moves: []
        rules: []
      test.deepEqual expected, game
      test.done()

  'Game can be renamed': (test) ->
    test.expect 3
    expected =
      author: @session.user_id
      name: 'Changed'
      boards: []
      moves: []
      rules: []
    G.create.call this, ({res:game}) ->
      expected.id = game.id
      G.update {id: game.id, name: 'Changed'}, ({success}) ->
        test.ok success
        G.get game.id, ({success, res:game}) ->
          test.ok success
          test.deepEqual expected, game
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

      G.update data, ({success}) ->
        test.ok success
        G.get game.id, ({success, res:game}) ->
          test.ok success
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
