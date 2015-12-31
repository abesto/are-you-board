Template.Chat.events({
    "submit form.send": function (event) {
        var $message = $(event.currentTarget).children('.message');
        var message = $message.val().trim();
        if (message.length > 0) {
            Meteor.call("sendChatMessage", this.chatName, $message.val());
            $message.val('');
        }
        return false;
    }
});
