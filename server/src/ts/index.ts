/// <reference path="typings/tsd.d.ts"/>

const express = require("express");
const app = express();

const api = require("./routes/api");

app.get("/api/test", api.test);

var server = app.listen(8000, function () {
    var host = server.address().address;
    var port = server.address().port;

    console.log("Example app listening at http://%s:%s", host, port);
});
