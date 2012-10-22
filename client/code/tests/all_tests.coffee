testModules = [
  'LudoBoard'
  'Path'
  'models/game'
  'models/user'
]

for module in testModules
  require "/#{module}Test"

