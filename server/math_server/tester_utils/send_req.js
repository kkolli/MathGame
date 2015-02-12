/*
This is a utility node for sending requests to other localhost stuff for testing purposes
*/

var request = require('request');
var argv = require('minimist')(process.argv.slice(2));
var fs = require('fs');

var port = !argv.port ? 3000 : argv.port;
var isGet = !argv.m ? true : (argv.m == "GET");
var path = !argv.p ? "" : argv.p;
var file = !argv.f ? null : argv.f;
var json_data;
var url = 'http://localhost:' + port + "/" + path;

var usage = "-port [PORT] -m [GET | POST] -p [path] -f [json_file]";
console.log("USAGE: " + usage);

console.log("url: " + url + " isGEt? : " + isGet);
console.log("JSON string: " + JSON.stringify(argv, null, '\t'));

if (file) {
  json_data = JSON.parse(fs.readFileSync(file, 'utf8'));
  console.log("json data from file: " + file + " has data: \n" + JSON.stringify(json_data, null, '\t'));
} else {
	if (!isGet) {
		console.log("It's a post request.... but you need to have a file....");
		return;
	}
}
// return;
if (isGet) {
	request(url, function(err, resp, body) {
		if(err) return console.log("err: " +  JSON.stringify(err, null, '\t'));
		console.log("body: " + JSON.stringify(body, null, '\t'));
	});
} else {
	console.log("posting to url: " + url);

	var options = {
	  uri: url,
	  method: 'POST',
	  json: json_data
	};

	request(options, function(err, resp,  body) {
		if(err) return console.log("err: " +  JSON.stringify(err, null, '\t'));
		console.log("body: " + JSON.stringify(body, null, '\t'));
	})
}