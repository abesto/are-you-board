import Chat = require("../models/Chat");
import mongoose = require("mongoose");

export function apply(app) {
    app.get("/chat", (req, res) => new Chat().save((err, chat: mongoose.Document) => {
        if (err || !chat) {
            res.send(500, err);
        } else {
            res.redirect(`/chat/${chat._id}`);
        }
    }));

    app.get("/chat/:chatId", (req, res) => {
        Chat.findById(req.params.chatId, (err, chat) => {
            if (err) {
                return res.send(500, err);
            }
            if (chat == null) {
                return res.send(404);
            }
            res.render("chat", {
                Site: {
                    chatId: req.params.chatId,
                    history: chat.messages
                }
            });
        })
    });
}
