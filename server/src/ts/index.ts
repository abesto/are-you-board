/// <reference path="typings/tsd.d.ts"/>
const MONGO_CONNECTION_STRING="mongodb://mongo/areyouboard";

const app = require("express")();
const http = require("http").Server(app);

function setupExpress(callback) {
    app.use(
        require("body-parser").json()
    );

    callback();
}

function setupSessions(callback) {
    const session = require("express-session");
    const MongoDBStore = require("connect-mongodb-session")(session);
    const store = new MongoDBStore({
        uri: MONGO_CONNECTION_STRING,
        collection: "sessions"
    });

    store.on("error", function(err) {
        if (err) {
            throw err;
        }
    });

    app.use(require("express-session")({
        secret: process.env.SESSION_SECRET,
        cookie: {
            maxAge: 1000 * 60 * 60 * 24 * 7 // 1 week
        },
        store: store
    }));

    callback();
}

function setupDb(callback) {
    const mongoose = require("mongoose");
    mongoose.connect(MONGO_CONNECTION_STRING);
    const db = mongoose.connection;
    // TODO: handle connection going away at runtime
    db.on("error", console.error.bind(console, "connection error:"));
    db.once("open", callback);
}

function setupSwagger(callback) {
    const path = require("path");
    const swaggerConfig = {
        appRoot: path.resolve(__dirname),
        configDir: path.resolve(__dirname, "api", "config")
    };
    require("swagger-express-mw").create(swaggerConfig, function(err, swaggerExpress) {
        if (err) {
            return callback(err);
        }
        swaggerExpress.register(app);
        callback();
    });
}

function setupSocketIO(callback) {
    const io = require("socket.io")(http);
    io.on("connection", function(socket){
        setInterval(function () {
            socket.emit("ping");
        }, 5000);
    });
    callback();
}

function listen(callback) {
    http.listen(8000, function () {
        var host = http.address().address;
        var port = http.address().port;
        console.log("Listening at http://%s:%s", host, port);
        callback();
    });
}

require("async").series([setupExpress, setupSessions, setupDb, setupSwagger, setupSocketIO, listen], function (err) {
    if (err) {
        console.log("Startup failed");
        throw err;
    }
});
