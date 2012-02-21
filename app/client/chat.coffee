exports.init = ->
  $chat = $('#chat-layout').tmpl()
  $messages = $chat.find '.messages'
  $scroll = $chat.find '.messages-scroll'
  $input = $chat.find 'form.chat-send input[name=input-msg]'
  RUB.content.html $chat

  viewport = $(window).height() - 40
  $chat.find('.scroll, .filler').css 'height', viewport * .7
  $chat.css 'margin-top', viewport * .095

  $chat.find('form.chat-send').submit ->
    msg = $input.val()
    return if msg.trim().length == 0
    SS.server.chat.send {msg: msg, channel: 'public'}
    $input.val('')
    false

  SS.server.chat.join 'public'
  SS.events.on 'msg', (msg, channel) ->
    row = $('#chat-message').tmpl(msg: msg)
    $messages.append row
    $scroll.scrollTop($messages[0].scrollHeight)

  $input.focus()
