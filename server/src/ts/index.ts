/// <reference path="typings/tsd.d.ts"/>
const MONGO_CONNECTION_STRING = "mongodb://mongo/areyouboard";
const SESSION_COOKIE = "connect.sid";

const
    app = require("express")(),
    http = require("http").Server(app),
    winston = require("winston"),
    expressWinston = require('express-winston');

var configuredSessionMiddleware;

function setupExpress(callback) {
    const bodyParser = require("body-parser");
    app.use(
        bodyParser.json(),
        bodyParser.urlencoded()
    );
    app.set("view engine", "jade");
    callback();
}

function setupSessions(callback) {
    const session: any = require("express-session");
    const MongoDBStore = require("connect-mongodb-session")(session);
    const sessionStore = new MongoDBStore({
        uri: MONGO_CONNECTION_STRING,
        collection: "sessions"
    });

    sessionStore.on("error", function(err) {
        if (err) {
            throw err;
        }
    });

    configuredSessionMiddleware = session({
        secret: process.env.SESSION_SECRET,
        cookie: {
            maxAge: 1000 * 60 * 60 * 24 * 7 // 1 week
        },
        store: sessionStore,
        name: SESSION_COOKIE
    });
    app.use(configuredSessionMiddleware);

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

const logging = {
    consoleTransport: new winston.transports.Console({
            json: false,
            colorize: true
    }),
    setupRequest: (callback) => {
        app.use(expressWinston.logger({
            transports: [logging.consoleTransport],
            expressFormat: true
        }));
        callback();
    },
    setupError: (callback) => {
        app.use(expressWinston.errorLogger({
            transports: [logging.consoleTransport]
        }));
        callback();
    }
};

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

function forEachModuleIn(prefix, f) {
    const fs = require("fs");
    var names = fs.readdirSync(`./${prefix}`);
    names.forEach((moduleName: String) => {
        const module = require(`./${prefix}/${moduleName}`);
        f(module);
    });
}

function setupSocketIO(callback) {
    const sio = require("socket.io").listen(8001);
    const sioExpressSession = require('socket.io-express-session');
    sio.use(sioExpressSession(configuredSessionMiddleware));
    forEachModuleIn("socketio", (module) => module.apply(sio) );
    callback();
}

function setupViews(callback) {
    // TODO: redirect to where the user wanted to go
    // TODO: look into "passport" library
    app.use((req, res, next) => {
        if (req.path != "/login" && !("userId" in req.session)) {
            res.redirect("/login");
        } else {
            next();
        }
    });

    forEachModuleIn("routes", (module) => app.use("/", module));

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

require("async").series([
    setupExpress, setupSessions,
    setupDb,
    logging.setupRequest,
    setupSwagger, setupSocketIO, setupViews,
    logging.setupError,
    listen
], function (err) {
    if (err) {
        console.log("Startup failed");
        throw err;
    }
});
