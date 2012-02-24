# Check the value of field on $form with validators
# Show appropriate alert in $form .alerts if a validator failed
# Return the sanitized input value
validate = (field, $form, validators...) ->
  res = RUB.V.validate($form.find("[name=#{field}]").val(), validators...)
  return res.sanitized if res.valid
  $form.find('.alerts').html $('#common-alert').tmpl
    normal: res.info
  return false 

# Show login form
exports.loginForm = loginForm = (cb) ->
  $form = $('#user-login').tmpl()
  $form.submit ->
    SS.server.user.login $form.find('[name=nick]').val(), $form.find('[name=password]').val(), (res) ->
      if not res.success
        $form.find('.alerts').html $('#common-alert').tmpl
          normal: res.info
      else
        $form.remove()
        SS.client.user.getCurrentUser cb
    false
  RUB.$content.html $form
  $form.find('[name=register]').click -> registerForm cb

# Show registration form
registerForm = (cb) ->
  $form = $('#user-register').tmpl()

  $form.find('[name=back]').click ->
    $form.remove()
    loginForm cb

  $form.submit ->
    # Validate nickname length, no spaces
    return false unless nick = validate(
      'nick', $form, RUB.V.trim(),
      RUB.V.longer(3, 'Nick must be longer than 3 characters.'), 
      RUB.V.doesntContain(' ', 'Nick mustn\'t contain spaces.')
    )

    # Validate password length
    return false unless password = validate(
      'password', $form, RUB.V.longer(3, 'Password must be longer than 3 characters.')
    )

    # Validate that passwords match
    return false unless password2 = validate(
      'password2', $form, RUB.V.equals(password, 'Please make sure the passwords match.')
    )

    # Register user
    SS.server.user.register nick, password, (res) ->
      if not res.success
        # Server refused the request
        $form.find('.alerts').html $('#common-alert').tmpl
          normal: res.info
      else
        # Registration succeeded, log the user in
        $form.remove()
        SS.server.user.login nick, password, ->
          SS.client.user.getCurrentUser cb
    false

  RUB.$content.html $form

# Show edit profile view
exports.edit = ->
  $form = $('#user-edit').tmpl user: RUB.user
  $form.find('[name=password]').focus()
  RUB.$content.html $form
  $form.submit ->
    return false unless password = validate(
      'password', $form, RUB.V.longer(3, 'Password must be longer than 3 characters.')
    )
    password2 = $form.find('[name=password2]').val()
    if password != password2
      $form.find('.alerts').html $('#common-alert').tmpl
        normal: 'Please make sure the passwords match.'
      return false
    SS.server.user.setPassword password, ({success, info}) ->
      if not success then $form.find('.alerts').html $('#common-alert').tmpl
        normal: info
      else $form.find('.alerts').html(
        $('#common-alert')
        .tmpl(normal: 'Your password has been changed.')
        .addClass('alert-success')
      )
    false

# Update RUB.user with the currently logged in user and pass it to cb
exports.getCurrentUser = (cb) ->
  SS.server.user.getCurrentUser (res) ->
    RUB.user = res
    cb? res

