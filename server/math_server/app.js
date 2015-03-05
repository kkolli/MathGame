var express = require('express');
var path = require('path');
var favicon = require('serve-favicon');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');


var mongoose = require('mongoose');
var User = require('./models/user.js');
var routes = require('./routes/index');
var users = require('./routes/users');

var app = express();

var uristring = process.env.MONGOHQ_URL ||
                process.env.MONGOLAB_URI ||
                'mongodb://localhost/nodedemo';
// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');

// uncomment after placing your favicon in /public
//app.use(favicon(__dirname + '/public/favicon.ico'));
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use('/', routes);
// app.use('/users', users);

// Database Connection

mongoose.connect(uristring, function(err, res) {
  if(err) {
     console.log("ERROR occurred connecting to :" + uristring + '. ' + err);
  } else {
     console.log("MONGO connected! here: " + uristring);

  }
});


//the db connection on error or opened 
var db = mongoose.connection;

db.on('error', console.error.bind(console, 'connection error:'));
db.once('open', function callback() {
  console.log("MONGO open!");
});

app.get('/list_user', users.list);
app.get('/HighScores/:fbID', users.getHighScores);
app.get('/friend_scores/:fbID', users.getFriendScores);
app.post('/HighScores/:fbID', users.sendHighScores);
app.post('/create_check_user', function(req, res) {
    users.createFbUser(req, function(err, data) {
        if (err) { 
            res.status(400);
            console.log("there was an error: " + JSON.stringify(err));
            res.end ("there was an error: " + JSON.stringify(err));
        } else {
            res.end("succcess!");
        }
    });
});

app.post('/post', function(req, res) { 
    res.end(JSON.stringify(req.body));
})

// app.post('')

// catch 404 and forward to error handler
app.use(function(req, res, next) {
    var err = new Error('Not Found');
    err.status = 404;
    next(err);
});

// error handlers

// development error handler
// will print stacktrace
if (app.get('env') === 'development') {
    app.use(function(err, req, res, next) {
        res.status(err.status || 500);
        res.render('error', {
            message: err.message,
            error: err
        });
    });
}

// production error handler
// no stacktraces leaked to user
app.use(function(err, req, res, next) {
    res.status(err.status || 500);
    res.render('error', {
        message: err.message,
        error: {}
    });
});


module.exports = app;
