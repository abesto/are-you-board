auth = require '../auth'
User = require '../../client/code/app/User'

credId = 0
cred = -> {nick: credId++, password:'pwd'}

describe 'BCrypt authentication', ->
  beforeEach (done) ->
    redis.flushdb done
    @cred = cred()

  it "reports error when user doesn't exist", (done) ->
    auth.authenticate {nick: 'nosuch', password:'nickname'}, (err, res) ->
      err.should.equal 'invalid_credentials'
      done()

  it "#authenticate succeeds with password set by #setPassword", (done) ->
    ss.rpc 'models.User.create', @cred.nick, @cred.password, ([err, rawUser]) =>
      should.not.exist err
      User.deserialize rawUser, (err, user) =>
        should.not.exist err
        auth.setPassword {user_id: user.id, password: 'password1'}, (err, res) =>
          should.not.exist err
          auth.authenticate {nick: @cred.nick, password: 'password1'}, done

  it '#authenticate succeeds with the password set by user creation via RPC', (done) ->
    ss.rpc 'models.User.create', 'nick', 'password0', ([err, rawUser]) =>
      should.not.exist err
      User.deserialize rawUser, (err, user) ->
        should.not.exist err
        auth.authenticate {nick: user.nick, password: 'password0'}, (err, res) =>
          should.not.exist err
          user.id.should.equal parseInt(res)
          done()

  it "#authenticate fails witn invalid password", (done) ->
    ss.rpc 'models.User.create', 'nick', 'password0', ([err, rawUser]) =>
      should.not.exist err
      User.deserialize rawUser, (err, user) ->
        should.not.exist err
        auth.authenticate {nick: user.nick, password:'notthis'}, (err, res) ->
          err.should.equal 'invalid_credentials'
          done()

