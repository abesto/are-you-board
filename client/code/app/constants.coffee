module.exports = constants =
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
    MODEL_METHODS: ['join', 'leave', 'start', 'rollDice', 'move', 'skip', 'startPiece']

  User:
    MODEL_METHODS: []
