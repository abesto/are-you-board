exports.init = ->

register = ->
  SS.server.chat.register (prompt 'Please enter your nickname'), (err) ->
    if err
      alert err
      register()
    else
      alert 'Logged in'
