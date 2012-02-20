exports.trim = -> (input) -> {valid: true, sanitized: input.trim()}
exports.longer = (than, info) -> (input) -> {valid: input.length > than, sanitized: input, info: info}
exports.doesntContain = (chars, info) -> (input) ->
  for char in chars
    if input.contains char then return {valid: false, info: info, char: char} 
  {valid: true, sanitized: input}

exports.validate = (input, validators...) ->
  for validator in validators
    data = validator input
    return data unless data.valid
  return data
