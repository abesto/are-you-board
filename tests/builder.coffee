global.SS =
  shared:
    test:
      object: class TestObject
        f: -> @x += 1


exports['Output is of the appropriate class and has all input properties'] = (t) ->
    t.expect 4
    input =
      _type: 'test.object'
      x: 5
      y: 3
    output = require('../app/shared/builder').build input
    t.equal 5, output.x
    t.equal 3, output.y
    output.f()
    t.equal 6, output.x
    t.equal 3, output.y
    t.done()