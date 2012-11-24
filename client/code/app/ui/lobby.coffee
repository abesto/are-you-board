Repository = require '/Repository'
User = require '/User'

$userList = null
$messageForm = null
$messageList = null
$messageInput = null
$sendInput = null

findControls = ->
  $userList = UI.$container.find '#lobby-user-list'
  $messageForm = UI.$container.find '#lobby-message-form'
  $messageList = $messageForm.find '#lobby-messages-list'
  $messageInput = $messageForm.find '#lobby-message-input'
  $sendInput = $messageForm.find '#lobby-send-input'


listenersConnected = false

connectListeners = ->
  return if listenersConnected
  ss.event.on 'User:disconnect', userDisconnectListener
  ss.event.on 'User:connect', userConnectListener
  ss.event.on 'lobby:message', messageListener
  listenersConnected = true

disconnectListeners = ->
  return unless listenersConnected
  ss.event.off 'User:disconnect', userDisconnectListener
  ss.event.off 'User:connect', userConnectListener
  ss.event.off 'lobby:message', messageListener
  listenersConnected = false


userDisconnectListener = (userId) ->
  $userList.find(".user-#{userId}").remove()
  Repository.delete userId

userConnectListener = (userId) ->
  Repository.get User, userId, (err, user) ->
    return alert err if err
    if $userList.find(".user-#{userId}").length == 0
      $userList.append ss.tmpl['lobby-userlistitem'].render user

messageListener = ([userId, message]) ->
  Repository.get User, userId, (err, user) ->
    return alert "Received message from non-existent user #{userId} (user get error: #{err})" if err
    alert "#{user.nick}: #{message}"


module.exports =
  render: ->
    UI.$container.empty().append ss.tmpl['lobby-index'].render()
    findControls()
    connectListeners()

    ss.rpc 'lobby.getOnlineUserIds', (err, ids) ->
      Repository.getMulti User, ids..., (err, users) ->
        $userList.prepend ss.tmpl['lobby-userlist'].render {users: users}, ss.tmpl

    $messageForm.submit (event) ->
      event.preventDefault()
      message = $messageInput.val().trimRight()
      return if message.length == 0
      ss.rpc 'lobby.message', message


  destroy: ->
    disconnectListeners()


