exports.run = (casper, po) ->
  casper.then -> casper.test.info "TEST: Registration, logout, login"
  casper.then -> po.waitForInitialLoading -> casper.test.info 'Application loaded'
  casper.then -> po.welcome.register()

  casper.then ->
    if po.navbar.haveLogin()
      casper.test.pass 'Registration completed, logged in automatically'
    else
      casper.test.fail 'Registration failed'
      po.login ->
        if po.navbar.haveLogin()
          casper.test.info "Login succeeded, runnint remaining tests"
        else
          casper.die 'Login failed', 1

  casper.then -> po.navbar.logout ->
    if po.navbar.haveLogin()
      casper.test.fail 'Logout'
    else
      casper.test.pass 'Logout'

  casper.then -> po.welcome.login ->
    if po.navbar.haveLogin()
      casper.test.pass 'Login'
    else
      casper.die 'Login failed', 1

  casper.then casper.test.done