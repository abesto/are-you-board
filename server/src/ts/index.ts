/// <reference path="typings/tsd.d.ts"/>

const path = require("path");
const http = require("http");

const express = require("express");
const bodyParser = require("body-parser");
const mongoose = require("mongoose");
const SwaggerExpress = require("swagger-express-mw");
const socketIo = require("socket.io");

const app = express();
const appHttp = http.Server(app);
const io = socketIo(appHttp);

app.use(bodyParser.json());

mongoose.connect("mongodb://mongo/areyouboard");
const db = mongoose.connection;

// TODO: handle connection going away at runtime
db.on("error", console.error.bind(console, "connection error:"));

db.once("open", function () {
    const swaggerConfig = {
        appRoot: path.resolve(__dirname)
    };

    io.on("connection", function(socket){
        setInterval(function () {
            socket.emit("ping");
        }, 5000);
    });

    SwaggerExpress.create(swaggerConfig, function(err, swaggerExpress) {
        if (err) {
            throw err;
        }
        swaggerExpress.register(app);

        var server = appHttp.listen(8000, function () {
            var host = appHttp.address().address;
            var port = appHttp.address().port;

            console.log("Example app listening at http://%s:%s", host, port);
        });
    });
});
