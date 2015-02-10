var express = require('express');
var router = express.Router();

var mongoose = require('mongoose')
  , Users = mongoose.model('Users')
  , request = require('request');

// Create user
exports.createFbUser = function(req, cb){
  console.log("JSON from create: " + JSON.stringify(req.body, null, '\t'));
  var newUser = null;
  if (validateFields(req.body)) {
  	console.log("VALIDATED FIELDS!");

    /*
    Now I have to do 2 things- 
    1) associate fbID's to ID's in mongoose
    2) check if user already existed


    
    */

  	fbUserExists(req.body.fbID, function(err, exists) {
      if(err) return cb(err);
      if (exists) return cb("Duplicate User");

      // if not duplicate, find all of users' friends and create the new user
      // req.body.friends = [12345, 123456, 1234567];
      var myFriends = req.body.friends_page;
      console.log("type: " + typeof myFriends);
      if(myFriends && myFriends.data && myFriends.data.length !== 0) {

        addAllFBFriends(myFriends, [], function(err, friends) {
          if (err) { return cb(err); }
          // else { console.log("friends: " + JSON.stringify(friends, null, '\t')); }
          // initialize it back to empty list
          req.body.friends = [];
          console.log("Our friends " + JSON.stringify(fbDataObjToArr(friends), null, '\t')); 
          newUser = new Users(req.body);
          giveMeIDList(fbDataObjToArr(friends), newUser._id, function(err, map) {
            if (err) return cb(err);
            console.log("found friends: " + JSON.stringify(map, null, '\t'));
            newUser.friends = map;
            newUser.save(function(err, user) {
              return cb(err);
            })
          });
        });
      } else {
        newUser = new Users(req.body);
    	  console.log("this new user has id: " + newUser.id);
    	  newUser.save(function(err, user){
    	    if(err) return cb(err);
    	    console.log("created user!");
    	    return cb();
    	  });
      }
    });
  } else {
  	return cb("Could Not Validate Fields");
  }

}

/*
Friends comes in as:
    {
      data: [
      {
      id: "780289285358033",
      name: "Edward Chiou",
      first_name: "Edward",
      last_name: "Chiou"
      }
      ],
      paging: {
      next: "https://graph.facebook.com/v2.2/10152612343177227/friends?fields=id,name,first_name,last_name&limit=25&offset=25&format=json&access_token=CAAJLVBsv3N4BAAcnbRvwxRyA4hTA9y2oCbvhwuXpoI2YZCTpAkZACZAR04Vo8IksMMMhWduFm1P05DYQFGWmhfBzQTetZCiOHnR0YNbox1MW9QcVnEGbn4erxSoJbc41qyZBgyVXORaEqQbhK7AXB8WO6nz00GJvwF5HLX7ZB3JLaH4UtDp4Yk82IpiPNW1khkfXpy5zWloAWnQkUlKSLG592ilJm8GWsba4D9SE38YwZDZD&__after_id=enc_Aeybkze8Iznm7aaVueyL0AsuTakmr--EbDCNo3vN-OzWM1IWGKbb05WjLmjIqc-OFZdJ2V9fqjd5Pz47z9YGu-0M"
      },
      summary: {
      total_count: 575
      }
    }
*/
function addAllFBFriends(friends, currData, cb) {
  // console.log("friends HERE: " + typeof friends + " and is: \n" + JSON.stringify(friends, null, '\t'));
  if (!friends.data) {return cb("eww error... data should never be undefined");}
  if (friends.data.length === 0) { return cb(null, currData); }
  var allData = currData.concat(friends.data);
  var next = "";
  if (friends.paging && friends.paging.next) {
    next = friends.paging.next;
    request(next, function(err, resp, body) {
      if (err) return cb(err); 
      else return addAllFBFriends(JSON.parse(body), allData, cb);
    });
  } else {
    return cb(null, allData);
    // if paging doesn't exist, just return
  }
}

/*
Takes the data array above and returns a list of ids
*/
function fbDataObjToArr(friendsData) {
  var result = [];
  friendsData.forEach(function(friend) {
    result.push(friend.id);
  });
  return result;
}

/*
given a list of facebook ID's, give back list of friends' ids
*/
function giveMeIDList(listIDs, myFBID, cb) {
  console.log("USing Users to find ... : " + JSON.stringify(listIDs, null, '\t'));
  Users.find({
    'fbID' : {
      $in: listIDs
    }
  }, function(err, docs) {
    if (err) return cb(err);
     console.log("new docs: " + JSON.stringify(docs, null, '\t'));

    var result = [];
    docs.forEach(function(friend) {
      // if each of our friends doesn't contain us as reference, push it in
      if (friend.friends.indexOf(myFBID) === -1) {
        friend.friends.push(myFBID);
      }
      friend.save();
      result.push(friend._id);
    })


    cb(err, result);
  });
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

//Get the HighScores
exports.getHighScores = function(req,res){
  Users.find({fbID:req.params.fbID},function(err,user){
    if(err) return res.end(JSON.stringify(err));
    return res.end(JSON.stringify(user));
  });
}

//Post a Score
exports.sendHighScores = function(req,res){
  console.log("req body: " + JSON.stringify(req.body, null, '\t'));
  Users.findOneAndUpdate({fbID: req.params.Id} ,{$push: {"score": req.body.score}},
    function(err,user){
      if(err) {
        res.sendStatus(400);
        return res.end(JSON.stringify(err));
      }
      res.sendStatus(200);
    }
  );
}
