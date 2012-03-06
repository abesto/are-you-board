exports.run = (casper) ->
  # Wait for app to load
  casper.then -> @waitForSelector '.login-form', -> @test.comment 'Application loaded'
  # Go to registration form
  casper.then ->
    @click 'input[name=register]'
    @waitForSelector '.register-form'

  # Register
  casper.then ->
    @fill '.register-form',
      nick: 'casper'
      password: 'casper'
      password2: 'casper'
    @click 'input[name=register]'
  casper.then -> @waitFor -> @exists('#logout') or @exists('.alert')
  casper.then ->
    if @exists '#chat'
      @test.pass 'Registration completed, logged in automatically'
    else
      @die 'User "casper" is already registered, but I want to test registration; do something please.', 1

  # Check that the UI shows the nickname
  casper.then -> @test.assertEval (-> $('#current-user-nick').text() == 'casper'), 'Username appears in the navbar'

  # Logout, login
  casper.then -> casper.click '#logout'
  casper.then -> @waitForSelector '.login-form', -> @test.pass 'Logout redirected to login form'
  casper.then -> 
    @fill '.login-form',
      nick: 'casper'
      password: 'casper'
    @click 'input[name=login]'
    @waitForSelector '#logout'

  casper.then -> @test.pass 'Login worked'

  # Check that the UI still shows the nickname
  casper.then -> @test.assertEval (-> $('#current-user-nick').text() == 'casper'), 'Username still appears in the navbar'
