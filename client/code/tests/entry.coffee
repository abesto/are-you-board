# Make 'ss' available to all modules and the browser console
window.ss = require('socketstream')

# Make 'winston' available to all modules and the browser console
window.winston = require('/winston')

ss.server.on 'disconnect', ->
  console.log('Connection down :-(')

ss.server.on 'reconnect', ->
  console.log('Connection back up :-)')

require '/all_tests'

