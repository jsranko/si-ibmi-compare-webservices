var http = require('http');
var ip = "localhost"; 
var port = $(NODEJS_PORT); 
var webserver = http.createServer((req, res) => { 
  res.writeHead(200, {'Content-Type': 'text/plain'}); 
  res.end('Hello World\n');
});
webserver.listen(port);
console.log('Server running at http://' + ip + ':' + port);