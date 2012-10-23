# Make 'ss' available to all modules and the browser console
window.ss = require('socketstream')

# Make 'winston' available to all modules and the browser console
window.winston = require('/winston')

# Global client-side model implementation
window.model = require('/model')

ss.server.on 'disconnect', ->
  console.log('Connection down :-(')

ss.server.on 'reconnect', ->
  console.log('Connection back up :-)')

# Flush database before running tests
ss.rpc 'dangerous.flushdb', (err, res) ->
  throw 'Failed to flush db before running tests: ' + err if err
  require '/all_tests'

