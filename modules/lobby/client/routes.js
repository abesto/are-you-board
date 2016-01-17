Router.route('/lobby', {
    template: 'Chat',
    waitOn: function () {
        return [
            this.subscribe("chat", "lobby"),
            this.subscribe("usersInChat", "lobby")
        ];
    },
    data: {
        welcome: {text: "Have fun!", time: new Date()},
        chatName: "lobby"
    },
    onBeforeAction: function () {
        Meteor.call("joinChat", "lobby");
        this.next();
    },
    onStop: function () {
        Meteor.call("leaveChat", "lobby");
    }
});
