var mongoose = require('mongoose');

// the host:port must match the location where you are running MongoDB
// the "myDatabase" part can be anything you like
//mongoose.connect("mongodb+srv://ndaniyarov:HelloNitisha@cluster0.sazvw.mongodb.net/users?retryWrites=true&w=majority");

var Schema = mongoose.Schema;

var userSchema = new Schema({
 username: {type: String, required: true, unique: true},
 items: Array,

});

// export personSchema as a class called Person
module.exports = mongoose.model('User', userSchema);

userSchema.methods.standardizeName = function() {
    this.title = this.title.toLowerCase();
    return this.title;
}