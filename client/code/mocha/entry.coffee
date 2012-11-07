# Make 'ss' available to all modules and the browser console
window.ss = require('socketstream')
window.TestMeta = []

buildSelector = (o) ->
  if o.constructor.name == 'Suite'
    headerTag = 'h1'
    liClass = 'suite'
  else if o.constructor.name == 'Test'
    headerTag = 'h2'
    liClass = 'test'
  else
    return
  "li.#{liClass} > #{headerTag}:contains(#{Mocha.utils.escape o.title})"

testSelector = (test) ->
  selectorArray = []
  item = test
  while item and item.title.length
    selectorArray.push buildSelector item
    item = item.parent
  selectorArray.reverse().join ' + ul > '

# Patch ss.rpc to capture RPC calls for current test
originalRpc = ss.rpc
ss.rpc = (method, args...) ->
  if _.isFunction _.last args
    cb = args.pop()
  if TestMeta.length
    toSave = _.filter args, (o) -> !_.isFunction o
    _.last(TestMeta).log.push '<- ' + method + '(' + (_.map(args, (o) -> JSON.stringify o)).join(", ") + ')'
  originalRpc method, args..., (err, res) ->
    originalRpc 'dangerous.monitor', (redislog) ->
      _.last(TestMeta).log.push redislog.join('\n') if TestMeta.length
      if err
        line = "-> err: #{err}"
      else
        line = "-> #{res}"
      _.last(TestMeta).log.push line + '\n' if TestMeta.length
      cb? err, res


# Make 'winston' available to all modules and the browser console
window.winston = require('/winston')

# Global client-side model implementation
window.model = require('/model')

# Constants
window.constants = require('/constants')

async.series [
  (cb) -> ss.server.on 'ready', cb
  (cb) -> ss.rpc 'dangerous.flushdb', cb
  (cb) -> ss.rpc 'dangerous.startMonitoring', cb
], (err, res) ->
  return document.write "Startup failed: #{err}" if err
  jQuery ->
    window.s = mocha.setup
      ui: 'bdd'
      reporter: 'html'
    window.Should = chai.Should()

    require '/helpers'
    suites = ['LudoBoard', 'Path', 'models/Game', 'models/User', 'LudoRules']
    require "/#{suite}Suite" for suite in suites

    if window.mochaPhantomJS
      mochaPhantomJS.run()
    else
      mochaRunner = mocha.run()
      mochaRunner.on 'test', (test) ->
        TestMeta.push
          test: test
          log: []
      mochaRunner.on 'end', ->
        for test in TestMeta
          if test.log.length
            $(testSelector(test.test) + ' + pre').append("\n\nRPC calls, Redis commands:\n" + test.log.join("\n"))



