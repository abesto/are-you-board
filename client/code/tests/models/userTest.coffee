User = require '/User'

QUnit.module 'server.models.user'

asyncTest 'can create a new user', 2, ->
  nick = 'testuser' + (new Date()).getTime()
  User.model.create nick, (err, user) ->
    ok user instanceof User
    strictEqual user.nick, nick
    start()