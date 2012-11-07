serialization = require './serialization'

class User
  constructor: (@id, @nick) -> null
  toString: -> "#{@id}:#{@nick}"

constants.apply User
model User

User.model.login = (nick, password, cb) ->
  ss.rpc 'models.User.login', nick, password, (err, res) ->
    return cb err if err
    User.deserialize res, cb

User.model.logout = (cb) -> ss.rpc 'models.User.logout', cb

User.model.getCurrent = (cb) ->
  ss.rpc 'models.User.getCurrent', (err, res) ->
    return cb err if err
    User.deserialize res, cb


serialization User, 1,
  1:
    to: -> [@id, @nick]
    from: (user, [id, nick], cb) ->
      user.id = id
      user.nick = nick
      cb null, user

module.exports = User
