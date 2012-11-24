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

  it "model.count returns number of registered users", (done) ->
    User.model.create 'foo', 'barbaz', (err, user) ->
      expectedCount = user.id
      User.model.count (err, count) ->
        Should.not.exist err
        count.should.equal expectedCount
        done()

  it "can get multiple users with one request", (done) ->
    User.model.create 'asdf', 'qwer', ->
      User.model.create 'qwer', 'asdf', ->
        User.model.getMulti 1, 2, 3, (err, multiUsers) ->
          Should.not.exist err
          async.parallel (((cb) -> User.model.get id, cb) for id in [1,2,3]), (err, singleUsers) ->
            Should.not.exist err
            for i in [0,1,2]
              singleUsers[i].should.eql multiUsers[i]
            done()








