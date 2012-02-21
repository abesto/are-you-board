exports.init = ->
  $chat = $('#chat-layout').tmpl()
  RUB.content.html $chat
  $messages = $ '#messages'
  $scroll = $ '#chat-scroll'
  SS.server.chat.join 'public'
  SS.events.on 'msg', (msg, channel) ->
    row = $('#chat-message').tmpl(msg: msg)
    $messages.append row
    $scroll.scrollTop($messages[0].scrollHeight)
  $input = $chat.find '#input-msg'
  $chat.find('form').submit ->
    SS.server.chat.send {msg: $input.val(), channel: 'public'}
    $input.val('')
    false
  $input.focus()
