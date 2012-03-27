async = require '../../node_modules/async/lib/async'

casper.then -> 
  casper.test.comment 'Registration, logout, login'
  casper.test.assertEquals casper.po.name, 'login', 'On login page after startup'

  async.waterfall [
    (cb) -> casper.po.toRegister cb
    (register, cb) -> 
      register.register cb
    (gameList, cb) -> 
      casper.test.pass 'Registration completed, logged in automatically'
      gameList.navbar.logout cb
    (login, cb) ->
      casper.test.pass 'Logout'
      login.login cb
    (gameList, cb) ->
      casper.test.pass 'Login'
      cb null, null
  ], (err, res) ->
    casper.test.fail err if err
    casper.test.done()
