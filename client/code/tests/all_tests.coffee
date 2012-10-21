testModules = [
  'LudoBoard'
  'Path'
  '/models/game'
]

for module in testModules
  require "/#{module}Test"

