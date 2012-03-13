fs = require 'fs'
utils = require 'utils'
f = utils.format
casper = require('casper').create
  faultTolerant: false
  verbose: true
  #logLevel: 'debug'
casper.defaultWaitTimeout = 30000

casper.po = require('./utils/PageObjects')(casper)

tests = []

if casper.cli.args.length
  tests = casper.cli.args.filter((path) -> fs.isFile(path) || fs.isDirectory path)
else
  casper.echo 'No test path passed, exiting.', 'RED_BAR', 80
  casper.exit 1

casper.test.on 'tests.complete', ->
    @renderResults true, undefined, casper.cli.get('xunit') || undefined

casper.start 'http://localhost:3000'
casper.then casper.po.waitForLoginForm
casper.test.runSuites.apply casper.test, tests

###
casper = require('casper').create
  verbose: true
  #logLevel: 'debug'
casper.defaultWaitTimeout = 30000
