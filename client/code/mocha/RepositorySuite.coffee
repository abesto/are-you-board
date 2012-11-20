Repository = require '/Repository'
Game = require '/Game'
User = require '/User'

describe 'Repository', ->
  before (done) ->
    sinon.spy Game.model, 'get'
    User.model.create 'repository-test', 'repository-password', (err, @user) =>
      Should.not.exist err
      User.model.login 'repository-test', 'repository-password', (err) =>
        Should.not.exist err
        Game.model.create (err, @game) => done err

  after ->
    Game.model.get.restore()

  it 'saves the item into Repository at creation', (done) ->
    Repository.get Game, @game.id, (err, game) =>
      Should.not.exist err
      game.id.should.equal @game.id
      Game.model.get.callCount.should.equal 0
      done()

  it 'gets from the server when an id is not found in the Repository', (done) ->
    Repository.get Game, @game.id + 1, (err, game) =>
      Game.model.get.callCount.should.equal 1
      done()

  it 'calls object methods when appropriate events are received', (done) ->
    Repository.get Game, @game.id, (err, game) =>
      sinon.stub game, 'join'
      ss.event.once "Game:join:#{game.id}", ->
        game.join.callCount.should.equal 1
        game.join.calledWithExactly @user
        game.join.restore()
        done()
      ss.event.emit "Game:join:#{game.id}", [@user]

