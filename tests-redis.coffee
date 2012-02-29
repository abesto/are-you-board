test = (name) -> require "./tests/#{name}"

require('nodeunit').reporters['default'].run
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
