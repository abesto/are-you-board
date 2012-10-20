Path = require '/Path'

QUnit.module 'Path',
  setup: ->
    @string = '3u4drr1l3u11d'
    @originRow = 3
    @originColumn = 4
    @p = new Path
      origin:
        row: @originRow
        column: @originColumn
      string: @string
    @steps = ({row:row, column:column} for [row, column] in [
      # origin
      [3, 4]
      # 3u
      [2, 4], [1, 4], [0, 4]
      # 4d
      [1, 4], [2, 4], [3, 4], [4, 4]
      # rr
      [4, 5], [4, 6]
      # 1l
      [4, 5]
      # 3u
      [3, 5], [2, 5], [1, 5]
      # 11d
      [2, 5], [3, 5], [4, 5], [5, 5], [6, 5], [7, 5], [8, 5], [9, 5], [10, 5], [11, 5], [12, 5]
    ])

pathStepsAre = (path, steps) ->
  for index, expected of steps
    deepEqual path.position(index), expected
    deepEqual path[index], expected


test 'constructor defaults', ->
  @p = new Path
  ok @p instanceof Path
  strictEqual @p.string, ''
  strictEqual @p.origin.row, 0
  strictEqual @p.origin.column, 0

test 'constructor with parameters', ->
  strictEqual @p.string, @string
  strictEqual @p.origin.row, @originRow
  strictEqual @p.origin.column, @originColumn

test 'position 0 = origin', ->
  deepEqual @p.position(0), {row: @originRow, column: @originColumn}
  deepEqual @p[0], {row: @originRow, column: @originColumn}

test 'complex path with non-0 origin', ->
  pathStepsAre @p, @steps

test 'rotation works', ->
  cases = [
    {rotation: 0, string: 'uurrdd'}
    {rotation: 90, string: 'rrddll'}
    {rotation: 180, string: 'ddlluu'}
    {rotation: 270, string: 'lluurr'}
  ]
  for {rotation, string} in cases
    unrotated = new Path string: string
    @p = new Path
      string: cases[0].string
      rotation: rotation
    for index in [0 ... cases[0]['string'].length]
      deepEqual @p.position(index), unrotated.position(index)

test 'length is set', ->
  strictEqual @p.length, 25

test 'paths can be appended, ends are fitted, strings appended', ->
  p0 = @p
  offset = p0.length
  p1 = new Path string: 'rd'
  p2 = new Path string: 'dl'
  p0.append p1
  p0.append p2
  @steps.push(step) for step in [
    {row: 12, column: 6} # r
    {row: 13, column: 6} # d
    {row: 14, column: 6} # d
    {row: 14, column: 5} # l
  ]
  pathStepsAre p0, @steps
  strictEqual p0.string, @string + 'rddl'

test 'clone creates a shared-nothing copy', ->
  p1 = @p.clone()
  @p.append new Path string: '10r'
  strictEqual p1.length, @steps.length
  strictEqual @p.length, @steps.length + 10

test 'pop removes the last step', ->
  deepEqual @p.pop(), @steps.pop()
  pathStepsAre @p, @steps