User = require '/User'

suite 'User model', ->
  test 'can create a new user', (done) ->
    nick = 'testuser' + (new Date()).getTime()
    User.model.create nick, (err, user) ->
      user.should.be.an.instanceof User
      user.nick.should.equal nick
      done()
