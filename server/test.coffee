require('./setup').loadTestGlobals()
global.ss = require('socketstream').start()

#require './mocha/authenticationSuite'
require './mocha/authorizationSuite'

