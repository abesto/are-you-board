redisHost = process.env.REDIS_PORT_6379_TCP_ADDR || process.env.REDIS_HOST || '127.0.0.1'
redisPort = process.env.REDIS_PORT_6379_TCP_PORT || process.env.REDIS || 6379

exports.redisHost = -> redisHost
exports.redis = -> require('redis').createClient(redisPort, redisHost)
exports.winston = -> require('winston')
exports.lodash = -> require('lodash')
exports.model = -> require('./model')
exports.async = -> require('async')
exports.constants = -> require '../client/code/app/constants'
exports.signals = -> require('signals')

exports.chai = -> require('chai')

exports.loadAppGlobals = ->
  for item in ['redis', 'redisHost', 'winston', 'model', 'async', 'constants', 'signals']
    global[item] = exports[item]()
  global._ = exports.lodash()
  require('../client/code/app/utils.coffee')(global);

exports.loadTestGlobals = ->
  exports.loadAppGlobals()
  global.chai = exports.chai()
  global.should = exports.chai().Should()

