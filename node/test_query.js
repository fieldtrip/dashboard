#!/usr/bin/env node

var mongodb = require("mongodb");
var ObjectID = mongodb.ObjectID;

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

  // Perform a query
  db.collection(COLLECTION).find({matlabversion: '2015b', functionname: 'test_bug1298'}).toArray(function(err, docs) {
    if (err) {
      handleError(res, err.message, "Failed to get test results.");
    } else {
      console.log(docs);
    }
  });

});
