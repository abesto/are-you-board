/// <reference path="typings/tsd.d.ts"/>

const express = require('express');

const app = express();

app.get('/api/test', function (req, res) {
    res.send('test response');
});

var server = app.listen(8000, function () {
    var host = server.address().address;
    var port = server.address().port;

    console.log('Example app listening at http://%s:%s', host, port);
});
