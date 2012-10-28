window.assertPropertiesEql = (properties, one, other) ->
  for property in properties
    if _.isNull(one[property]) or _.isUndefined(one[property])
      should.not.exist other[property]
    else
      one[property].should.eql other[property]

