/// <reference path="typings/tsd.d.ts"/>
/// <reference path="../../../shared/message.ts"/>

// Test using shared code
const msg: Message = new Message();
console.log(msg);

var socket = io();

socket.on("ping", function () {
    socket.emit("pong");
});