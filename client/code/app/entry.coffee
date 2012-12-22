# Make 'ss' available to all modules and the browser console
window.ss = require('socketstream')

# Make 'winston' available to all modules and the browser console
window.winston = require('/winston')

# Global client-side model implementation
window.model = require('/model')

# Constants
window.constants = require('/constants')

ss.server.on 'disconnect', ->
  console.log('Connection down :-(')

ss.server.on 'reconnect', ->
  console.log('Connection back up :-)')

ss.server.on 'ready', ->

  # Wait for the DOM to finish loading
  jQuery ->
    $(window).unload ss.heartbeatStop
    # Load app
    require('/app')
    require('/i18n')
