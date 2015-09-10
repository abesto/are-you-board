/// <reference path="../../typings/tsd.d.ts"/>

const mongoose = require("mongoose");

const catSchema = new mongoose.Schema({
    name: String
}, {
    id: false,
    toJSON: {
        getters: true,
        versionKey: false,
    }
});
var Cat;

catSchema.virtual("uri").get(function () {
    return "/api/cat/" + this._id;
});

Cat = mongoose.model("Cat", catSchema);

export function list(req, res) {
    res.json([]);
}

export function create(req, res) {
    const cat = new Cat(req.swagger.params.cat.value);
    cat.save(function (err) {
        if (err) {
            return res.json(500, { message: err });
        }
        console.log(cat);
        res.json(cat);
    });
}

export function getById(req, res) {
    Cat.findById(req.swagger.params.id.value, function(err, cat) {
        if (err) {
            return res.json(404, { message: "Not found" });
        }
        res.json(cat);
    });
}