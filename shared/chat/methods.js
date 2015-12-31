Meteor.methods({
    joinChat: function (chatName) {
        // TODO: authorization, DRY'd with server/chat/publish.js
        return Chats.update(
            {name: chatName},
            {$addToSet: {users: Meteor.userId()}}
        );
    },
    leaveChat: function (chatName) {
        return Chats.update(
            {name: chatName},
            {$pull: {users: Meteor.userId()}}
        );
    },
    sendChatMessage: function (chatName, messageText) {
        // TODO: authorization, DRY'd with server/chat/publish.js
        check(chatName, String);
        check(messageText, String);
        var message = {
            text: messageText,
            time: new Date(),
            from: Meteor.userId()
        };
        var modifier = {
                    $push: {
                        messages: {
                            $each: [message],
                            $sort: {time: 1},
                            $slice: -100
                        }
                    }
                };
        var selector = {name: chatName};
        return Chats.update(selector, modifier);
    }
});
