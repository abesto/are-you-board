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
  ss.rpc 'dangerous.flushdb', (err, res) ->
    # Wait for the DOM to finish loading
    jQuery ->
      mocha.setup
        ui: 'bdd'
        reporter: 'html'
      window.Should = chai.Should()

      require '/helpers'
      suites = ['LudoBoard', 'Path', 'models/Game', 'models/User', 'LudoRules']
      require "/#{suite}Suite" for suite in suites

      if window.mochaPhantomJS
        mochaPhantomJS.run()
      else
        mocha.run()


