test = (name) -> require "./nodeunit-suite/#{name}"
require('nodeunit').reporters['default'].run
  Logic:
    'Test utils':
      'Call counter': test 'callcounter'
    Builder: test 'builder'
    Boards:
      Rectangle: test 'boards/rectangle'
    Moves:
      AbsolutePath: test 'moves/absolutepath'
  'Redis models':
    setUp: (cb) ->
      global.R = require('redis').createClient()
      R.select 10
      cb()
    tearDown: (cb) ->
      R.flushdb()
      R.quit()
      cb()
    'bcrypt auth': test 'auth_redis_bcrypt'
    'game storage': test 'server/game'
