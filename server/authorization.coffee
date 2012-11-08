class Authorization
  constructor: (@req) ->

  @check = (name, items...) ->
    Authorization.prototype[name] = (args...) ->
      return [true] if @req.session.isSuperuser
      for item in items
        continue if item.check.apply this, args
        if _.isFunction item.meta
          meta = item.meta.apply this, args
        else if not _.isUndefined item.meta
          meta = item.meta
        else
          meta = {}
        item.meta ?= {}
        item.meta.user = @req.session.userId
        item.meta.method = name
        return [false, item.msg, meta]
      [true]

  check: (name, args...) -> this[name] args...

loginRequired = {
  check: -> @req.session.userId
  msg: 'not_logged_in'
}

sameUser = {
  check: (user) -> user.id == @req.session.userId
  msg: 'wrong_user'
  meta: (user) -> otherUser: user.id
}

inGame = {
  check: (game) -> game.isUserPlaying @req.session.userId
  msg: 'not_in_game'
  meta: (game) -> game: game.id
}

Authorization.check 'Game.create', loginRequired
Authorization.check 'Game.join', loginRequired, sameUser
Authorization.check 'Game.leave', loginRequired, sameUser
Authorization.check 'Game.start', loginRequired,
  {
    check: (game) -> game.createdBy == @req.session.userId
    msg: 'not_owner'
    meta: (game) -> owner: game.createdBy
  }
Authorization.check 'Game.rollDice', loginRequired, inGame
Authorization.check 'Game.move', loginRequired, inGame
Authorization.check 'Game.skip', loginRequired, inGame
Authorization.check 'Game.startPiece', loginRequired, inGame

module.exports = Authorization
