module.exports = constants = c =
    apply: (cls) ->
      clsName = cls._name
      throw new Error("No constants for class #{clsName}") unless clsName of constants
      for key, value of constants[clsName]
        cls[key] = value

    Game:
      STATE_JOINING: 1
      STATE_DICE: 2
      STATE_MOVE: 3
      REQUIRED_PLAYERS: 2
      MAXIMUM_PLAYERS: 4
      MODEL_METHODS: ['join', 'leave', 'start', 'rollDice', 'move', 'skip', 'startPiece']

    User:
      MODEL_METHODS: []

    LudoUI:
      STATE_TEXT: {}

    LudoBoard:
      ROWS: 11
      COLUMNS: 11
      LAST_ROW: 10
      LAST_COLUMN: 10

      START_POSITIONS: [
        {
        player: 0
        row: 4
        column: 0
        }, {
        player: 1
        row: 0
        column: 6
        }, {
        player: 2
        row: 6
        column:10
        }, {
        player: 3
        row: 10
        column: 4
        }
      ]

c.LudoUI.STATE_TEXT[c.Game.STATE_JOINING] = 'Waiting for players...'
c.LudoUI.STATE_TEXT[c.Game.STATE_DICE] = 'Dice roll'
c.LudoUI.STATE_TEXT[c.Game.STATE_MOVE] = 'Moving a piece'

c
