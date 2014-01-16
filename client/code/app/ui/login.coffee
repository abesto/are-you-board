User = require '/User'
routes = require '/ui/routes'

showLoginForm = (successCb) ->
  UI.$container.empty().append ss.tmpl['login'].render()
  $signinForm = $('form.form-signin')
  $alert = $signinForm.find('.alert')
  $nick = $signinForm.find('input[name=nick]').focus()
  $password = $signinForm.find('input[name=password]')

  alert = (str) -> $alert.text(str).removeClass('hidden')

  $signinForm.submit (event) ->
    event.preventDefault()
    nick = $nick.val()
    password = $password.val()
    User.model.login nick, password, (err, user) ->
      return alert err if err
      ss.heartbeatStart()
      window.user = user
      UI.init(user)
      successCb()

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
        routes.navigate routes.index

  $registerForm.find('[name=back]').click showLoginForm

buildSuccessCallback = (redirectTo) -> ->
  if redirectTo
    hasher.setHash routes.unslugifySegment(redirectTo)
  else
    routes.navigate routes.lobby

exports.bindRoutes = ->
  routes.login.matched.add (redirectTo) ->
    successCb = buildSuccessCallback(redirectTo)
    if window.user
      successCb()
    else
      showLoginForm(successCb)

  routes.logout.matched.add ->
    ss.heartbeatStop()
    User.model.logout (err) ->
      return alert err if err
      delete window.user
      UI.reset()
