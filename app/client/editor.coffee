# Editing a game
edit = (game) ->
  window.game = game
  game.boards = SS.shared.builder.build game.boards
  $editor = $('#editor-game-layout').tmpl(game:game)
  $name = $editor.find('input[name=name]')
  $description = $editor.find('textarea[name=description]')
  $deleteDialog = $('.modal')

  $deleteDialog.find('.btn[rel=cancel]').click -> $deleteDialog.modal 'hide'

  # Save general data button
  $editor.find('form').submit ->
    game.name = $name.val()
    game.description = $description.val()
    rpc SS.server.game.update, game, (err, res) ->
      if not err 
        notify
          title: 'Game saved'
          message: "\"#{game.name}\" has been saved"
          class: 'success'
        $('.game-name').text game.name
    false 


  # Boards
  boardEditor = new SS.shared.boards.rectangle.editor $editor.find('.left'), $editor.find('.properties')

  editBoard = (board) ->
    $editor.find('.board-list .selected').removeClass 'selected'
    $editor.find(".board-list li[rel=#{board.id}]").addClass 'selected'
    boardEditor.setBoard board

  addBoard = (board) ->
    $editor.find('.board-list').append $item = $('#editor-board-list-item')
      .tmpl(board:board)
      .click -> editBoard board
    $item.find('.delete').click (event) ->
      event.stopPropagation()
      $editor.find(".board-list li[rel=#{board.id}]").remove()
      game.boards.splice game.boards.indexOf(board), 1
      #$deleteDialog.find('.modal-body').text 'FOO'
      #$deleteDialog.modal().find('.btn[rel=delete]').one 'click', ->
        #game.boards.splice board.id, 1
        #$editor.find(".board-list li[rel=#{board.id}]").remove()
    editBoard board

  addBoard(board) for board in game.boards
  editBoard game.boards[0] unless game.boards.length == 0

  $editor.find('.add-board').click ->
    $this = $(this)
    clazz = $this.attr('data-board')
    parameters = $this.attr('data-parameters')
    board = new SS.shared.boards[clazz].definition JSON.parse parameters
    while (true for existing in game.boards when existing.id == board.id).any()
      board.id++
    game.boards.push board
    addBoard board
    board

  RUB.$content.html $editor

exports.init = ->
  $list = $('#editor-game-list').tmpl()

  # Create game button
  $list.find('#create-game').click ->
    rpc SS.server.game.create, (err, res) ->
      return notify err if err
      edit res

  # Load existing games
  $dlg = $list.find '.delete-dialog'
  rpc SS.server.game.getByUser, RUB.user.user_id, (err, res) ->
    return notify err if err
    $tbody = $list.find 'tbody'
    for game in res
      do (game) ->

        d = new Date()
        d.setTime(game.lastModified)
        game.lastModified = d
        
        $item = $('#editor-game-list-item').tmpl(game:game)
        $item.find('[rel=tooltip]').tooltip()
        $item.find('.edit').click -> 
          $tbody.find('[rel=tooltip]').tooltip 'hide'
          edit game

        $dlg.find('.btn[rel=cancel]').click -> $dlg.modal('hide')

        $item.find('.delete').click ->
          $dlg.find('.modal-body').text "You are about to delete the game '#{game.name}'. This can not be undone. Are you sure?"
          $dlg.find('.btn[rel=delete]').one 'click', ->
            rpc SS.server.game.delete, game.id, (err, res) ->
              return notify err if err
              $item.remove()
              notify
                title: 'Game deleted'
                message: '"' + game.name + '" has been deleted'
                class: 'success'
            $dlg.modal('hide')
          $dlg.modal()

        $item.appendTo $tbody

  RUB.$content.html $list