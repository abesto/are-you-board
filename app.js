var http = require('http'),
    ss = require('socketstream');

var libs = {
  jquery: {
    main: 'libs/jquery/jquery.js',
    livequery: 'libs/jquery.livequery/dist/jquery.livequery.js'
  },
  bootstrap: {
    js: 'libs/bootstrap/dist/js/bootstrap.js',
    css: 'libs/bootstrap/bootstrap.css'
  },
  lodash: 'libs/lodash/dist/lodash.js',
  signals: 'libs/js-signals/dist/signals.js',
  hasher: 'libs/hasher/dist/js/hasher.js',
  crossroads: 'libs/crossroads/dist/crossroads.js',
  async: 'libs/async/lib/async.js',
  moment: 'libs/moment/moment.js',
  mocha: {
    js: 'libs/mocha/mocha.js',
    css: 'libs/mocha/mocha.css'
  },
  chai: 'libs/chai/chai.js',
  sinon: 'libs/sinonjs/sinon.js'
};

// Define a single-page client called 'main'
ss.client.define('main', {
  view: 'app.jade',
  css:  ['app.less', 'ludo.less', libs.bootstrap.css],
  code: [
    libs.jquery.main, libs.jquery.livequery, libs.bootstrap.js, libs.lodash, libs.signals, libs.hasher,
    libs.crossroads, libs.async, libs.moment,
    'app'
  ],
  tmpl: '*'
});
ss.http.route('/', function(req, res){
  res.serveClient('main');
});

// Code Formatters
ss.client.formatters.add(require('ss-coffee'));
ss.client.formatters.add(require('ss-jade'));
ss.client.formatters.add(require('ss-less'));
ss.client.templateEngine.use(require('ss-hogan'));

// Set up global helpers
require('./server/setup').loadAppGlobals();


// Minimize and pack assets if you type: SS_ENV=production node app.js
if (ss.env === 'production') {
    ss.client.packAssets();
    winston.handleExceptions(new winston.transports.File({ filename: 'exceptions.log' }));
    winston.add(winston.transports.File, { filename: 'app.log' });
    ss.session.store.use('redis');
    ss.publish.transport.use('redis');
    ss.responders.add(require('ss-heartbeat-responder'));
} else {
    // Start Console Server (REPL)
    // To install client: sudo npm install -g ss-console
    // To connect: ss-console <optional_host_or_port>
    var consoleServer = require('ss-console')(ss);
    consoleServer.listen(5000);
    // Run mocha tests on /mocha
    ss.client.define('mocha', {
        view: 'mocha.jade',
        css:  [libs.mocha.css],
        code: [
          libs.async, libs.chai, libs.jquery.main, libs.mocha.js, libs.sinon, libs.lodash, libs.signals,
          libs.crossroads, libs.hasher,
          'app', 'mocha'
        ]
    });
    ss.http.route('/mocha', function(req, res){
        res.serveClient('mocha');
    });
    ss.responders.add(require('ss-heartbeat-responder'), { logging: 1, fakeRedis: true });
    // Debug logging
    winston.remove(winston.transports.Console);
    winston.add(winston.transports.Console, {
      level: 'silly',
      handleExceptions: true,
      colorize: true,
      timestamp: true
    });
}

// Start web server
var server = http.Server(ss.http.middleware);
var port = process.argv[2] || 3000;
server.listen(port, '127.0.0.1');

// Start SocketStream
ss.start(server);
