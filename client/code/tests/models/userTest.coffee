User = require '/User'

QUnit.module 'server.models.user'

test 'can create a new user', ->
  stop()
  nick = 'testuser' + (new Date()).getTime()
  User.model.create nick, (err, user) ->
    ok user instanceof User
    strictEqual user.nick, nick
    start()