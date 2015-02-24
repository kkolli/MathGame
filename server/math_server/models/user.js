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

UserSchema.pre('save', function(next) {
  var user = this;
  next();

  // // only hash the password if it has been modified (or is new)
  // if (!user.isModified('password')) return next();

  // // generate a salt
  // bcrypt.genSalt(SALT_WORK_FACTOR, function(err, salt) {
  //   if (err) return next(err);
  //   // hash the password along with our new salt
  //   bcrypt.hash(user.password, salt, function(err, hash) {
  //     if (err) return next(err);
  //     // override the cleartext password with the hashed one
  //     user.password = hash;
  //     next();
  //   });
  // });
});



// UserSchema.methods.updateEditSettings = function(data, cb) {
//   UserSchema.findOne({username: data.username}, function(err, doc) {
//     if(data.profile_pic) doc.profile_url = data.profile_pic;
//     if(data.status) doc.status = data.status;
//     if(data.about) doc.about = data.about;
//     doc.save(function(err) { 
//       cb(err);
//     });
//   })
// }

module.exports = mongoose.model('Users', UserSchema);
