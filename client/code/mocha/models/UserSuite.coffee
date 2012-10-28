User = require '/User'

suite 'User model', ->
  test 'can create a new user', (done) ->
    nick = 'testuser' + (new Date()).getTime()
    User.model.create nick, (err, user) ->
      user.should.be.an.instanceof User
      user.nick.should.equal nick
      done()

  test "can't create a user without nickname", (done) ->
    User.model.create (err) ->
      err.should.equal 'nick_required'
      User.model.create '', (err) ->
        err.should.equal 'nick_required'
        User.model.create null, (err) ->
          err.should.equal 'nick_required'
          done()

  test "nick can't contain \":\"", (done) ->
    User.model.create 'a:b', (err) ->
      err.should.equal 'nick_forbidden_char :'
      done()
