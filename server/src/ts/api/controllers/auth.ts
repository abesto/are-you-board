/// <reference path="../../typings/tsd.d.ts"/>

import user = require("../../models/user");
const User = user.User;

export function login(req, res) {
    if ("userId" in req.session) {
        return res.status(400).json({ message: "Already logged in" });
    }
    var data = {
        nick: req.swagger.params.nick.value
    };
    function doLogin(user) {
        req.session["userId"] = user._id;
        res.redirect("/");
    }
    User.findOne(data, function (err, user) {
        if (err) {
            return res.status(400).json({message: err.toString()});
        }
        if (user === null) {
            user = new User(data);
            user.save((err) => {
                if (err) {
                    return res.status(500).json({ message: err.toString() });
                }
                doLogin(user);
            });
        } else {
            doLogin(user);
        }
    })
}

export function logout(req, res) {
    req.session.destroy((err) => {
        if (err) {
            return res.status(500).json({ message: err.toString() });
        }
        res.redirect("/");
    });
}