casper.po.run ->
  @then -> @test.comment "Registration, logout, login"
  @then -> @po.welcome.register()

  @then ->
    if @po.navbar.haveLogin()
      @test.pass 'Registration completed, logged in automatically'
    else
      @test.fail 'Registration failed'
      @po.welcome.login ->
        if @po.navbar.haveLogin()
          @test.info "Login succeeded, running remaining tests"
        else
          @die 'Login failed', 1

  @then -> @po.navbar.logout -> @test.assertNot @po.navbar.haveLogin(), 'Logout'
  @then -> @po.welcome.login -> @test.assert @po.navbar.haveLogin(), 'Login'
  @then -> @test.done()
