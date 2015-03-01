var mongoose = require('mongoose')
  , Schema = mongoose.Schema;

var UserSchema = new Schema({
  fbID : {type: String, required: true, index: { unique: true }},
  createdAt : { type: Date, default: Date.now },
  // username : { type: String, required: true, index: { unique: true } },
  firstName : { type: String, required: true, index : { unique: false } },
  lastName : { type: String, required: true, index: { unique: false } },
  friends : [String], // friends are a string of Id's where Id's are the auto id's in mongo
  score: {type: [Number]}
});

module.exports = mongoose.model('Users', UserSchema);
