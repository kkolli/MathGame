//
// ViewController.swift
// SwiftBook
//
// Created by Brian Coleman on 2014-07-07.
// Copyright (c) 2014 Brian Coleman. All rights reserved.
//import UIKit

import UIKit
import SpriteKit
import Alamofire

class LoginViewController: UIViewController, FBLoginViewDelegate {
    @IBOutlet var fbLoginView : FBLoginView!
    var alreadyFetched = false
    var user: FBGraphUser!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        println("loaded login view controller")
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
            "fbID": user.objectID,
            "firstName": user.first_name,
            "lastName" : user.last_name,
            //"friends": data.objectForKey("data") as NSArray,
            "friends_page" : data
        ]
        println("PRINTING PARAMS: ")
        println(params)
        
        
        
        Alamofire.request(.POST, "http://mathisspeedy.herokuapp.com/create_check_user", parameters: params, encoding:.JSON)
        .response { (request, response, data, error) in
          println("request: \(request)")
          println("response: \(response)")
          println("error: \(error)")
        }
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
            "fbID": user.objectID,
            "firstName": user.first_name,
            "lastName" : user.last_name,
            //"friends": data.objectForKey("data") as NSArray,
            "friends_page" : data
        ]
        println("PRINTING PARAMS: ")
        println(params)
        
        
        
        Alamofire.request(.POST, "http://mathisspeedy.herokuapp.com/create_check_user", parameters: params, encoding:.JSON)
        .response { (request, response, data, error) in
          println("request: \(request)")
          println("response: \(response)")
          println("error: \(error)")
        }
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "login_segue" {
            println("performing segue")
            let vc = segue.destinationViewController as ViewController2
            
        }
        
    }
    
}
