Path = require '/Path'

chai.Assertion.overwriteMethod 'equal', (_super) -> (expectedSteps) ->
  return _super.call(this, expectedSteps) unless @_obj instanceof Path
  path = @_obj
  for index, expected of expectedSteps
    path.position(index).should.deep.equal expected
    path[index].should.deep.equal expected

describe 'Path', ->
  before ->
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

  it 'has correct defaults', ->
    p = new Path
    p.should.be.an.instanceof Path
    p.string.should.equal ''
    p.origin.row.should.equal 0
    p.origin.column.should.equal 0

  it 'handles constructor parameters', ->
    @p.string.should.equal @string
    @p.origin.row.should.equal @originRow
    @p.origin.column.should.equal @originColumn

  it 'has length set', ->
    @p.should.have.length 25

  it 'returns the same for #position and []', ->
    for i in [0 ... @p.length]
      @p.position(i).should.equal @p[i]
    Should.not.exist @p.position(@p.length)
    Should.not.exist @p[@p.length]

  it 'has position 0 as the origin', ->
    @p.position(0).should.eql {row: @originRow, column: @originColumn}

  it 'creates steps correctly', ->
    @p.should.equal @steps

  it 'can be rotated', ->
    cases = [
      {rotation: 0, string: 'uurrdd'}
      {rotation: 90, string: 'rrddll'}
      {rotation: 180, string: 'ddlluu'}
      {rotation: 270, string: 'lluurr'}
    ]
    for {rotation, string} in cases
      p = new Path
        string: cases[0].string
        rotation: rotation
      p.should.equal new Path string: string

  it 'can be appended: ends are fitted, strings appended', ->
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
    p0.should.equal @steps
    p0.string.should.equal @string + 'rddl'

  it '#clone creates a shared-nothing copy', ->
    p1 = @p.clone()
    p1.append new Path string: '10r'
    @p.should.have.length @steps.length
    p1.should.have.length @steps.length + 10

  it 'pop removes the last step', ->
    @p.pop().should.deep.equal @steps.pop()
    @p.should.equal @steps
