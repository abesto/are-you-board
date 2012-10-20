class Path
  @VECTORS:
    u: {row: -1, column: 0}
    d: {row: 1, column: 0}
    l: {row: 0, column: -1}
    r: {row: 0, column: 1}

  @DEFAULTS =
    origin:
      row: 0
      column: 0
    rotation: 0
    string: ''

  constructor: (opts={}) ->
    opts = _.defaults opts, Path.DEFAULTS
    @origin = opts.origin
    @string = @rotate opts
    @buildPositions()

  offsetPosition: (a, b) -> row: a.row + b.row, column: a.column + b.column

  rotate: (opts) ->
    string = opts.string
    rotation = opts.rotation
    throw 'Only supported rotations of 0, 90, 180, 270' unless opts.rotation % 90 == 0
    offset = opts.rotation / 90
    ordering = ['u', 'r', 'd', 'l']
    mapping = {}
    for index, from of ordering
      index = -(-index)
      mapping[from] = ordering[(index + offset) % ordering.length]
    ((if char of mapping then mapping[char] else char) for char in string).join ''

  addStep: (step) ->
    this[@length++] = step

  buildPositions: ->
    @length = 0
    @addStep @origin
    stringIndex = 0
    while @string.length > stringIndex
      if @string[stringIndex] in '0123456789'
        count = ''
        while @string[stringIndex] in '0123456789' and stringIndex < @string.length
          count += @string[stringIndex++]
        count = parseInt count
        throw 'Expected direction, got a number at the end of the path string' if stringIndex == @string.length
      else
        count = 1
      direction = @string[stringIndex++]
      throw "Unkown direction #{direction} at index #{stringIndex}" unless direction of Path.VECTORS
      vector = Path.VECTORS[direction]
      for i in [0 ... count]
        @addStep @offsetPosition _.last(this), vector

  position: (index) -> this[index]

  append: (other) ->
    postfix = new Path
      string: other.string
      origin: _.last(this)
    for step in _.toArray(postfix)[1 ... postfix.length]
      @addStep step
    @string += other.string

  pop: ->
    elem = this[--@length]
    delete this[@length]
    elem

  clone: ->
    new Path
      string: @string
      origin: @origin

module.exports = Path