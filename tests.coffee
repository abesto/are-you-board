test = (name) -> require "./tests/#{name}"

require('nodeunit').reporters['default'].run
  'Test utils':
    'Call counter': test 'callcounter'
  Builder: test 'builder'
  Boards:
    Rectangle: test 'boards/rectangle'
  Moves:
    AbsolutePath: test 'moves/absolutepath'
