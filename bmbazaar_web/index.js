
// set up Express
var express = require('express');
var app = express();
var mongoose = require('mongoose');

mongoose.connect("mongodb+srv://ndaniyarov:HelloNitisha@cluster0.sazvw.mongodb.net/items_services?retryWrites=true&w=majority");
mongoose.set('useFindAndModify', false);

const router = express.Router()               // router will be used to handle the request.
const multer = require('multer')              // multer will be used to handle the form data.
const Aws = require('aws-sdk') 					// aws-sdk library will used to upload image to s3 bucket.

//require("dotenv/config")   // for using the environment variables that stores the confedential information.

// set up BodyParser
var bodyParser = require('body-parser');
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

// import the Person class from Person.js
var Item = require('./Item.js');

// Set up ejs
app.use(express.static(__dirname + '/public'));
app.set('views', __dirname + '/public');
app.engine('html', require('ejs').renderFile);
app.set('view engine', 'html');

/***************************************/

// endpoint for creating a new person
// this is the action of the "create new person" form
app.use('/create', (req, res) => {
	// construct the Person from the form data which is in the request body

	// Get Item type
	var service = false;
	//
	// if (req.body.getElementById('isService').checked) {
	// 	service = true
	// }

	var newItem = new Item ({
		title: req.query.title,
		description: req.query.description,
		isService: req.query.isService,
		venmo: req.query.venmo,
		location: req.query.location,
		price: req.query.price,
		image: req.query.image

		// title: req.body.title,
		// description: req.body.description,
		// isService: service,
		// venmo: req.body.venmo,
		// location: req.body.location,
		// price: req.body.price,
		// image: req.body.image
	    });

	// save the person to the database
	newItem.save( (err) => {
		if (err) {
		    res.type('html').status(200);
		    res.write('uh oh: ' + err);
		    console.log(err);
		    res.end();
		}
		else {
		    // display the "successfull created" message
		    res.send('successfully added ' + newItem.title + ' to the database');
		}
	});
});

app.use('/delete', (req, res) => {
	var filter = { 'title': req.query.title, 'venmo': req.query.venmo};
	console.log(filter);

	Item.findOneAndDelete(filter, (err, orig) => {
		if (err) {
			res.json({ 'status': err });
		}
		else if (!orig) {
			res.json({ 'status': 'no resource' });
		}
		else {
			res.json({ 'status': 'success' });
		}
	});
});



// endpoint for showing all the people
app.use('/all', (req, res) => {

	// find all the Person objects in the database
	Item.find( {}, (err, items) => {
		if (err) {
		    res.type('html').status(200);
		    console.log('uh oh' + err);
		    res.write(err);
		}
		else {
		    if (items.length == 0) {
			res.type('html').status(200);
			res.write('There are no items');
			res.end();
			return;
		    }
		    else {
			res.type('html').status(200);
			res.write('Here are the items in the database:');
			res.write('<ul>');
			// show all the items
			items.forEach( (item) => {
				res.write('<li>Title: ' + item.title + '; description: ' + item.description + '; service?: '+ item.isService +'; venmo: ' + item.venmo + '; location: ' + item.location + '; price: ' + item.price + '; image: ' + item.image + '</li>');
			    });
			res.write('</ul>');
			res.end();
		    }
		}
	    }).sort({ 'price': 'asc' }); // this sorts them BEFORE rendering the results
    });

// endpoint for accessing data via the web api
// to use this, make a request for /api to get an array of all Person objects
// or /api?name=[whatever] to get a single object
app.use('/api', (req, res) => {

	// construct the query object
	var queryObject = {};
	if (req.query.title) {
	    // if there's a name in the query parameter, use it here
	    queryObject = { "title" : req.query.title };
	}

	Item.find( queryObject, (err, items) => {
		console.log(items);
		if (err) {
		    console.log('uh oh' + err);
		    res.json({});
		}
		else if (items.length == 0) {
		    // no objects found, so send back empty json
		    res.json({});
		}
		else if (items.length == 1 ) {
		    var item = items[0];
		    // send back a single JSON object
		    res.json( { 'title' : item.title , "description" : item.description, "price" : item.price, "isService" : item.isService, "location" : item.location, "venmo" : item.venmo, "image" : item.image } );
		}
		else {
		    // construct an array out of the result
		    var returnArray = [];
		    items.forEach( (item) => {
			    returnArray.push( { 'title' : item.title , "description" : item.description, "price" : item.price, "isService" : item.isService, "location" : item.location, "venmo" : item.venmo, "image" : item.image } );
			});
		    // send it back as JSON Array
				eitherSort(returnArray);
				res.json(returnArray);
		}

	    });
    });




/*************************************************/

app.use('/public', express.static('public'));

app.use('/', (req, res) => { res.redirect('/public/personform.html'); } );

app.listen(3000,  () => {
	console.log('Listening on port 3000');
    });

const eitherSort = (arr = []) => {
   const sorter = (a, b) => {
      return +a.price - +b.price;
   };
   arr.sort(sorter);
};
