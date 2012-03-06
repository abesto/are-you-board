# Editing a game
edit = (game) ->
  game.boards = SS.shared.builder.build game.boards
  $editor = $('#editor-game-layout').tmpl(game:game)

  # Game name, description
  $editor.find('[name=name]').change -> game.name = $(this).val()
  $editor.find('[name=description]').change -> game.description = $(this).val()

  # Save general data button
  $editor.find('form').submit ->
    SS.server.game.update game, ({err, res}) ->
      notify err || res
    false 

  # Boards
  boardEditor = new SS.shared.boards.rectangle.editor $editor.find('.left')
  addBoard = (board) ->
    $editor.find('.board-list').append(
      $('<li>').text(board.name).click ->
        boardEditor.setBoard board
        $editor.find(".#{type}-count").html boardEditor.board[type+'s']
    )

  $editor.find('.add-board').click ->
    $this = $(this)
    clazz = $this.attr('data-board')
    parameters = $this.attr('data-parameters')
    board = new SS.shared.boards[clazz].definition JSON.parse parameters
    game.boards.push board
    addBoard board
    boardEditor.setBoard board

  addBoard(board) for board in game.boards

  # Add, remove rows and columns
  for type in ['row', 'column']
    do (type) ->
      $counter = $editor.find(".#{type}-count")
      for action in ['add', 'delete']
        do (action) ->
          $editor.find(".#{action}-#{type}").click ->
            boardEditor[action + type[0].toUpperCase() + type[1..]]()
            $counter.html boardEditor.board[type+'s']

  $editor.find('.field-color').colorpicker().on 'changeColor', (event) ->
    boardEditor.css 'background-color': event.color.toHex()

  RUB.$content.html $editor

exports.init = ->
  $list = $('#editor-game-list').tmpl()

  # Create game button
  $list.find('#create-game').click ->
    SS.server.game.create ({err, res}) ->
      return notify err if err
      edit res

  # Load existing games
  $dlg = $list.find '.delete-dialog'
  SS.server.game.getByUser RUB.user.user_id, ({err, res}) ->
    return notify err if err
    $tbody = $list.find 'tbody'
    for game in res
      do (game) ->
        $item = $('#editor-game-list-item').tmpl(game:game)
        $item.find('[rel=tooltip]').tooltip()
        $item.find('.edit').click -> 
          $tbody.find('[rel=tooltip]').tooltip 'hide'
          edit game

        $dlg.find('.btn[rel=cancel]').click -> $dlg.modal('hide')

        $item.find('.delete').click ->
          $dlg.find('.modal-body').text "You are about to delete the game '#{game.name}'. This can not be undone. Are you sure?"
          $dlg.find('.btn[rel=delete]').one 'click', ->
            SS.server.game.delete game.id, ({err, res}) ->
              return notify err if err
              $item.remove()
              notify 'OK'
            $dlg.modal('hide')
          $dlg.modal()

        $item.appendTo $tbody

  RUB.$content.html $list