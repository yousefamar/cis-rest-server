var express = require('express');
var bodyParser = require('body-parser');
var mongodb = require('mongodb');

mongodb.MongoClient.connect('mongodb://localhost:27017/api', function (err, db) {
	if (err)
		throw err;

	var app = express();

	app.use(bodyParser.urlencoded({ extended: false }));

	function handle (req, res, data) {
		switch(req.params.method) {

			case 'write':
				var entry = {
					timestamp: new Date(),
					type: data.type,
					value: data.value
				};
				db.collection(data.group).insert(entry);

				res.writeHead(200, {
					'Access-Control-Allow-Origin': req.headers.origin || '*',
					'Content-Type': 'application/json'
				});
				res.end();
				break;

			case 'read-all':
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
				db.collection(data.group).find({
					type: data.type,
					timestamp: {
						$gte: new Date(data.from),
						$lte: new Date(data.to)
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
