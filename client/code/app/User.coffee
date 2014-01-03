serialization = require './serialization'

class User
  @_name = 'User'

  constructor: (@id, @nick) ->
    @registeredAt = new Date()
    @isSuperuser = false

  toString: -> "User(id=#{@id},nick=#{@nick})"

constants.apply User

serialization User, 1,
  1:
    to: -> [@id, @nick, @registeredAt.getTime(), @isSuperuser]
    from: (user, [id, nick, registeredAt, isSuperuser], cb) ->
      user.id = id
      user.nick = nick
      user.registeredAt = new Date registeredAt
      user.isSuperuser = isSuperuser
      cb null, user

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


module.exports = User
