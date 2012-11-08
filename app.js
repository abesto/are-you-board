var http = require('http'),
    ss = require('socketstream');

// Define a single-page client called 'main'
ss.client.define('main', {
  view: 'app.jade',
  css:  ['app.styl'],
  code: ['libs/jquery.min.js', 'app'],
  tmpl: '*'
});
ss.http.route('/', function(req, res){
  res.serveClient('main');
});

// Code Formatters
ss.client.formatters.add(require('ss-coffee'));
ss.client.formatters.add(require('ss-jade'));
ss.client.formatters.add(require('ss-stylus'));

// Set up global helpers
require('./server/setup').loadAppGlobals();

// Minimize and pack assets if you type: SS_ENV=production node app.js
if (ss.env === 'production') {
    ss.client.packAssets();
    winston.add(winston.transports.File, { filename: 'app.log' });
    winston.handleExceptions(winston.transports.File, { filename: 'exceptions.log' });
    ss.session.store.use('redis');
    ss.publish.transport.use('redis');
} else {
    // Start Console Server (REPL)
    // To install client: sudo npm install -g ss-console
    // To connect: ss-console <optional_host_or_port>
    var consoleServer = require('ss-console')(ss);
    consoleServer.listen(5000);

    // Run mocha tests on /mocha
    ss.client.define('mocha', {
        view: 'mocha.jade',
        css:  ['libs'],
        code: ['libs', 'app', 'mocha']
    });
    ss.http.route('/mocha', function(req, res){
        res.serveClient('mocha');
    });
}

// Start web server
var server = http.Server(ss.http.middleware);
server.listen(3000);

// Start SocketStream
ss.start(server);