//
//  ViewController3.swift
//  Speedy
//
//  Created by John Chou on 2/19/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import UIKit
import Alamofire
import MultipeerConnectivity

class IntroViewController: UIViewController, MCBrowserViewControllerDelegate {
    @IBOutlet weak var IntroLabel: UILabel!
    @IBOutlet weak var fbProfilePic: UIImageView!
    var user : FBGraphUser!
    var appDelegate:AppDelegate!
    var id = UIDevice.currentDevice().identifierForVendor.UUIDString.utf8
    var isServer:Bool!
    var hasSeguedToMP: Bool!
    @IBOutlet weak var yourHighScore: UILabel!
    
    @IBOutlet weak var logout_button: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        println("in intro view controller")
        if user == nil {
            println("can't get the user")
        } else {
            IntroLabel.text = "Hello " + user.first_name + "!"
            
        }
        //
        appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.mpcHandler.setupPeerWithDisplayName(UIDevice.currentDevice().name)
        appDelegate.mpcHandler.setupSession()
        appDelegate.mpcHandler.advertiseSelf(true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerChangedStateWithNotification:", name: "MPC_DidChangeStateNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleReceivedDataWithNotification:", name: "MPC_DidReceiveDataNotification", object: nil)
        hasSeguedToMP = false
        //
        userSetup()
        logout_button.addTarget(self, action: "buttonClicked", forControlEvents: .TouchUpInside)
        // Do any additional setup after loading the view.
    }
    
    func buttonClicked() {
        var sesh: FBSession?
        sesh = FBSession.activeSession()
        sesh!.closeAndClearTokenInformation()
        sesh!.close()
    }
    
    func userSetup(){
        var uri = "http://mathisspeedy.herokuapp.com/OneHighScore/" + user.objectID
        Alamofire.request(.GET, uri)
            .responseJSON { (request, response, data, error) in
                println("request: \(request)")
                println("response: \(response)")
                println("data: \(data)")
                println("error: \(error)")
                if error != nil || data == nil ||  data!.objectForKey("highscore") == nil {
                    println(" errors found")
                } else {
                    var highscoreValue:NSInteger = data!.objectForKey("highscore") as NSInteger
                    println(highscoreValue)
                    self.yourHighScore.text = "Your Score: " + String(highscoreValue)
                    
                }
        }
        uri = "http://graph.facebook.com/\(user.objectID)/picture?type=large"
        let url = NSURL(string:uri)
        let urlRequest = NSURLRequest(URL: url!)
        
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue())
            {
                (response:NSURLResponse!, data:NSData!, error:NSError!) -> Void in
            
                // Display the image
                let image = UIImage(data: data)
                self.fbProfilePic.image = image
            
            }
    }
    @IBAction func setupConnection(sender: AnyObject) {
        if appDelegate.mpcHandler.session != nil{
            appDelegate.mpcHandler.setupBrowser()
            appDelegate.mpcHandler.browser.delegate = self
            
            self.presentViewController(appDelegate.mpcHandler.browser, animated: true, completion: nil)
            
        }
    }
    
    func peerChangedStateWithNotification(notification:NSNotification){
        println("PEER CHANGED STATE?!?!")
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        
        let state = userInfo.objectForKey("state") as Int
        let otherUserPID = userInfo.objectForKey("peerID") as MCPeerID
        if state != MCSessionState.Connecting.rawValue {
            self.navigationItem.title = "Connected"
            if !hasSeguedToMP {
                determineServer(otherUserPID)
            }
        }
        
    }

    
    func determineServer(peerID: MCPeerID) {
        // first figure out who's the server
        // If I'm the server, send data saying { "server": true }
        self.isServer = amIServer(peerID)
        
        // should probably make init some kind of constant
        var msg = ["type" : "init", "server": self.isServer]
        let messageData = NSJSONSerialization.dataWithJSONObject(msg, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        var error:NSError?
        
        appDelegate.mpcHandler.session.sendData(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
        
        if error != nil{
            println("error: \(error?.localizedDescription)")
        }
    }

    
    
    /*
    Convert both to utf8 and then compute them
    return true if I'm the server.  else false
    */
    func amIServer(peerID: MCPeerID) -> Bool {
        let myIDArr = Array(appDelegate.mpcHandler.peerID.displayName.generate())
        let otherIDArr = Array(peerID.displayName.generate())
        
        let iter_count = max(myIDArr.count, otherIDArr.count)
        for i in 0...iter_count-1 {
            if (myIDArr[i] > otherIDArr[i]) {
                return true
            } else {
                return false
            }
        }
        return false
        
        
    }

    
    func handleReceivedDataWithNotification(notification:NSNotification){
        println("received some data with notification! mcsetupview")
        let userInfo = notification.userInfo! as Dictionary
        let receivedData:NSData = userInfo["data"] as NSData
        
        let message = NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments, error: nil) as NSDictionary
        let senderPeerId:MCPeerID = userInfo["peerID"] as MCPeerID
        let senderDisplayName = senderPeerId.displayName
        let msg_type: AnyObject? = message.objectForKey("type")
        if msg_type?.isEqualToString("init") == true{
            let isPeerServer = message.objectForKey("server")? as Bool
            // here we have to make sure that if we're the server, then they're not, and if we're not the server, that they are
            if isPeerServer != self.isServer {
                // success!
                println("resolved correctly, going to segue to multiplayer!!")
                if appDelegate.mpcHandler.browser != nil {
                    appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
                }
                hasSeguedToMP = true
                performSegueToMultiplayer()
            } else {
                println("there was an error for client server resolution- client: \(self.isServer) serveR: \(isPeerServer)")
            }
        }
    }

    
    func performSegueToMultiplayer() {
        self.performSegueWithIdentifier("multiplayer_segue", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "multiplayer_segue" {
            println("performing segue to multiplayer")
            let vc = segue.destinationViewController as MultiplayerGameViewController
        }
        
    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
}
