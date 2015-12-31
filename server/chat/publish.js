Meteor.publish("chat", function (chatName) {
    check(chatName, String);
    // TODO: authorization
    return Chats.find({name: chatName}, {limit: 1});
});

Meteor.publish("usersInChat", function (chatName) {
    check(chatName, String);
    // TODO: authorization
    var chat = Chats.findOne({name: chatName});

    var usersInChat = chat.users;
    var usersInHistory = chat.messages.map(function (m) { return m.from; });

    return Meteor.users.find({$or: [
        {_id: {$in: usersInChat}, status: 'online'},
        {_id: {$in: usersInHistory}}
    ]});
});
