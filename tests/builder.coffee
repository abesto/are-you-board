apiTree =
  test:
    tree:
      object: class TestObject
        f: -> @x += 1

builder = require '../app/shared/builder'


exports['Output is of the appropriate class and has all input properties'] = (t) ->
    t.expect 4
    input =
      _type: 'test.tree.object'
      x: 5
      y: 3
    output = builder.build input, apiTree
    t.equal 5, output.x
    t.equal 3, output.y
    output.f()
    t.equal 6, output.x
    t.equal 3, output.y
    t.done()

exports['Meaningful error when a class is not found'] = (t) ->
  t.expect 1
  expected = new Error("API tree node 'foobar' not found while building 'test.foobar'")
  t.throws -> builder.build {_type:'test.foobar', x:3}, apiTree, expected
  t.done()