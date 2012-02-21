auth_path = SS.root + '/lib/server/auth_redis_bcrypt'
auth = require auth_path

exports.actions = 
  join: (channel, cb) ->
    @session.channel.subscribe channel
  
  send: ({msg, channel}, cb) ->
    auth.getUserData @session.user_id, (data) ->
      SS.publish.channel channel, 'msg', {from: data['nick'], msg: msg}

