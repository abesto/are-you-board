# Editing a game
edit = (game) ->
  $editor = $('#editor-game-layout').tmpl(game:game)

  # Game name, description
  $editor.find('[name=name]').change -> game.name = $(this).val()
  $editor.find('[name=description]').change -> game.description = $(this).val()

  # Save general data button
  $editor.find('form').submit ->
    SS.server.game.update game, ({err, res}) ->
      notify err || res
    false 

  board = new SS.shared.boards.rectangle.definition
    rows: 8
    columns: 8

  SS.shared.boards.rectangle.editor board, $editor.find('.left')

  RUB.$content.html $editor

exports.init = ->
  $list = $('#editor-game-list').tmpl()

  # Create game button
  $list.find('#create-game').click ->
    SS.server.game.create ({err, res}) ->
      return notify err if err
      edit res

  # Load existing games
  SS.server.game.getByUser RUB.user.id, ({err, res}) ->
    return notify err if err
    $tbody = $list.find 'tbody'
    for game in res
      $item = $('#editor-game-list-item').tmpl(game:game)
      $item.find('[rel=tooltip]').tooltip()
      $item.find('.edit').click -> 
        $tbody.find('[rel=tooltip]').tooltip 'hide'
        edit game
      $item.appendTo $tbody

  RUB.$content.html $list