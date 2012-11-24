User = require '/User'

showLoginForm = ->
  UI.$container.empty().append ss.tmpl['login'].render()
  $signinForm = $('form.form-signin')
  $alert = $signinForm.find('.alert')
  $nick = $signinForm.find('input[name=nick]').focus()
  $password = $signinForm.find('input[name=password]')

  alert = (str) -> $alert.show().text(str)

  $signinForm.submit (event) ->
    event.preventDefault()
    nick = $nick.val()
    password = $password.val()
    User.model.login nick, password, (err, user) ->
      window.user = user
      return alert err if err
      ss.heartbeatStart()
      UI.init(user)

  $signinForm.find('[name=register]').click showRegisterForm

showRegisterForm = ->
  UI.$container.empty().append ss.tmpl['register'].render()
  $registerForm = $('form.form-register')
  $alert = $registerForm.find('.alert')
  $nick = $registerForm.find('input[name=nick]').focus()
  $password = $registerForm.find('input[name=password]')
  $passwordAgain = $registerForm.find('input[name=password-again]')

  alert = (str) -> $alert.show().text(str)

  $registerForm.submit (event) ->
    nick = $nick.val()
    password = $password.val()
    passwordAgain = $passwordAgain.val()
    event.preventDefault()
    if password != passwordAgain
      return alert 'Passwords must match!'
    User.model.create nick, password, (err) ->
      return alert err if err
      User.model.login nick, password, (err, user) ->
        return alert err if err
        ss.heartbeatStart()
        window.user = user
        UI.init(user)

  $registerForm.find('[name=back]').click showLoginForm


module.exports =
  logout: (event) ->
    event.preventDefault()
    ss.heartbeatStop()
    User.model.logout (err) ->
      return alert err if err
      UI.reset()

  renderLogin: showLoginForm

