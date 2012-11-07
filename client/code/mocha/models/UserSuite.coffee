User = require '/User'

describe 'User RPC', ->
  before (done) ->
    @nick = 'testuser' + (new Date()).getTime()
    @password = 'testpassword'
    User.model.create @nick, @password, (err, @user) =>
      done err, @user

  it 'can create a new user', ->
    @user.should.be.an.instanceof User
    @user.nick.should.equal @nick

  it "requires nick to create a user", (done) ->
    User.model.create (err) ->
      err.should.equal 'nick_required'
      User.model.create '', (err) ->
        err.should.equal 'nick_required'
        User.model.create null, (err) ->
          err.should.equal 'nick_required'
          done()

  it "refuses \":\" in the nick", (done) ->
    User.model.create 'a:b', (err) ->
      err.should.equal 'nick_forbidden_char :'
      done()

  it "requires a password at least 3 characters long to create a user", (done) ->
    User.model.create '3char', 'aa', (err) ->
      err.should.equal 'password_too_short'
      done()

  it "adds the user to the 'users_by_nick' hash", (done) ->
    ss.rpc 'dangerous.redis', 'hget', 'users_by_nick', @nick, (err, id) =>
      @user.id.should.equal parseInt(id)
      done()

  it "returns error not_logged_in if there's no logged in user", (done) ->
    User.model.getCurrent (err) ->
      err.should.equal 'not_logged_in'
      done()

  it "returns user after successful login, remembers it, can log out", (done) ->
    User.model.login @nick, @password, (err, user) =>
      @user.id.should.equal user.id
      User.model.getCurrent (err, user) =>
        @user.id.should.equal user.id
        User.model.logout -> User.model.getCurrent (err) ->
          err.should.equal 'not_logged_in'
          done()






