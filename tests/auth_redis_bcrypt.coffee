auth = require '../lib/server/auth_redis_bcrypt'

credId = 0
cred = -> {nick: credId++, password:'pwd'}

module.exports =
  'Error: User not found': (test) ->
    test.expect 1
    auth.authenticate {nick: 'nosuch', password:'nickname'}, (err, res) ->
      test.equal 'User not found.', err 
      test.done()

  'Registration doesn\'t return hash': (test) ->
    test.expect 2
    credentials = cred()
    auth.register credentials, (err, user) ->
      test.equal null, err
      test.ok user.hash is undefined
      test.done()

  'Registration increments users id, sets nick': (test) ->
    test.expect 3
    credentials = cred()
    R.get 'users:id', (err, oldId) ->
      auth.register credentials, (err, user) ->
        test.equal null, err
        test.ok user.user_id > oldId
        test.equal credentials.nick, user.nick
        test.done()

  'getUserData returns nick and id': (test) ->
    test.expect 4
    credentials = cred()
    auth.register credentials, (err, user) ->
      test.equal null, err
      auth.getUserData user.user_id, (err, res) ->
        test.equal null, err
        test.equal user.user_id, res.user_id
        test.equal user.nick, res.nick
        test.done()

  'Authentication returns the user id': (test) ->
    test.expect 3
    credentials = cred()
    auth.register credentials, (err, user) ->
      test.equal null, err
      auth.authenticate credentials, (err, res) ->
        test.equal null, err
        test.equal user.user_id, res
        test.done()

  'Invalid password': (test) ->
    test.expect 2
    credentials = cred()
    auth.register credentials, (err, res) ->
      test.equal null, err
      auth.authenticate {nick:credentials.nick, password:'notthis'}, (err, res) ->
        test.equal 'Invalid password.', err
        test.done()

  'Nick already exists': (test) ->
    test.expect 2
    credentials = cred()
    auth.register credentials, (err, res) ->
      test.equal null, err
      auth.register credentials, (err, res) ->
        test.equal 'Sorry, that nick is already taken.', err
        test.done()

  'Change password': (test) ->
    test.expect 3
    credentials = cred()
    auth.register credentials, (err, res) ->
      test.equal null, err
      auth.setPassword {user_id:res.user_id, password:'newpwd'}, (err, res) ->
        test.equal null, err
        auth.authenticate {nick:credentials.nick, password:'newpwd'}, (err, res) ->
          test.equal null, err
          test.done()