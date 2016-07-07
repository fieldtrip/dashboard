var express = require('express');
var bodyParser = require('body-parser');
var mongodb = require("mongodb");
var ObjectID = mongodb.ObjectID;

var app = express();
app.use(bodyParser.json());

// Create a database variable outside of the database connection callback to reuse the connection pool in your app.
var db;

var COLLECTION = process.env.MONGODB_COLLECTION;

if (typeof COLLECTION == 'undefined') {
  console.log('required environment variable is not set');
  process.exit(1);
}

// Connect to the database before starting the application server. 
mongodb.MongoClient.connect(process.env.MONGODB_URI, function (err, database) {
  if (err) {
    console.log(err);
    process.exit(1);
  }

  // Save database object from the callback for reuse.
  db = database;
  console.log("Database connection ready");

  // Initialize the app.
  var server = app.listen(process.env.PORT || 3002, function () {
    var port = server.address().port;
    console.log("App now running on port", port);
  });
});

// Generic error handler used by all endpoints.
function handleError(res, reason, message, code) {
  console.log("ERROR: " + reason);
  res.status(code || 500).json({"error": message});
}

/*  "/test"
 *    GET: finds all tests
 *    POST: creates a new test
 */

app.post("/test", function(req, res) {
  var newTest = req.body;
  newTest.createDate = new Date();
  console.log(newTest);

  if (!(req.body.testName || req.body.ftVersion || req.matabVersion)) {
    handleError(res, "Invalid user input", "Must provide required fields.", 400);
  }

  db.collection(COLLECTION).insertOne(newTest, function(err, doc) {
    if (err) {
      handleError(res, err.message, "Failed to create new test.");
    } else {
      res.status(201).json(doc.ops[0]);
    }
  });
});

app.get("/test", function(req, res) {
  db.collection(COLLECTION).find({}).toArray(function(err, docs) {
    if (err) {
      handleError(res, err.message, "Failed to get tests.");
    } else {
      res.status(200).json(docs);
    }
  });
});

/*  "/test/:id"
 *    GET: find test by id
 *    PUT: update test by id
 *    DELETE: deletes test by id
 */

app.get("/test/:id", function(req, res) {
  db.collection(COLLECTION).findOne({ _id: new ObjectID(req.params.id) }, function(err, doc) {
    if (err) {
      handleError(res, err.message, "Failed to get contact");
    } else {
      res.status(200).json(doc);
    }
  });
});

app.put("/test/:id", function(req, res) {
  var updateDoc = req.body;
  delete updateDoc._id;

  db.collection(COLLECTION).updateOne({_id: new ObjectID(req.params.id)}, updateDoc, function(err, doc) {
    if (err) {
      handleError(res, err.message, "Failed to update contact");
    } else {
      res.status(204).end();
    }
  });
});

app.delete("/test/:id", function(req, res) {
  db.collection(COLLECTION).deleteOne({_id: new ObjectID(req.params.id)}, function(err, result) {
    if (err) {
      handleError(res, err.message, "Failed to delete contact");
    } else {
      res.status(204).end();
    }
  });
});


