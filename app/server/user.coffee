# User registration, login, logout and profile editing
# Authentication is implemented in lib/server/auth_redis_bcrypt

auth_path = SS.root + '/lib/server/auth_redis_bcrypt'
auth = require auth_path

exports.actions =
  register: (nick, password, cb) -> auth.register {nick: nick, password: password}, cb
  login: (nick, password, cb) -> 
    @session.authenticate auth_path, {nick: nick, password: password}, (response) =>
      @session.setUserId response.user_id if response.success
      cb response
  setPassword: (password, cb) -> auth.setPassword @session.user_id, password, cb
  logout: (cb) -> @session.user.logout cb
  getCurrentUser: (cb) -> 
    if @session.user_id
      auth.getUserData @session.user_id, cb
    else
      cb null
  getUserData: (id, cb) -> auth.getUserData id, cb

