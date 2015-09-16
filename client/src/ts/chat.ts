/// <reference path="typings/tsd.d.ts"/>

import IMessage = require("./shared/IMessage");

declare var Site: {
    chatId: String,
    history: Array<IMessage>
};

$(() => {
    var socket = io(`${location.protocol}//${location.hostname}:8081`);
    socket.on("ping", () => socket.emit("pong"));
    socket.on("connect", () => socket.emit("chat:join", Site.chatId));

    var $history = $(".chat > table.history"),
        $form = $(".chat > form"),
        $msg = $form.children("input.msg"),
        $send = $form.children("input.send");

    function send() {
        socket.emit("chat:msg", { message: $msg.val() });
        $msg.val("");
        return false;
    }

    function show(msg: IMessage) {
        $history.append(
            `<tr><td>${msg.timestamp}</td><td>${msg.sender}</td><td>${msg.message}</td></tr>`
        )
    }

    socket.on("chat:msg", (msg) => {
        show(msg);
    });

    Site.history.forEach(show);

    $send.click(send);
    $form.submit(send);
});

