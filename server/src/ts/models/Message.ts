/// <reference path="../typings/tsd.d.ts"/>

import mongoose = require("mongoose");
import IMessage = require("../shared/IMessage");

interface IMessageModel extends IMessage, mongoose.Document {}

const messageSchema = new mongoose.Schema({
    message: String,
    sender: String,
    timestamp: Date
});

const Message = mongoose.model<IMessageModel>("Message", messageSchema);

export = Message
