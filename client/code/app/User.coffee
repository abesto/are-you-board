serialization = require './serialization'

model class User
  constructor: (@id, @nick) -> null
  toString: -> "#{@id}:#{@nick}"

serialization User, 1,
  1:
    to: -> [@id, @nick]
    from: (user, [id, nick]) ->
      user.id = id
      user.nick = nick

module.exports = User
