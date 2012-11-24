Repository = require '/Repository'
User = require '/User'

$userList = null

findControls = ->
  $userList = UI.$container.find '#lobby-user-list'

userDisconnectListener = (userId) ->
  $userList.find(".user-#{userId}").remove()
  Repository.delete userId

userConnectListener = (userId) ->
  Repository.get User, userId, (err, user) ->
    return alert err if err
    if $userList.find(".user-#{userId}").length == 0
      $userList.append ss.tmpl['lobby-userlistitem'].render user

module.exports =
  render: ->
    UI.$container.empty().append ss.tmpl['lobby-index'].render()
    findControls()

    ss.rpc 'lobby.getOnlineUserIds', (err, ids) ->
      Repository.getMulti User, ids..., (err, users) ->
        $userList.prepend ss.tmpl['lobby-userlist'].render {users: users}, ss.tmpl

    ss.event.on 'User:disconnect', userDisconnectListener
    ss.event.on 'User:connect', userConnectListener

  destroy: ->
    ss.event.off 'User:disconnect', userDisconnectListener
    ss.event.off 'User:connect', userConnectListener


