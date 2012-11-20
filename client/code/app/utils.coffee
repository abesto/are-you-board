module.exports = (window) ->
  window.timestamp = -> (new Date()).getTime()

  window.TypeCheck = window.TC = (name, signature...) -> (fun) -> (args...) ->
    expectedMinArguments = 0
    expectedMaxArguments = 0
    for t in signature
      expectedMinArguments += t.minArguments ? 1
      expectedMaxArguments += t.maxArguments ? 1
    if args.length < expectedMinArguments
      expectedStr = if expectedMinArguments == expectedMaxArguments then 'exactly' else 'at least'
      throw new Error "#{name} expected #{expectedStr} #{expectedMinArguments} arguments, got #{args.length}"
    if args.length > expectedMaxArguments
      expectedStr = if expectedMinArguments == expectedMaxArguments then 'exactly' else 'at most'
      throw new Error "#{name} expected at most #{expectedMinArguments} arguments, got #{args.length}"
    for i in [0 ... args.length]
      unless signature[i].call this, args[i]
        throw new Error "Expected argument #{i} of #{name} to be #{signature[i].err}, got #{args[i]} of type #{typeof args[i]}"
    fun.apply this, args
  window.TC.String = _.isString
  window.TC.String.err = 'string'

  window.TC.Instance = (cls) ->
    test = (o) -> o instanceof cls
    test.err = "instance of #{cls.name}"
    test

  window.TC.Number = _.isNumber
  window.TC.Number.err = 'number'

  window.TC._ = -> true

  window.TC.Function = _.isFunction
  window.TC.Function.err = 'function'

  window.TC.Object = _.isObject
  window.TC.Object.err = 'object'

  window.TC.Maybe = (t) ->
    f = (o) -> !o or t(o)
    f.err = "Maybe #{t.err}"
    f.minArguments = 0
    f

  window.TC.Callback = TC.Maybe TC.Function

  window.TypeSafe = (cls) ->
    for name, fun of cls.prototype
      if cls.prototype.hasOwnProperty "#{name}S"
        cls.prototype[name] = TC("#{cls.name}##{name}", cls.prototype["#{name}S"]...)(fun)
