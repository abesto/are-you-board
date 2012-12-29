Game = require '/Game'
User = require '/User'
Repository = require '/Repository'
LudoRules = require '/LudoRules'

$createGame = null
$joinGame = null
$openGame = null

findControls = ->
  $createGame = $('#create-game-btn')
  $joinGame = $('.join-game.btn')
  $openGame = $('.open-game.btn')

ludoFlavor = ->
  flavor = new LudoRules.Flavor()
  $form = $('form#ludo-flavor')
  for field in LudoRules.Flavor.FIELDS
    $checkbox = $form.find('#' + field)
    flavor[field] = $checkbox.is(':checked') if $checkbox.length > 0
  flavor

module.exports = exports =
  makeRender: (listMethod) ->
    ret = render: ->
      listMethod (err, games) ->
        return alert err if err
        async.map games, ((game, cb) ->
          Repository.get User, game.createdBy, (err, createdBy) ->
            return cb err if err
            cb null, {
              id: game.id
              playerCount: game.playerCount()
              maximumPlayers: Game.MAXIMUM_PLAYERS
              createdBy: createdBy.nick
              createdAt: game.createdAt
              joined: game.isUserPlaying(window.user)
            }
        ), (err, context) ->
          return alert err if err
          UI.$container.empty().append ss.tmpl['gamelist'].render games: context
          findControls()
          $createGame.click ->
            Game.model.create ludoFlavor().serialize(), (err, game) ->
              return alert err if err
              game.join window.user, (err) ->
                return alert err if err
                ret.render()
          $joinGame.click ->
            Repository.get Game, $(this).data('gameid'), (err, game) ->
              return alert err if err
              game.join window.user, (err) ->
                return alert err if err
                require('./ludo').render(game.id)
          $openGame.click ->
            Repository.get Game, $(this).data('gameid'), (err, game) ->
              return alert err if err
              game.rejoin (err) ->
                return alert err if err
                require('./ludo').render(game.id)
