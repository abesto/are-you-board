# Within your web app's UI there are areas that your tests interact with.
# A Page Object simply models these as objects within the test code. This 
# reduces the amount of duplicated code and means that if the UI changes, 
# the fix need only be applied in one place. 
#
#    - https://code.google.com/p/selenium/wiki/PageObjects

module.exports = (casper) ->
  nick = 'casper'
  password = 'casper'

  navbarTabs = {}

  pos = {}

  navbar =
    logout: (cb) ->
      casper.evaluate -> $('#logout').click()
      casper.waitFor (-> not navbar.haveLogin()), (-> cb null, pos.login)

    haveLogin: (cb) -> 
      result = nick == casper.evaluate -> $('#current-user-nick').text()
      cb? result
      result

    toTab: (name, cb) ->
      cb "Navbar tab #{name} not known", null unless name of navbarTabs
      tab = navbarTabs[name]
      casper.click tab.change
      casper.waitUntilVisible tab.ready, -> cb null, tab.po
  # eof navbar

  class PageObject
    constructor: (@name, mixin) ->
      @navbar = navbar
      for name, fun of mixin
        this[name] = fun

    waitUntilVisible: -> casper.waitUntilVisible @_selector

    _next: (cb, po, err=null) ->
      t0 = Date.now()
      msg = "Switching to PO #{po.name}"
      casper.log msg, 'debug'
      casper.waitForSelector po._selector, -> 
        casper.log "#{msg}: done in #{Date.now() - t0}ms", 'debug'
        cb err, po
      po

    _errorAlertMessage: -> 
      ret = casper.evaluate -> $('.alert-error p:last-child').text()
      casper.click '.alert-error a.close'
      ret


  pos.login = new PageObject 'login',
    _selector: '.login-form'

    login: (cb) ->
      casper.fill '.login-form',
        nick: nick
        password: password
      casper.click 'input[name=login]'
      casper.waitFor (-> navbar.haveLogin() or casper.exists '.alert-error'), =>
        @_next cb, pos.login, @_errorAlertMessage() unless navbar.haveLogin()
        @_next cb, pos.editor.gameList

    toRegister: (cb) ->
      casper.click 'input[name=register]'
      @_next cb, pos.register
  # eof login


  pos.register = new PageObject 'register',
    _selector: '.register-form'

    register: (cb) ->
      casper.fill '.register-form',
        nick: nick
        password: password
        password2: password
      casper.click 'input[name=register]'
      casper.waitFor (-> navbar.haveLogin() or casper.exists('.alert-error')), =>
        return @_next cb, pos.register, @_errorAlertMessage() unless navbar.haveLogin()
        @_next cb, pos.editor.gameList

    toLogin: (cb) ->
      casper.click 'input[name=back]'
      @_next cb, pos.login
  # eof register

  pos.editor = {}
  pos.editor.gameList = new PageObject 'editor.gameList',
    _selector: '.game-list'

    createGame: (cb) ->
      casper.click '#create-game'
      @_next cb, pos.editor.general

    edit: (id, cb) ->
      casper.evaluate ((id) -> $(".game-list [rel=#{id}] .edit").click()), id:id
      @_next cb, pos.editor.general

    get: (id) ->
      casper.evaluate ((id) ->
        $row = $(".game-list [rel=#{id}]")
        return "" unless $row.length > 0
        return {
            name: $row.find('td.name').text()
            description: $row.find('td.description').text()
            lastModified: parseInt($row.find('td.last-modified').attr('rel'))
          }), id:id

    delete: (id, cb) ->
      casper.evaluate ((id) -> $(".game-list tr[rel=#{id}] .delete").click()), id:id
      casper.waitUntilVisible '.delete-dialog', ->
        casper.click '.btn[rel=delete]'
        casper.waitForSelector '.alert-success', -> cb? null, pos.editor.gameList
  navbarTabs.editor =
    change: '#editor'
    ready: '#create-game'
    po: pos.editor.gameList


  pos.editor.general = new PageObject 'editor.general',
    _selector: '#general'

    save: (cb) ->
      casper.click '#general .btn.save'
      casper.waitForSelector '.alert-success', => @_next cb, this

    enterName: (name, cb) -> 
      casper.fill 'form', name:name
      cb? null, this

    enterDescription: (desc, cb) -> 
      casper.fill 'form', description:desc
      cb? null, this

    getCurrent: (cb) -> 
      ret = casper.evaluate -> 
        id: $('span.game-id').text()
        name: $('span.game-name').text()
      cb? null, ret
      ret

    toBoards: (cb) ->
      casper.click "#content #board"
      @_next cb, pos.editor.boards


  pos.editor.boards = new PageObject 'editor.boards'
    _selector: '#boards'

    addBoard: (type) ->
      board = casper.evaluate -> $(".add-board[data-board=#{type}]").click type:type
      casper.waitForSelector ".board-list li[rel=#{board.id}]"

  pos.login
