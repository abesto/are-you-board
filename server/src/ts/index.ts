/// <reference path="typings/tsd.d.ts"/>

const path = require("path");

const express = require("express");
const bodyParser = require("body-parser");
const mongoose = require("mongoose");
const SwaggerExpress = require("swagger-express-mw");

const app = express();

app.use(bodyParser.json());

mongoose.connect("mongodb://mongo/areyouboard");
const db = mongoose.connection;

// TODO: handle connection going away at runtime
db.on("error", console.error.bind(console, "connection error:"));

db.once("open", function () {
    const swaggerConfig = {
        appRoot: path.resolve(__dirname)
    };

    SwaggerExpress.create(swaggerConfig, function(err, swaggerExpress) {
        if (err) {
            throw err;
        }
        swaggerExpress.register(app);

        var server = app.listen(8000, function () {
            var host = server.address().address;
            var port = server.address().port;

            console.log("Example app listening at http://%s:%s", host, port);
        });
    });
});
