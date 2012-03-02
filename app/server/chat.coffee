# Backend of the chat demo

auth_path = SS.root + '/lib/server/auth_redis_bcrypt'
auth = require auth_path

async = require 'async'
A = require '../../lib/server/action_helpers'

A.actions module,
  join: (channel, cb) ->
    @session.channel.subscribe channel
    cb null, null
  
  send: ({msg, channel}, cb) ->
    async.waterfall [
      (      cb) => auth.getUserData @session.user_id, cb
      (user, cb) -> SS.publish.channel channel, 'msg', {from:user.nick, msg:msg}; cb null, null
    ], cb

