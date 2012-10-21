var http = require('http'),
    ss = require('socketstream');

// Load underscore.js into global object
// It's loaded with 'libs' on the client (libs/underscore-min.js)
global._ = require('underscore');

// Define a single-page client called 'main'
ss.client.define('main', {
  view: 'app.jade',
  css:  ['app.styl'],
  code: ['libs/jquery.min.js', 'app'],
  tmpl: '*'
});

// Serve this client on the root URL
ss.http.route('/', function(req, res){
  res.serveClient('main');
});

// Test client
ss.client.define('tests', {
    view: 'tests.jade',
    css:  ['libs/qunit-1.10.0.css'],
    code: ['libs', 'app', 'tests']
});
ss.http.route('/tests', function(req, res){
    res.serveClient('tests');
});

// Code Formatters
ss.client.formatters.add(require('ss-coffee'));
ss.client.formatters.add(require('ss-jade'));
ss.client.formatters.add(require('ss-stylus'));

// Use server-side compiled Hogan (Mustache) templates. Others engines available
ss.client.templateEngine.use(require('ss-hogan'));

// Minimize and pack assets if you type: SS_ENV=production node app.js
if (ss.env === 'production') ss.client.packAssets();

// Use Redis as session and pubsub backend
ss.session.store.use('redis');
ss.publish.transport.use('redis');

// Start web server
var server = http.Server(ss.http.middleware);
server.listen(3000);

// Start Console Server (REPL)
// To install client: sudo npm install -g ss-console
// To connect: ss-console <optional_host_or_port>
var consoleServer = require('ss-console')(ss);
consoleServer.listen(5000);

// Start SocketStream
ss.start(server);