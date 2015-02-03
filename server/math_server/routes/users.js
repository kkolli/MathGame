var express = require('express');
var router = express.Router();

var mongoose = require('mongoose')
  , Users = mongoose.model('Users');

// Create user
exports.createFbUser = function(req, cb){
  console.log("JSON from create: " + JSON.stringify(req.body, null, '\t'));
  var newUser = null;
  if (validateFields(req.body)) {
  	console.log("VALIDATED FIELDS!");
  	fbUserExists(req.body.fbID, function(err, exists) {
      if(err) return cb(err);
      if (exists) return cb("Duplicate User");
      newUser = new Users(req.body);

	  console.log("this new user has id: " + newUser.id);
	  newUser.save(function(err, user){
	    if(err) return cb(err);
	    console.log("created user!");
	    return cb();
	  });
    });
  } else {
  	return cb("Could Not Validate Fields");
  }

}

function fbUserExists(fbId, cb) {
  Users.findOne({fbID: fbId}, function(err, doc) {
    if(err) return cb(err);
    // if the doc is null, none found with this id, just return null
    // console.log("doc: " + JSON.stringify(doc));
    return cb(err, (doc !== null)); 
  })
}

/*
Simply just return if these fields exist. 
Friends is an optional field
*/

function validateFields(data) {
  return (data.fbID && data.firstName && data.lastName);
}
// List all users
exports.list = function(req, res){
  Users.find(function(err,users){
    if(err) return res.end(JSON.stringify(err));
    else return res.end(JSON.stringify(users));
    
  });
}

// Update user
exports.update = function(req, res, next){
  var user = req.user;

  console.log("req.body: " + JSON.stringify(req.body,null,'\t'));
  // remove password attribute from form if not changing
  if (!req.body.password) delete req.body.password;
  // ensure valid current password
  user.validPassword(req.body.currentPassword, function(err, isMatch){
    if(err) return next(err);
    if(isMatch) return updateUser();
    else return failedPasswordConfirmation();
  });
  // Handle correct current password and changes to user
  function updateUser(){
    user.set(req.body);
    user.save(function(err, user){
      if (err && err.code == 11001){
        var duplicatedAttribute = err.err.split("$")[1].split("_")[0];
        req.flash('error', "That " + duplicatedAttribute + " is already in use.");
        return res.redirect('/account');
      }
      if(err) return next(err);
      
      // User updated successfully, redirecting
      
      req.flash('success', "Account updated successfully.");
      return res.redirect('/account');
    });
  }
}

exports.profile_update = function(req, res, next) {
  var user = req.user;
  var data = req.body;
  User.findOne({username: user.username}, function(err, doc) {
    if(data.profile_pic) doc.profile_url = data.profile_pic;
    if(data.status) doc.status = data.status;
    if(data.about) doc.about = data.about;
    console.log("JSON from profupdate: " + JSON.stringify(req.body, null, '\t') + "\n" + JSON.stringify(doc, null, '\t'))

    doc.save(function(err) { 
      if(err) {
        req.flash('error', "error while saving your data");
        next(err);
      } else {
        req.flash('success', "Account updated successfully");
        res.redirect('/profile');
      }
     });
  });
}



// Validations for user objects upon user update or create
exports.userValidations = function(req, res, next){
  console.log("JSON from user valid: " + JSON.stringify(req.body, null, '\t'))
  var creatingUser = req.url == "/register";
  var updatingUser = !creatingUser; // only to improve readability
  req.assert('email', 'You must provide an email address.').notEmpty();
  req.assert('firstName', 'First Name is required.').notEmpty();
  req.assert('lastName', 'Last Name is required.').notEmpty();
  req.assert('email', 'Your email address must be valid.').isEmail();
  req.assert('username', 'Username is required.').notEmpty();
  if(creatingUser || (updatingUser && req.body.password)){
    req.assert('password', 'Your password must be 6 to 20 characters long.').len(6, 20);
  }
  var validationErrors = req.validationErrors() || [];
  if (req.body.password != req.body.passwordConfirmation) validationErrors.push({msg:"Password and password confirmation did not match."});
  if (validationErrors.length > 0){
    validationErrors.forEach(function(e){
      req.flash('error', e.msg);
    });
    // Create handling if errors present
    if (creatingUser) return res.render('users/registration', {user : new User(req.body), errorMessages: req.flash('error')});
    // Update handling if errors present
    else return res.redirect("/account");
  } else next();
}

// Process password reset request
exports.generate_password_reset = function(req, res, next){
  // Validations
  req.assert('email', 'You must provide an email address.').notEmpty();
  req.assert('email', 'Your email address must be valid.').isEmail();
  var validationErrors = req.validationErrors() || [];
  if (validationErrors.length > 0){
    validationErrors.forEach(function(e){
      req.flash('error', e.msg);
    });
    return res.redirect("/reset_password");
  }
  // Passed validations
  User.findOne({email:req.body.email}, function(err, user){
    if(err) return next(err);
    if(!user){
      // Mimic real behavior if someone is attempting to guess passwords
      req.flash('success', "You will receive a link to reset your password at "+req.body.email+".");
      return res.redirect('/');
    }
    user.generatePerishableToken(function(err,token){
      if(err) return next(err);
      // Generated reset token, saving to user
      user.update({
        resetPasswordToken : token,
        resetPasswordTokenCreatedAt : Date.now()
      }, function(err){
        if(err) return next(err);
        // Saved token to user, sending email instructions
        res.mailer.send('mailer/password_reset', {
            to: user.email,
            subject: 'Password Reset Request',
            username: user.username,
            token: token,
            urlBase: "http://"+req.headers.host+"/password_reset"
          }, function(err) {
            if(err) return next(err);
            // Sent email instructions, alerting user
            req.flash('success', "You will receive a link to reset your password at "+req.body.email+".");
            res.redirect('/');
          });
      });
    });
  });
}

// Get password reset page
exports.password_reset = function(req, res, next){
  res.render("users/password_reset", {token : req.query.token, username : req.query.username});
}


// module.exports = router;

