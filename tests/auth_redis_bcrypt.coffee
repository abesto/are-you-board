auth = require '../lib/server/auth_redis_bcrypt'

credId = 0
cred = -> {nick: credId++, password:'pwd'}

module.exports =
  'Error: User not found': (test) ->
    test.expect 1
    auth.authenticate {nick: 'nosuch', password:'nickname'}, (res) ->
      test.deepEqual {success:false, info:'User not found.'}, res
      test.done()

  'Registration increments users id': (test) ->
    test.expect 2
    R.get 'users:id', (err, oldId) ->
      auth.register cred(), (res) ->
        test.equal true, res.success
        test.ok res.user_id > oldId
        test.done()

  'Authentication': (test) ->
    test.expect 2
    credentials = cred()
    auth.register credentials, (res) ->
      test.equal true, res.success
      auth.authenticate credentials, (res) ->
        test.equal true, res.success
        test.done()

  'Invalid password': (test) ->
    test.expect 2
    credentials = cred()
    auth.register credentials, (res) ->
      test.equal true, res.success
      auth.authenticate {nick:credentials.nick, password:'notthis'}, (res) ->
        test.deepEqual {success:false, info:'Invalid password.'}, res
        test.done()

  'Nick already exists': (test) ->
    test.expect 2
    credentials = cred()
    auth.register credentials, (res) ->
      test.equal true, res.success
      auth.register credentials, (res) ->
        test.deepEqual {success:false, info:'Sorry, that nick is already taken.'}, res
        test.done()

  'Change password': (test) ->
    test.expect 3
    credentials = cred()
    auth.register credentials, (res) ->
      test.equal true, res.success, 'Registering'
      auth.setPassword res.user_id, 'newpwd', (res) ->
        test.equal true, res.success, 'Changing the password'
        auth.authenticate {nick:credentials.nick, password:'newpwd'}, (res) ->
          test.equal true, res.success, 'Authentication after the password is changed'
          test.done()