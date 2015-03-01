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
Takes the data array above and returns a list of ids
*/
function fbDataObjToFBID(friendsData) {
  var result = [];
  friendsData.forEach(function(friend) {
    result.push(friend.fbID);
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
/*
{
        "_id": "54d1d9a823883d0300e6456a",
        "fbID": "987654321",
        "firstName": "test1",
        "lastName": "test1pw",
        "__v": 1,
        "score": [1, 2, 3, 4],
        "friends": [
            "54d3bb8f643155030037eb75"
        ],
        "createdAt": "2015-02-04T08:34:48.669Z"
    }


currently - [1, 2, 3, 4]
obj = { 
   "user": fbid,
   "highscore": .... 
}

res.end(JSON.stringify(obj))
*/


/*Array.max = function(array){
  return Math.max.apply(Math, array);

};
*/

/*function highestScore(array)
{
    var m = -Infinity, i = 0, n = a.length;

    for (; i != n; ++i) {
        if (a[i] > m) {
            m = a[i];
        }
    }
    return m;
}
*/



exports.getHighScores = function(req,res){
  Users.findOneAndUpdate({fbID: req.params.fbID}, {$push: {"score": {
        $each:[20,30],
        $sort: -1,
        $slice: 1
    }}} , 
    function(err,users){ //get users score based on fb idea
    if(err) return res.end(JSON.stringify(err));
    console.log("users: " + JSON.stringify(users));
     return res.end(JSON.stringify(users));
    
  });
}

//Post a Score
exports.sendHighScores = function(req,res){
  Users.findOneAndUpdate({fbID: req.params.fbID} ,{$push: {"score": req.body.score}},
    function(err,user){
      if(err) {
        res.sendStatus(400);
        return res.end(JSON.stringify(err));
      }
      res.sendStatus(200);
    }
  );
}

/*
Request -> fbID

Return -> 
if Error:
status 400, and the error as well

if no Error:
status 200, return the list of user friends
friends: [
{
   (friend data object)
  firstName: ...
  lastName: ...
  highScore: ...
}
]
*/
exports.getFriendScores = function(req, res) { 
  Users.findOne({fbID:req.params.fbID},function(err,user){
    if(err || !user) {
      res.status(400);
      if (!user) { 
        return res.end("user not found"); 
      }
      res.end(JSON.stringify(err));
      return
    }
    var friends = user.friends;
    // in other words, if loner
    if (!friends.length || friends.length === 0) {
      res.status(200);
      res.end(JSON.stringify({friends : []}));
    } else {
      Users.find({
        '_id' : {
          $in: friends
        }
      }, function(err, myFriends) {
        res.status(200);
        var result = {
          friends: myFriends
        }
        res.end(JSON.stringify(result, null, '\t'));
      });
    }
  });
}
