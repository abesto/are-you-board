validate = (field, $form, validators...) ->
  res = RUB.V.validate($form.find("[name=#{field}]").val(), validators...)
  return res.sanitized if res.valid
  $form.find('.alerts').html $('#common-alert').tmpl
    normal: res.info
  return false 

loginForm = (cb) ->
  $form = $('#user-login').tmpl()
  $form.submit ->
    SS.server.user.login $form.find('[name=nick]').val(), $form.find('[name=password]').val(), (res) ->
      if not res.success
        $form.find('.alerts').html $('#common-alert').tmpl
          strong: 'Oops!'
          normal: res.info
      else
        SS.server.user.getCurrentUser cb
    false
  RUB.content.html $form
  $form.find('[name=register]').click registerForm

registerForm = (cb) ->
  $form = $('#user-register').tmpl()
  $form.find('[name=back]').click loginForm
  $form.submit ->
    return unless nick = validate(
      'nick', $form, RUB.V.trim(),
      RUB.V.longer(3, 'Nick must be longer than 3 characters.'), 
      RUB.V.doesntContain(' ', 'Nick mustn\'t contain spaces.')
    )
    return unless password = validate(
      'password', $form, 
      RUB.V.longer(3, 'Password must be longer than 3 characters.')
    )
    password2 = $form.find('[name=password2]').val()
    if password != password2
      return $form.find('.alerts').html $('#common-alert').tmpl
        normal: 'Please make sure the passwords match.'
    SS.server.user.register nick, password, (res) ->
      if not res.success
        $form.find('.alerts').html $('#common-alert').tmpl
          strong: 'Oops!'
          normal: res.info
      else
        SS.server.user.login nick, password, cb
    false

  RUB.content.html $form

exports.init = loginForm