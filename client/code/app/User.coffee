serialization = require './serialization'

class User
  constructor: (@id, @nick) -> null
  toString: -> "#{@id}:#{@nick}"

constants.apply User
model User

serialization User, 1,
  1:
    to: -> [@id, @nick]
    from: (user, [id, nick], cb) ->
      user.id = id
      user.nick = nick
      cb null, user

module.exports = User
