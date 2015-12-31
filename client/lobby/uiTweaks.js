// Resize chat message list to most of the height of the window
var resize = function () {
    var $chat = $('.chat');
    var $messages = $('.chat-messages-list-container');
    var windowHeight = $(window).height();
    $chat.css('height', windowHeight - 120);
    $messages.css('height', $(window).height() - 140);
};

Template.Chat.onRendered(resize);

Template.Chat.onCreated(function () {
    $(window).resize(resize);
});

Template.Chat.onDestroyed(function () {
    $(window).off('resize');
});
// EOF resize

// Keep message list scrolled to bottom
Template.ChatMessage.onRendered(function () {
    var $list = $(this.firstNode).closest('.chat-messages-list');
    var $container = $list.closest('.chat-messages-list-container');
    $container.scrollTop($list.height());
});
