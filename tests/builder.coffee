apiTree =
  test:
    tree:
      object: class TestObject
        f: -> @x += 1
      another: class AnotherObject
        constructor: ({x}) -> @x = x + 1

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

exports['Work recursively on arrays'] = (t) ->
  t.expect 7
  input = [
    [
      {_type: 'test.tree.object', x:3}
    ],
    {_type: 'test.tree.object', y:4}
  ]
  output = builder.build input, apiTree
  t.ok output instanceof Array
  t.equal 2, output.length
  t.equal 1, output[0].length
  t.ok output[0][0] instanceof apiTree.test.tree.object
  t.ok output[1] instanceof apiTree.test.tree.object
  t.equal 3, output[0][0].x
  t.equal 4, output[1].y
  t.done()

exports['Constructor gets input as argument, properties set by the constructor are not overwritten'] = (t) ->
  t.expect 2
  input =
    _type: 'test.tree.another'
    x: 3
    y: 4
  output = builder.build input, apiTree
  t.equal 4, output.x
  t.equal 4, output.y
  t.done()
