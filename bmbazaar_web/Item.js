var mongoose = require('mongoose');

// the host:port must match the location where you are running MongoDB
// the "myDatabase" part can be anything you like
mongoose.connect("mongodb+srv://ndaniyarov:HelloNitisha@cluster0.sazvw.mongodb.net/items_services?retryWrites=true&w=majority");

var Schema = mongoose.Schema;

var itemSchema = new Schema({
 title: {type: String, required: true, unique: true},
 description: String,
 isService: Boolean,
 venmo: String,
 location: String,
 price: {type: Number, required: true},
 image: String,
 email: String
});

// export personSchema as a class called Person
module.exports = mongoose.model('Item', itemSchema);

itemSchema.methods.standardizeName = function() {
    this.title = this.title.toLowerCase();
    return this.title;
}
