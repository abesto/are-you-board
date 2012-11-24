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

mustBeLoggedIn = {
  check: -> @req.session.userId
  msg: 'not_logged_in'
}

mustNotBeLoggedIn = {
  check: -> !@req.session.userId
  msg: 'already_logged_in'
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

# Game

Authorization.check 'Game.create', mustBeLoggedIn
Authorization.check 'Game.get', mustBeLoggedIn
Authorization.check 'Game.join', mustBeLoggedIn, onlySelf
Authorization.check 'Game.leave', mustBeLoggedIn, onlySelf
Authorization.check 'Game.start', mustBeLoggedIn,
  {
    check: (game) -> game.createdBy == parseInt(@req.session.userId)
    msg: 'not_owner'
    meta: (game) -> owner: game.createdBy
  }
Authorization.check 'Game.rollDice', mustBeLoggedIn, inGame, currentPlayer
Authorization.check 'Game.move', mustBeLoggedIn, inGame, currentPlayer,
  {
    check: (game, piece) -> piece.player == parseInt(@req.session.userId)
    msg: 'not_own_piece'
    meta: (game, piece) -> owner: piece.player
  }
Authorization.check 'Game.skip', mustBeLoggedIn, inGame, currentPlayer
Authorization.check 'Game.startPiece', mustBeLoggedIn, inGame, currentPlayer

# User

Authorization.check 'User.create', mustNotBeLoggedIn
Authorization.check 'User.login', mustNotBeLoggedIn
Authorization.check 'User.logout', mustBeLoggedIn

# Lobby

Authorization.check 'lobby.listUsers', mustBeLoggedIn
Authorization.check 'lobby.message', mustBeLoggedIn

module.exports = Authorization
