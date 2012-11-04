# Lightweight functions to be used in app and test initialization

exports.redis = -> require('redis').createClient()
exports.winston = -> require('winston')
exports.underscore = -> require('underscore')
exports.model = -> require('./model');

exports.chai = -> require('chai')

exports.loadAppGlobals = ->
  for item in ['redis', 'winston', 'model']
    global[item] = exports[item]()
  global._ = exports.underscore()


exports.loadTestGlobals = ->
  exports.loadAppGlobals()
  global.should = exports.chai().Should()
  global.constants = require '../client/code/app/constants'

