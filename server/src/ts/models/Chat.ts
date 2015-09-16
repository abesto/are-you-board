/// <reference path="../typings/tsd.d.ts"/>

import mongoose = require("mongoose");
import IChat = require("./IChat");
import Message = require("./Message");

interface IChatModel extends IChat, mongoose.Document {}

const chatSchema = new mongoose.Schema({
    messages: [Message.schema]
});

const Chat = mongoose.model<IChatModel>("Chat", chatSchema);

export = Chat;

