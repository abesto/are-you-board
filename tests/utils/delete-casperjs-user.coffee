# User "casper" will be registered as a test; remove it if it exists
R = require('redis').createClient()
R.hexists 'users', 'casper', (err, res) ->
  if res
    console.log 'User "casper" exists. Deleting it.'
    console.log 'TODO: No data related to the user is removed, this can lead to inconsistencies'
    R.hget 'users', 'casper', (err, res) ->
      R.del "user:#{res}"
      R.hdel 'users', 'casper'
      process.exit()
  else
    process.exit()

