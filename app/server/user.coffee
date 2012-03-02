# User registration, login, logout and profile editing
# Authentication is implemented in lib/server/auth_redis_bcrypt

auth_path = SS.root + '/lib/server/auth_redis_bcrypt'
auth = require auth_path

A = SS.require 'action_helpers'

A.actions
  register: auth.register
  login: ({nick, password}, cb) ->
    @session.authenticate auth_path, {nick: nick, password: password}, (response) =>
      @session.setUserId response.user_id if response.success
      cb response
  setPassword: (password, cb) -> auth.setPassword {user_id:@session.user_id, password:password}, cb
  logout: (cb) -> @session.user.logout cb
  getCurrentUser: (cb) -> 
    if @session.user_id
      auth.getUserData @session.user_id, cb
    else
      cb 'No active login', null
  getUserData: auth.getUserData

