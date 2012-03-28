# Within your web app's UI there are areas that your tests interact with.
# A Page Object simply models these as objects within the test code. This 
# reduces the amount of duplicated code and means that if the UI changes, 
# the fix need only be applied in one place. 
#
#    - https://code.google.com/p/selenium/wiki/PageObjects

nick = 'casper'
password = 'casper'

class PO # Base PO
  @casper: null

  constructor: (@name, @selector, mixin) ->
    if PO[@name] isnt undefined
      throw "Failed creating PO #{@name}: a PO instance or class method with this name already exists"
    PO[@name] = this
    @__defineGetter__ 'casper', -> PO.casper
    this[key] = val for key, val of mixin

  waitUntilVisible: (cb) -> @casper.waitUntilVisible @selector, cb

  next: (cb, po, err=null) ->
    t0 = Date.now()
    msg = "Switching to PO #{po.name}"
    @casper.log msg, 'debug'
    po.waitUntilVisible =>
      @casper.log "#{msg}: done in #{Date.now() - t0}ms", 'debug'
      cb err, po
    po

new PO 'navbar', '',
  tabs: {}
  logout: (cb) ->
    @casper.click '#logout'
    @casper.waitFor (=> not @haveLogin()), (=> cb null, PO['login'])

  haveLogin: (cb) -> 
    result = nick == @casper.evaluate -> $('#current-user-nick').text()
    cb? result
    result

  addTab: ({name, switchSelector, readySelector, po}) ->
    @tabs[name] = arguments[0]

  toTab: (name, cb) ->
    cb "Navbar tab #{name} not known", null unless name of @tabs
    tab = @tabs[name]
    @casper.click tab.switchSelector
    @casper.waitUntilVisible tab.readySelector, => cb null, PO[tab.po]


class PON extends PO # PO with navbar, selector and error message helper
  constructor: (name, selector, mixin) ->
    super name, selector, mixin
    @navbar = PO['navbar']

  _errorAlertMessage: -> 
    ret = @casper.evaluate -> $('.alert-error p:last-child').text()
    @casper.click '.alert-error a.close'
    ret


new PON 'login', '.login-form',
  login: (cb) ->
    @casper.fill '.login-form',
      nick: nick
      password: password
    @casper.click 'input[name=login]'
    @casper.waitFor (=> @navbar.haveLogin() or @casper.exists '.alert-error'), =>
      @next cb, PO['login'], @_errorAlertMessage() unless @navbar.haveLogin()
      @next cb, PO['editor.gameList']

  toRegister: (cb) ->
    @casper.click 'input[name=register]'
    @next cb, PO['register']


new PON 'register', '.register-form',
  register: (cb) ->
    @casper.fill '.register-form',
      nick: nick
      password: password
      password2: password
    @casper.click 'input[name=register]'
    @casper.waitFor (=> @navbar.haveLogin() or @casper.exists('.alert-error')), =>
      return @next cb, this, @_errorAlertMessage() unless @navbar.haveLogin()
      @next cb, PO['editor.gameList']

  toLogin: (cb) ->
    @casper.click 'input[name=back]'
    @next cb, PO['login']


new PON 'editor.gameList', '.game-list',
  createGame: (cb) ->
    @casper.click '#create-game'
    @next cb, PO['editor.general']

  edit: (id, cb) ->
    @casper.evaluate ((id) -> $(".game-list [rel=#{id}] .edit").click()), id:id
    @next cb, PO['editor.general']

  get: (id) ->
    @casper.evaluate ((id) ->
      $row = $(".game-list [rel=#{id}]")
      return "" unless $row.length > 0
      return {
          name: $row.find('td.name').text()
          description: $row.find('td.description').text()
          lastModified: parseInt($row.find('td.last-modified').attr('rel'))
        }), id:id

  delete: (id, cb) ->
    @casper.evaluate ((id) -> $(".game-list tr[rel=#{id}] .delete").click()), id:id
    @casper.waitUntilVisible '.delete-dialog', =>
      @casper.click '.btn[rel=delete]'
      @casper.waitForSelector '.alert-success', -> cb? null, PO['editor.gameList']

PO['navbar'].addTab
  name: 'editor'
  switchSelector: '#editor'
  readySelector: '#create-game'
  po: 'editor.gameList'


class POG extends PON # PON with a save game and get current game method
  save: (cb) ->
    @casper.click '#general .btn.save'
    @casper.waitForSelector '.alert-success', => @next cb, this

  getCurrent: (cb) ->
    ret = @casper.evaluate -> 
      id: $('span.game-id').text()
      name: $('span.game-name').text()
    cb? null, ret
    ret


new POG 'editor.general', '#general',
  enterName: (name, cb) -> 
    @casper.fill 'form', name:name
    cb? null, this

  enterDescription: (desc, cb) -> 
    @casper.fill 'form', description:desc
    cb? null, this

  toBoards: (cb) ->
    @casper.click "#content #board"
    @next cb, PO['editor.boards']


new POG 'editor.boards', '#boards',
  addBoard: (type, cb) ->
    board = @casper.evaluate -> $(".add-board[data-board=#{type}]").click type:type
    @casper.waitForSelector ".board-list li[rel=#{board.id}]", cb


module.exports = (casper) ->
  PO.casper = casper
  PO['login']
