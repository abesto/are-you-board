# Lightweight functions to be used in app and test initialization

exports.redis = -> require('redis').createClient()
exports.winston = -> require('winston')
exports.underscore = -> require('underscore')

exports.chai = -> require('chai')


exports.loadAppGlobals = ->
  for item in ['redis', 'winston']
    global[item] = exports[item]()
  global._ = exports.underscore()

exports.loadTestGlobals = ->
  global.should = exports.chai().Should()
