Game = require '/Game'
Repository = require '/Repository'

$board = null

findControls = ->
  $board = $('#board')

renderBoard = ->
  paper.setup($board[0])
  rect = new paper.Rectangle(new paper.Point(0,300), new paper.Point(300,300))
  rect.strokeColor = 'red'
  path = new paper.Path()
  path.strokeColor = 'black'
  start = new paper.Point(100, 100);
  path.moveTo(start)
  path.lineTo(start.add([ 200, -50 ]))
  paper.view.draw()

module.exports =
  render: (gameId) ->
    Repository.get Game, gameId, (err, game) ->
      return alert err if err
      UI.$container.empty().append ss.tmpl['ludo'].render()
      findControls()
      renderBoard()
