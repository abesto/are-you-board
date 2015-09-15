/// <reference path="../typings/tsd.d.ts"/>

const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
    nick: String,
    lastSeen: Date
});

export const User = mongoose.model("User", userSchema);

export function seen(userId, cb) {
    User.findById(userId, (err, user) => {
        if (!err && user) {
            user["lastSeen"] = new Date();
            user.save(cb);
        }
        cb(err, user);
    })
}
