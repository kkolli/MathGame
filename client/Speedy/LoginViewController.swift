//
// ViewController.swift
// SwiftBook
//
// Created by Krishna Kolli on 2014-07-07.
// Copyright (c) 2014 Krishna Kolli. All rights reserved.
//import UIKit

import UIKit
import SpriteKit
import Alamofire

class LoginViewController: UIViewController, FBLoginViewDelegate {
    @IBOutlet weak var NavBar: UINavigationItem!
    
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
    
    override func viewDidAppear(animated: Bool) {
        if(user != nil){
            var rightButton = UIBarButtonItem(title: "Continue", style: .Plain, target: self, action: "moveToPageViewController:")
            NavBar.rightBarButtonItem = rightButton
        }
    }
    
    func moveToPageViewController(sender: UIBarButtonItem){
        self.performSegueWithIdentifier("login_segue", sender: nil)
    }
    
    // Facebook Delegate Methods
    
    func loginViewShowingLoggedInUser(loginView : FBLoginView!) {
        println("User Logged In")
    }
    
    /*
    After facebook returns the login info, call the facebook API to give us the friends list
    When we get the info back, make a post request to our server
    */
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser) {
        self.user = user
        println("User: \(user)")
        println("User ID: \(user.objectID)")
        println("User Name: \(user.name)")
        var userEmail = user.objectForKey("email") as String
        println("User Email: \(userEmail)")
        
        // call method to handle getting the user's current/updated friends
        if !alreadyFetched {
            alreadyFetched = true
            getFacebookFriendsList(user, makePostReq)
        } else {
            println("already fetched...")
        }
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
        .responseString { (request, response, data, error) in
          println("request: \(request)")
          println("response: \(response)")
          println("data: \(data)")
          println("error: \(error)")
            if error != nil {
                println(" errors found")
            } else {
                self.performSegueWithIdentifier("login_segue", sender: nil)
                //perform a segue
            }
          
        }
    }
    
    func getFacebookFriendsList(user: FBGraphUser, handler: (FBGraphUser, NSDictionary) -> Void) {
        // Get List Of Friends
        var friendsRequest : FBRequest = FBRequest.requestForMyFriends()
        friendsRequest.startWithCompletionHandler{(connection:FBRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
            if error != nil {
                println("error: \(error)")
                return
            }
            var resultdict = result as NSDictionary
            // println("Result Dict: \(resultdict)")
            var data : NSArray = resultdict.objectForKey("data") as NSArray
            
            println("calling handler")
            handler(user, resultdict)
            println("called handler...")
        }
    }
    
    func loginViewShowingLoggedOutUser(loginView : FBLoginView!) {
        println("User Logged Out")
        alreadyFetched = false
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
            let vc = segue.destinationViewController as PageViewController
            vc.user = user
            
        }
        
    }
    
}
