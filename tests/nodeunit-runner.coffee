fs = require 'fs'
redis = require 'redis'

global.setUpRedis = (cb) ->
  global.R = redis.createClient()
  R.select 10
  cb()

global.tearDownRedis = (cb) ->
  R.flushdb()
  R.quit()
  cb()


test = (path) ->
  ret = {}
  for file in fs.readdirSync path
    fullPath = "#{path}/#{file}"
    if fs.statSync(fullPath).isDirectory()
      for key, value of test fullPath
        ret[key] = value
    else
      ret[fullPath] = require fullPath
  ret


suites = test './nodeunit-suite'

require('nodeunit').reporters['default'].run suites
