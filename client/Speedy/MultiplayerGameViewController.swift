//
//  MultiplayerViewController.swift
//  Speedy
//
//  Created by John Chou on 2/26/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import SpriteKit
import UIKit
import MultipeerConnectivity

class MultiplayerGameViewController: UIViewController, MCBrowserViewControllerDelegate  {
    
    var appDelegate:AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("IN GAME CENTER CONTROLLER")
        appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerChangedStateWithNotification:", name: "MPC_DidChangeStateNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleReceivedDataWithNotification:", name: "MPC_DidReceiveDataNotification", object: nil)
        
        initialCountDown("3",changedType: "init_state")
       
        println("in multiplayer view controller")
        if let scene = GameScene(size: view.frame.size) as GameScene? {
            // Configure the view.
            let skView = self.view as SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            //skView.showsPhysics = true
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = false
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
        }
        // Do any additional setup after loading the view.
    }
    
    func handleReceivedDataWithNotification(notification:NSNotification){
        println("Here in the main game")
        let userInfo = notification.userInfo! as Dictionary
        let receivedData = userInfo["data"] as NSData
        let message = NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments, error: nil) as NSDictionary
        let msg_type: AnyObject? = message.objectForKey("type")
        var msg_val:AnyObject?  = message.objectForKey("value")
        if msg_type?.isEqualToString("init_state") == true{
            //Do everything here for beginning countdown
            
            var counter:Int = msg_val!.integerValue
            counter--

            if(counter == 0){
                //start the game
               initialCountDown(String(counter), changedType: "not_init_state")

            }
            else{
                initialCountDown(String(counter), changedType: "init_state")
            }
        }
        
    }
    
    func peerChangedStateWithNotification(notification:NSNotification){
        println("PEER CHANGED IN Main GAME")
        
    }

    
    func initialCountDown(val:String, changedType:String){
        var msg = ["value" : val, "type": changedType]
        let messageData = NSJSONSerialization.dataWithJSONObject(msg, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        var error:NSError?
        
        appDelegate.mpcHandler.session.sendData(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
        
        if error != nil{
            println("error: \(error?.localizedDescription)")
        }

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }


}
