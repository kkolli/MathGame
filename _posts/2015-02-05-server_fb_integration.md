---
layout: post
title: Integrating the Server and Client with Facebook as the Glue
---

*Author: John Chou* 

In this blog post I'll discuss how I went about building the serverside component in Node.js, integrating swift with Facebook, and making requests with AlamoFire

-----

For the past 2 weeks I was working on the server side component of our application, and it required many different components to get it working.  I'll divide up the work that I did in 3 parts, though I transitioned from each of them quite frequently:

* The Facebook Integration
* The Client requests
* The Serverside

-----

### The Facebook Integration

![Initial Game Sequence](/images/fblogin.png)

So Facebook has a nice IOS SDK in Objective-C, but it doesn't have very good Swift support.  Therefore, we had to use a bridging header where I found a tutorial to do [here](www.brianjcoleman.com/tutorial-facebook-login-in-swift/)

From there, I was able to get facebook login to work correctly, the next task was that because we needed the users' friends information to be sent over via a POST request, we needed to make another subsequent facebook request for the users' friends.  After we finally got that information, we sent the information to the server.

-----

### The Client Requests

From the client, I had to handle the tasks of segueing into the next view controller, building up the user with its facebook credentials, sending the request to facebook, and issuing the post request to the heroku server.   The main challenge here was simply learning the swift language, which I actually found to be quite annoying in some areas.  But as with learning a new language, there's always a unique learning curve, and in retrospect, I think it was quite interesting.  However, a main plus-side to IOS that I've learned is that I don't have to deal with nasty XML since unlike Android, IOS's storyboard works beautifully, so props to them!

-----

### The Serverside

![JSON Image](/images/mathisspeedy_json.png)

On the serverside, we used node.js as our backend, powered by MongoDB and Express 4.0.  While the serverside was mostly just about getting user registration to work so that we could keep track of the users' friends and high scores, the biggest challenge 

In order to test with the client side, we deployed with Heroku, which although seemed straightforward, didn't work like we expected since the server had to be in the root directory of the .git file.  So we actually migrated to a different repository just for server deployment.  But after all the trouble... check it out! *mathisspeedy.herokuapp.com*

Thanks for reading!
