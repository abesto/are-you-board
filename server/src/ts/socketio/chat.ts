import User = require("../models/User");
import Chat = require("../models/Chat");
import Message = require("../shared/IMessage");

export function apply(sio) {
    sio.on("connection", (socket) => {
        var session = socket.handshake.session;
        User.findById(session.userId, (err, user) => {
            if (err || !user) {
                socket.emit("error:get-user", err);
                return socket.disconnect();
            }
            socket.once("chat:join", (chatId) => {
                Chat.findById(chatId, (err, chat) => {
                    if (err || !chat) {
                        return socket.emit("error:get-chat", err)
                    }
                    var room = `chat:${chatId}`;
                    socket.join(room, (err) => {
                        if (err) {
                            socket.emit("error:join-room", err);
                            return socket.disconnect();
                        }
                        socket.on("chat:msg", (msg: Message) => {
                            msg.sender = user.nick;
                            msg.timestamp = new Date();
                            Chat.update(
                                { _id: chatId },
                                {
                                    $push: {
                                        messages: {
                                            $each: [msg],
                                            $slice: -10
                                        }
                                    }
                                },
                                (err) => {
                                    if (err) {
                                        console.log("error:history-add", err, chat)
                                    }
                                }
                            );
                            sio.to(room).emit("chat:msg", msg);
                        })
                    });
                });
            });
        });
    });
}

