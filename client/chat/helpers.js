Template.ChatMessage.helpers({
    formatTime: function (date) {
        return moment(date).format('HH:mm:ss');
    },
    sender: function (id) {
        return Meteor.users.findOne(id);
    }
});

Template.Chat.helpers({
    chat: function () {
        return Chats.findOne({name: this.chatName});
    },
    users: function (chat) {
        return Meteor.users.find(
            {_id: {$in: chat.users}, status: 'online'},
            {sort: userDisplayNameFields}
        );
    }
});
