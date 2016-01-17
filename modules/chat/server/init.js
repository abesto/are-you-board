Meteor.startup(function () {
    if (Chats.find({name: 'lobby'}, {limit: 1}).count() === 0) {
        Chats.insert({name: 'lobby', messages: [], users: []});
    }
});
