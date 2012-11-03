auth = require '../auth'
require('../setup').loadAppGlobals()
require('../setup').loadTestGlobals()

credId = 0
cred = -> {nick: credId++, password:'pwd'}

describe 'BCrypt authentication', ->
  beforeEach (done) ->
    redis.flushdb done
    @cred = cred()

  it "reports error when user doesn't exist", (done) ->
    auth.authenticate {nick: 'nosuch', password:'nickname'}, (err, res) ->
      err.should.equal 'User not found.'
      done()

  it "allows setting of a "

  it 'recognizes correct password': (done) ->
    auth.register @cred, (err, user) ->
      should.not.exist err
      auth.authenticate @cred, (err, res) ->
        should.not.exist err
        user.id.shoul
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
