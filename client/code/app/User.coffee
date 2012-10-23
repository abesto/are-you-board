serialization = require './serialization'
model = require './model'

class User
  constructor: (@id, @nick) -> null
  toString: -> "#{@id}:#{@nick}"

serialization User, 1,
  1:
    to: -> [@id, @nick]
    from: ([id, nick]) ->
      new User id, nick

model User, 'user'

module.exports = User
