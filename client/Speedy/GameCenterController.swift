//
//  GameCenterController.swift
//  Speedy
//
//  Created by Krishna Kolli on 2/12/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class GameCenterController: UIViewController, MCBrowserViewControllerDelegate {
    /// GameCenter
//    var gameCenter: GameCenter!
    var currentPlayer:String!
    
    var appDelegate:AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("IN GAME CENTER CONTROLLER")
        appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.mpcHandler.setupPeerWithDisplayName(UIDevice.currentDevice().name)
        appDelegate.mpcHandler.setupSession()
        appDelegate.mpcHandler.advertiseSelf(true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerChangedStateWithNotification:", name: "MPC_DidChangeStateNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleReceivedDataWithNotification:", name: "MPC_DidReceiveDataNotification", object: nil)
    }
    @IBAction func connectWithPlayer(sender: AnyObject) {
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
        
        if state != MCSessionState.Connecting.rawValue{
            self.navigationItem.title = "Connected"
            performSegueToMultiplayer()
        }
        
    }
    
    func handleReceivedDataWithNotification(notification:NSNotification){
        let userInfo = notification.userInfo! as Dictionary
        let receivedData:NSData = userInfo["data"] as NSData
        
        let message = NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments, error: nil) as NSDictionary
        let senderPeerId:MCPeerID = userInfo["peerID"] as MCPeerID
        let senderDisplayName = senderPeerId.displayName
        
        if message.objectForKey("string")?.isEqualToString("New Game") == true{
            
        }
        
        
    }
    
    func performSegueToMultiplayer() {
        self.performSegueWithIdentifier("multiplayer_segue", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "multiplayer_segue" {
            println("performing segue to multiplayer")
            let vc = segue.destinationViewController as MultiplayerViewController
        }
        
    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
}