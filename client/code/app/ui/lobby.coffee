Repository = require '/Repository'
User = require '/User'
routes = require '/ui/routes'

$userList = null
$messageForm = null
$messageListContainer = null
$messageList = null
$messageInput = null
$sendInput = null

formatMessageDate = (date, format='HH:mm:ss') -> moment(date).format(format)

findControls = ->
  $userList = UI.$container.find '#lobby-user-list'
  $messageListContainer = UI.$container.find '#lobby-messages-list-container'
  $messageList = UI.$container.find '#lobby-messages-list'
  $messageForm = UI.$container.find '#lobby-message-form'
  $messageInput = $messageForm.find '#lobby-message-input'
  $sendInput = $messageForm.find '#lobby-send-input'


listenersConnected = false

logger = winston.getLogger 'ui.lobby'

connectListeners = ->
  logger.debug 'connectListeners_start'
  if listenersConnected
    logger.verbose 'lobby.connectListeners_already_connected'
    return
  ss.event.on 'User:disconnect', userDisconnectListener
  ss.event.on 'User:connect', userConnectListener
  ss.event.on 'lobby:message', messageListener
  listenersConnected = true
  logger.debug 'connectListeners_finish'

disconnectListeners = ->
  logger.debug 'disconnectListeners_start'
  unless listenersConnected
    logger.verbose 'disconnectListeners_already_not_connected'
    return
  ss.event.off 'User:disconnect', userDisconnectListener
  ss.event.off 'User:connect', userConnectListener
  ss.event.off 'lobby:message', messageListener
  listenersConnected = false
  logger.debug 'disconnectListeners_finish'


userDisconnectListener = (userId) ->
  logger.debug 'userDisconnected', {userId: userId}
  $userList.find(".user-#{userId}").remove()
  Repository.delete userId

isUserInUserList = (userId) ->
  count = $userList.find(".user-#{userId}").length
  logger.warn("multiple_user_occurences_in_userlist userId=#{userId} count=#{count}") if count > 1
  return count > 0

userConnectListener = (userId) ->
  logger.debug 'userConnected', {userId: userId}
  Repository.get User, userId, (err, user) ->
    return alert err if err
    $userList.append ss.tmpl['lobby-userlistitem'].render user unless isUserInUserList(userId)

messageListener = ([userId, message, timestamp]) ->
  Repository.get User, userId, (err, user) ->
    if err
      logger.warn 'message_received_from_nonexistent_user', {userId: userId, message: message, timestamp: timestamp, err: err}
      user = {nick: ''}
    logger.debug 'message_received', {senderId: user.id, senderNick: user.nick, message: message, timestamp: timestamp}
    $messageList.append ss.tmpl['lobby-message'].render from: user.nick, time: formatMessageDate(timestamp), text: message
    $messageListContainer.scrollTop($messageList.height())


exports.bindRoutes = ->
  routes.lobby.matched.add ->
    UI.$container.empty().append ss.tmpl['lobby-index'].render {renderedAt: formatMessageDate(new Date())}
    findControls()
    connectListeners()
    $messageInput.focus()
    $messageListContainer.height $(window).height() - 140

    ss.rpc 'lobby.getOnlineUserIds', (err, ids) ->
      logger.debug 'got_online_user_ids', {userIds: ids}
      Repository.getMulti User, ids..., (err, users) ->
        users = _.reject(users, (u) -> isUserInUserList(u.id))
        $userList.prepend ss.tmpl['lobby-userlist'].render {users: users}, ss.tmpl

    $messageForm.submit (event) ->
      event.preventDefault()
      message = $messageInput.val().trimRight()
      return if message.length == 0
      $messageInput.val('')
      logger.debug 'sending_message', {message: message}
      ss.rpc 'lobby.message', message

  routes.lobby.switched.add ->
    disconnectListeners()
