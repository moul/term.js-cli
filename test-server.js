var tty = require('tty.js');

var app = tty.createServer({
  shell: 'bash',
  shellArgs: ["-c", 'date; while true; do date; sleep 1; done'],
  users: {
    foo: 'bar'
  },
  port: 8000
});

app.get('/foo', function(req, res, next) {
  res.send('bar');
});

app.listen();
