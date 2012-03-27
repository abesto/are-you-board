phantom.casperPath = './casperjs'
phantom.injectJs phantom.casperPath + '/bin/bootstrap.js'

casper = require('casper').create
  faultTolerant: false
  verbose: true
  #logLevel: 'debug'
casper.defaultWaitTimeout = 30000

casper.po = require('./utils/PageObjects') casper

casper.start 'http://localhost:3000'
casper.po.waitUntilVisible()
casper.test.on 'tests.complete', ->
  @renderResults true, undefined, casper.cli.get('xunit') || undefined
casper.test.runSuites.apply casper.test, ['./casperjs-suite']
casper.run()