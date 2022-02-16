// set up Express
var express = require('express');
var app = express();


// set up BodyParser
var bodyParser = require('body-parser');
app.use(bodyParser.urlencoded({ extended: true }));

// import the Person class from Person.js
var Item = require('./Item.js');

/***************************************/

// endpoint for creating a new person
// this is the action of the "create new person" form
app.use('/create', (req, res) => {
	// construct the Person from the form data which is in the request body
	var newItem = new Item ({
		title: req.query.title,
		description: req.query.description,
		isService: req.query.isService,
		venmo: req.query.venmo,
		location: req.query.location,
		price: req.query.price
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
	var filter = { 'title': req.query.title};
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
				res.write('<li>Title: ' + item.title + '; description: ' + item.description + '; service?: '+ item.isService +'; venmo: ' + item.venmo + '; location: ' + item.location + '; price: ' + item.price + '</li>');
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
	if (req.query.name) {
	    // if there's a name in the query parameter, use it here
	    queryObject = { "name" : req.query.name };
	}
    
	Person.find( queryObject, (err, persons) => {
		console.log(persons);
		if (err) {
		    console.log('uh oh' + err);
		    res.json({});
		}
		else if (persons.length == 0) {
		    // no objects found, so send back empty json
		    res.json({});
		}
		else if (persons.length == 1 ) {
		    var person = persons[0];
		    // send back a single JSON object
		    res.json( { "name" : person.name , "age" : person.age } );
		}
		else {
		    // construct an array out of the result
		    var returnArray = [];
		    persons.forEach( (person) => {
			    returnArray.push( { "name" : person.name, "age" : person.age } );
			});
		    // send it back as JSON Array
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
