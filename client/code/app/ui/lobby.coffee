Repository = require '/Repository'
User = require '/User'

$userList = null
$messageForm = null
$messageListContainer = null
$messageList = null
$messageInput = null
$sendInput = null

findControls = ->
  $userList = UI.$container.find '#lobby-user-list'
  $messageListContainer = UI.$container.find '#lobby-messages-list-container'
  $messageList = UI.$container.find '#lobby-messages-list'
  $messageForm = UI.$container.find '#lobby-message-form'
  $messageInput = $messageForm.find '#lobby-message-input'
  $sendInput = $messageForm.find '#lobby-send-input'


listenersConnected = false

connectListeners = ->
  winston.debug 'connectListeners', 'start'
  if listenersConnected
    winston.verbose 'connectListeners', 'already_connected'
    return
  ss.event.on 'User:disconnect', userDisconnectListener
  ss.event.on 'User:connect', userConnectListener
  ss.event.on 'lobby:message', messageListener
  listenersConnected = true
  winston.debug 'connectListeners', 'finish'

disconnectListeners = ->
  winston.debug 'disconnectListeners', 'start'
  unless listenersConnected
    winston.verbose 'disconnectListeners', 'already_not_connected'
    return
  ss.event.off 'User:disconnect', userDisconnectListener
  ss.event.off 'User:connect', userConnectListener
  ss.event.off 'lobby:message', messageListener
  listenersConnected = false
  winston.debug 'disconnectListeners', 'finish'


userDisconnectListener = (userId) ->
  winston.debug 'userDisconnected', userId
  $userList.find(".user-#{userId}").remove()
  Repository.delete userId

userConnectListener = (userId) ->
  winston.debug 'userConnected', userId
  Repository.get User, userId, (err, user) ->
    return alert err if err
    if $userList.find(".user-#{userId}").length == 0
      $userList.append ss.tmpl['lobby-userlistitem'].render user

messageListener = ([userId, message, timestamp]) ->
  winston.debug 'message_received', userId, message, timestamp
  Repository.get User, userId, (err, user) ->
    return alert "Received message from non-existent user #{userId} (user get error: #{err})" if err
    $messageList.append ss.tmpl['lobby-message'].render from: user.nick, time: moment(timestamp).format('HH:mm:ss'), text: message
    $messageListContainer.scrollTop($messageList.height())


module.exports =
  render: ->
    UI.$container.empty().append ss.tmpl['lobby-index'].render()
    findControls()
    connectListeners()
    $messageInput.focus()
    $messageListContainer.height $(window).height() - 80

    ss.rpc 'lobby.getOnlineUserIds', (err, ids) ->
      winston.debug 'got_online_user_ids', ids.join(',')
      Repository.getMulti User, ids..., (err, users) ->
        $userList.prepend ss.tmpl['lobby-userlist'].render {users: users}, ss.tmpl

    $messageForm.submit (event) ->
      event.preventDefault()
      message = $messageInput.val().trimRight()
      return if message.length == 0
      $messageInput.val('')
      ss.rpc 'lobby.message', message


  destroy: ->
    disconnectListeners()


