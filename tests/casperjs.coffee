phantom.casperPath = './casperjs/casperjs'
phantom.injectJs phantom.casperPath + '/bin/bootstrap.js'

casper = require('casper').create
  verbose: true
  #logLevel: 'debug'
casper.defaultWaitTimeout = 30000

po = require('./casperjs/PageObjects')(casper)

casper.start 'https://localhost:3001/'
  
require("./casperjs/#{t}").run casper, po for t in [
  'register-login'
]

casper.run -> @exit @test.testResults.failed != 0
