var express = require('express');
var bodyParser = require('body-parser');
var mongodb = require('mongodb');

mongodb.MongoClient.connect('mongodb://localhost:27017/cis', function (err, db) {
	if (err)
		throw err;

	var app = express();

	app.use(bodyParser.urlencoded({ extended: false }));

	function handle (req, res, data) {
		if(typeof data.group == 'undefined'){
			res.writeHead(400, "no 'group' defined", {'content-type' : 'text/plain'});
			res.end();
			return;
		}
		switch(req.params.method) {
			case 'write':
				if(typeof data.type == 'undefined'){
					res.writeHead(400, "no 'type' defined", {'content-type' : 'text/plain'});
					res.end();
					return;
				}
				if(typeof data.value == 'undefined'){
					res.writeHead(400, "no 'value' defined", {'content-type' : 'text/plain'});
					res.end();
					return;
				}
				var entry = {
					timestamp: new Date(),
					type: data.type,
					value: data.value
				};
				db.collection(data.group).insertOne(entry);

				res.writeHead(200, {
					'Access-Control-Allow-Origin': req.headers.origin || '*',
					'Content-Type': 'application/json'
				});
				res.end();
				break;
			case 'write-bulk':
				// TODO add functions to insert bulk data
				//db.collection(data.group).insertMany();

				res.writeHead(501, "write bulk of data is not yet implemented", {'content-type' : 'text/plain'});
				res.end();
				break;

			case 'read-all':
				if(typeof data.type == 'undefined'){
					res.writeHead(400, "no 'type' defined", {'content-type' : 'text/plain'});
					res.end();
					return;
				}
				db.collection(data.group).find({ type: data.type }).toArray(function (err, docs) {
					if (err)
						throw err;

					res.writeHead(200, {
						'Access-Control-Allow-Origin': req.headers.origin || '*',
						'Content-Type': 'application/json'
					});
					res.end(JSON.stringify(docs));
				});
				break;

			case 'read':
				if(typeof data.type == 'undefined'){
					res.writeHead(400, "no 'type' defined", {'content-type' : 'text/plain'});
					res.end();
					return;
				}
				var from = data.from;
				var to = data.to;
				if(typeof from == 'undefined') {
					from = new Date(0);
				}
				if(typeof to == 'undefined') {
					to = new Date();
				}

				db.collection(data.group).find({
					type: data.type,
					timestamp: {
						$gte: new Date(from),
						$lte: new Date(to)
					}
				}).toArray(function (err, docs) {
					if (err)
						throw err;

					res.writeHead(200, {
						'Access-Control-Allow-Origin': req.headers.origin || '*',
						'Content-Type': 'application/json'
					});
					res.end(JSON.stringify(docs));
				});
				break;

			default:
				res.writeHead(404);
				res.end();
				break;
		}
	}

	app.get('/:method', function(req, res) { handle(req, res, req.query); });
	app.post('/:method', function(req, res) { handle(req, res, req.body); });

	app.listen(process.env.PORT || 8080);
});
