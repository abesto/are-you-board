# Within your web app's UI there are areas that your tests interact with.
# A Page Object simply models these as objects within the test code. This 
# reduces the amount of duplicated code and means that if the UI changes, 
# the fix need only be applied in one place. 
#
#    - https://code.google.com/p/selenium/wiki/PageObjects

# Work around https://github.com/n1k0/casperjs/issues/63 by using evaluate

tabSelectors =
  editor: '#create-game'
  chat: 'input[name=input-msg]'

nick = 'casper'
password = 'casper'

module.exports = (casper) -> m = 
  run: (cb) -> 
    cb.call(casper)
    casper.run()

  waitForLoginForm: ->
    casper.waitForSelector '.login-form'

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
      casper.evaluate -> $('#logout').click()
      casper.waitFor (-> not m.navbar.haveLogin()), cb

    haveLogin: -> nick == casper.evaluate -> $('#current-user-nick').text()

    toTab: (name, cb) ->
      casper.evaluate ((name) -> $('#' + name).click()), name:name
      casper.waitForSelector tabSelectors[name], cb
      
  editor:
    save: ->
      casper.click '#general .btn.save'
      casper.waitForSelector '.alert-success'

    list:
      createGame: (cb) ->
        casper.click '#create-game'
        casper.waitForSelector '.editor', cb

      edit: (id, cb) ->
        casper.evaluate ((id) -> $(".game-list [rel=#{id}] .edit").click()), id:id
        casper.waitForSelector '.editor', cb

      get: (id) ->
        casper.evaluate ((id) ->
          $row = $(".game-list [rel=#{id}]")
          return "" if $row.length == 0
          return {
            name: $row.find('td.name').text()
            description: $row.find('td.description').text()
            lastModified: $row.find('td.last-modified').attr('rel')
          }), id:id

      delete: (id, cb) ->
        casper.evaluate ((id) -> $(".game-list [rel=#{id}] .delete").click()), id:id
        casper.waitUntilVisible '.delete-dialog', ->
          casper.click '.btn[rel=delete]'
          casper.waitWhileVisible '.delete-dialog', cb

    game:
      here: -> casper.exists 'span.game-id'
      rename: (name, cb) -> 
        casper.fill 'form', name:name
      describe: (desc, cb) -> casper.fill 'form', description:desc
      getId: -> casper.evaluate -> $('span.game-id').text()
