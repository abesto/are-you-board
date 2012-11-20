class Authorization
  enabled: true
  @disable: -> Authorization.enabled = false
  @enable: -> Authorization.enabled = true

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
        item.meta.user = parseInt(@req.session.userId)
        item.meta.method = name
        return [false, item.msg, meta]
      [true]

  check: (name, args...) -> this[name] args...

  checkRes: (res, name, args...) ->
    checkResult = @check name, args...
    return true if checkResult[0] or not Authorization.enabled
    res checkResult[1]
    return false

loginRequired = {
  check: -> @req.session.userId
  msg: 'not_logged_in'
}

onlySelf = {
  check: (user) -> user.id == parseInt(@req.session.userId)
  msg: 'wrong_user'
  meta: (user) -> otherUser: user.id
}

currentPlayer = {
  check: (game) -> game.players[game.currentSide].id == parseInt(@req.session.userId)
  msg: 'not_current_player'
  meta: (game) -> currentPlayer: game.players[game.currentSide].id
}

inGame = {
  check: (game) -> game.isUserIdPlaying parseInt(@req.session.userId)
  msg: 'not_in_game'
  meta: (game) -> game: game.id
}

Authorization.check 'Game.create', loginRequired
Authorization.check 'Game.get', loginRequired
Authorization.check 'Game.join', loginRequired, onlySelf
Authorization.check 'Game.leave', loginRequired, onlySelf
Authorization.check 'Game.start', loginRequired,
  {
    check: (game) -> game.createdBy == parseInt(@req.session.userId)
    msg: 'not_owner'
    meta: (game) -> owner: game.createdBy
  }
Authorization.check 'Game.rollDice', loginRequired, inGame, currentPlayer
Authorization.check 'Game.move', loginRequired, inGame, currentPlayer,
  {
    check: (game, piece) -> piece.player == parseInt(@req.session.userId)
    msg: 'not_own_piece'
    meta: (game, piece) -> owner: piece.player
  }
Authorization.check 'Game.skip', loginRequired, inGame, currentPlayer
Authorization.check 'Game.startPiece', loginRequired, inGame, currentPlayer

module.exports = Authorization
