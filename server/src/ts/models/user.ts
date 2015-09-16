/// <reference path="../typings/tsd.d.ts"/>

import mongoose = require("mongoose");
import IUser = require("../shared/IUser");

interface IUserModel extends IUser, mongoose.Document {}

const userSchema = new mongoose.Schema({
    nick: String,
    lastSeen: Date
});

const User = mongoose.model<IUserModel>("User", userSchema);

export = User;
