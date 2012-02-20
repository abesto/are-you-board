exports.actions = 
  amILoggedIn: (cb) -> cb false

  register: (name, cb) ->
    if name == 'abesto' then cb('Name taken')
    else cb()