class Navbar
  constructor: (@$container, @defaultTab=null) ->
    @items = {}

  render: ->
    $navbar = $('#common-navbar').tmpl user:RUB.user
    @$container.html $navbar
    for id, action of @items
      do (id, action) ->
        $navbar.find('#'+id).click ->
          $navbar.find('.active').removeClass('active')
          action()
    if @defaultTab isnt null
      $navbar.find('#'+@defaultTab).click()


instance = null

exports.init = ($navbar) -> instance = new Navbar $navbar

exports.render = -> instance.render()

exports.setDefaultTab = (defaultTab) -> instance.defaultTab = defaultTab

exports.addItems = (data) ->
  for name, action of data
    instance.items[name] = action
