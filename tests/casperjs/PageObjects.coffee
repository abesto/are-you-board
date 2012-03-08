# Within your web app's UI there are areas that your tests interact with.
# A Page Object simply models these as objects within the test code. This 
# reduces the amount of duplicated code and means that if the UI changes, 
# the fix need only be applied in one place. 
#
#    - https://code.google.com/p/selenium/wiki/PageObjects

tabSelectors =
  selectors =
    editor: '#create-game'
    chat: 'input[name=input-msg]'

nick = 'casper'
password = 'casper'

module.exports = (casper) -> m = 
  waitForInitialLoading: (cb) ->
    casper.waitForSelector '.login-form', cb

  welcome:
    login: (cb) ->
      doLogin = ->
        casper.fill '.login-form',
          nick: 'casper'
          password: 'casper'
        casper.click 'input[name=login]'
        casper.waitFor m.navbar.haveLogin, cb
      if casper.exists 'input[name=back]'
        casper.click 'input[name=back]'
        casper.waitForSelector '.login-form', doLogin
      else
        doLogin()

    register: ->
      doRegister = ->
        casper.fill '.register-form',
          nick: nick
          password: password
          password2: password
        casper.click 'input[name=register]'
        casper.waitFor -> m.navbar.haveLogin() or casper.exists('.alert')
      if casper.exists 'input[name=register]'
        casper.click 'input[name=register]'
        casper.waitForSelector '.register-form', doRegister
      else
        doRegister()

  navbar:
    logout: (cb) ->
      casper.click '#logout'
      casper.waitFor (-> not m.navbar.haveLogin()), cb

    haveLogin: -> nick == casper.evaluate -> $('#current-user-nick').text()

    toTab: (name, cb) ->
      casper.click "#{name}"
      casper.waitForSelector Navbar.tabSelectors[name], cb
      
