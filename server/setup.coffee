# Lightweight functions to be used in app and test initialization

exports.redis = -> require('redis').createClient()
exports.winston = -> require('winston')
exports.underscore = -> require('underscore')
exports.model = -> require('./model');
exports.async = -> require('async')
exports.sinon = -> require('sinon')
exports.constants = -> require '../client/code/app/constants'


exports.chai = -> require('chai')

exports.loadAppGlobals = ->
  for item in ['redis', 'winston', 'model', 'async', 'constants']
    global[item] = exports[item]()
  global._ = exports.underscore()
  require('../client/code/app/utils.coffee')(global);

exports.loadTestGlobals = ->
  exports.loadAppGlobals()
  global.chai = exports.chai()
  global.should = exports.chai().Should()
  global.sinon = exports.sinon()

