# Make 'ss' available to all modules and the browser console
window.ss = require('socketstream')
TestMeta = []

log = (str) ->
  return if TestMeta.length == 0
  current = _.last TestMeta
  current.log.push str

require('/utils')(window)

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
  toSave = _.filter args, (o) -> !_.isFunction o
  log '<- ' + method + '(' + [JSON.stringify o for o in args].join(", ") + ')'
  originalRpc method, args..., (err, res) ->
    originalRpc 'dangerous.monitor', (redislog) ->
      log redislog.join('\n')
      if err
        line = "-> err: #{err}"
      else
        line = "-> #{res}"
      log line + '\n'
      cb? err, res

# Log all events
ss.event.onAny (args...) -> log 'E ' + args.join(' ')

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
    suites = ['LudoBoard', 'Path', 'models/Game', 'models/User', 'LudoRules', 'Repository']
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



