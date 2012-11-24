User = require '/User'

module.exports =
  render: (event) ->
    UI.$container.html 'Loading users'
    User.model.count (err, count) ->
      return alert err if err
      UI.$container.html "Loading #{count} users"
      User.model.getMulti [1..count]..., (err, users) ->
        return alert err if err
        UI.$container.empty().append ss.tmpl['admin-userlist'].render(users: users)
