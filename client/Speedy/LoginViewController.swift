//
//  ViewController.swift
//  Speedy
//
//  Created by Krishna Kolli on 1/21/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import UIKit
<<<<<<< HEAD
=======
import SpriteKit
import Alamofire
>>>>>>> adding facebook integration for friends request and almos post request to heroku

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends"]
        
    }
    
    // Facebook Delegate Methods
    
    func loginViewShowingLoggedInUser(loginView : FBLoginView!) {
        println("User Logged In")
        performSegueWithIdentifier("login_segue", sender: nil);
        //perform a segue
    }
    
    /*
    After facebook returns the login info, call the facebook API to give us the friends list
    When we get the info back, make a post request to our server
    */
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser) {
        println("User: \(user)")
        println("User ID: \(user.objectID)")
        println("User Name: \(user.name)")
        var userEmail = user.objectForKey("email") as String
        println("User Email: \(userEmail)")
        
        // call method to handle getting the user's current/updated friends
        getFacebookFriendsList(user, makePostReq);
    }
    
    func makePostReq(user: FBGraphUser, data: NSDictionary) {
        /*Issue a post request to our server, with the updated/or new user with friends */
        let params = [
            "user_id": user.objectID,
            "user_first_name": user.first_name,
            "user_last_name" : user.last_name,
            "friends": data.objectForKey("data") as NSArray,
            "other" : data
        ]
        println("PRINTING PARAMS: ")
        println(params)
        /*Alamofire.request(.POST, "http://[HEROKU_URL]/create_update_fbuser", parameters: params)
        .response { (request, response, data, error) in
        println(request)
        println(response)
        println(error)
        }*/
    }
    
    func getFacebookFriendsList(user: FBGraphUser, handler: (FBGraphUser, NSDictionary) -> Void) {
        // Get List Of Friends
        var friendsRequest : FBRequest = FBRequest.requestForMyFriends()
        friendsRequest.startWithCompletionHandler{(connection:FBRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
            var resultdict = result as NSDictionary
            // println("Result Dict: \(resultdict)")
            var data : NSArray = resultdict.objectForKey("data") as NSArray
            
            println("calling handler")
            handler(user, resultdict)
            println("called handler...")
            
            
            /* for i in 0...(data.count-1) {
                let valueDict : NSDictionary = data[i] as NSDictionary
                let id = valueDict.objectForKey("id") as String
                println("the id value is \(id)")
            }

            
            var friends = resultdict.objectForKey("data") as NSArray
            println("Found \(friends.count) friends")*/
        }
    }
    
    func loginViewShowingLoggedOutUser(loginView : FBLoginView!) {
        println("User Logged Out")
    }
    
    func loginView(loginView : FBLoginView!, handleError:NSError) {
        println("Error: \(handleError.localizedDescription)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

