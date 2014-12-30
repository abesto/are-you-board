exports.redis = -> require('redis').createClient(process.env.REDIS_PORT || 6379, process.env.REDIS_HOST || '127.0.0.1')
exports.winston = -> require('winston')
exports.lodash = -> require('lodash')
exports.model = -> require('./model');
exports.async = -> require('async')
exports.constants = -> require '../client/code/app/constants'
exports.signals = -> require('signals')

exports.chai = -> require('chai')

exports.loadAppGlobals = ->
  for item in ['redis', 'winston', 'model', 'async', 'constants', 'signals']
    global[item] = exports[item]()
  global._ = exports.lodash()
  require('../client/code/app/utils.coffee')(global);

exports.loadTestGlobals = ->
  exports.loadAppGlobals()
  global.chai = exports.chai()
  global.should = exports.chai().Should()

