serialization = require './serialization'
model = require './model'

model class User
  constructor: (@id, @nick) -> null
  toString: -> "#{@id}:#{@nick}"

serialization User, 1,
  1:
    to: -> [@id, @nick]
    from: ([id, nick]) ->
      new User id, nick

module.exports = User
