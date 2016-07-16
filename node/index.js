#!/usr/bin/env node

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

/*  "/api"
 *    GET: finds all tests
 *    POST: creates a new test
 */

app.post("/api", function(req, res) {
  var newTest = req.body;
  newTest.createDate = new Date();
  console.log(newTest);

  if (!(req.body.fieldtripversion || req.matabversion)) {
    handleError(res, "Invalid user input", "Must provide required fields.", 400);
  }

  db.collection(COLLECTION).insertOne(newTest, function(err, doc) {
    if (err) {
      handleError(res, err.message, "Failed to post test results.");
    } else {
      res.status(201).json(doc.ops[0]);
    }
  });
});

app.get("/api", function(req, res) {
  // the ?key1=val1&key2=val2 arguments on the URL are used for querying
  if ( 'undefined' != typeof req.query.distinct ) {
    db.collection(COLLECTION).distinct(req.query.distinct, function(err,docs) {
      if (err) {
        handleError(res, err.message, "Failed to get test results.");
      } else {
        res.status(200).json(docs);
      }
    });
  }
  else {
    db.collection(COLLECTION).find(req.query).toArray(function(err, docs) {
      if (err) {
        handleError(res, err.message, "Failed to get test results.");
      } else {
        res.status(200).json(docs);
      }
    });
  }
});

// Example usage from http://stackoverflow.com/questions/15125920/how-to-get-distinct-values-from-an-array-of-objects-in-javascript
// uniqueBy(array, function(x){return x.age;}); // outputs [17, 35]
function uniqueBy(arr, fn) {
  var unique = {};
  var distinct = [];
  arr.forEach(function (x) {
    var key = fn(x);
    if (!unique[key]) {
      distinct.push(key);
      unique[key] = true;
    }
  });
  return distinct;
}
