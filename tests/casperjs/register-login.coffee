exports.run = (casper) ->
  casper.then -> @waitForSelector 'input[name=register]', -> @test.comment 'Application loaded'
  casper.then ->
    @click 'input[name=register]'
    @waitForSelector 'input[name=password2]'

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

  casper.then -> @test.assertEval (-> $('#current-user-nick').text() == 'casper'), 'Username appears in the navbar'
