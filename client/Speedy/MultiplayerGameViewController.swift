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

class MultiplayerGameViewController: UIViewController {
    var timer = NSTimer()
    var counter = 0
    var game_max_time = 60 // TODO - modify this somehow later
    var score = 0
    var peer_score = 0
    var targetNumber: Int?
    let TIME_DEBUG = false
    var appDelegate:AppDelegate!
    
    @IBOutlet weak var counterTimer: UILabel!
    @IBOutlet weak var PeerCurrentScore: UILabel!
    @IBOutlet weak var MyCurrentScore: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("in multiplayer view controller")
        // hardcode a targetNumber for now
        setTargetNumber(10)
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
            scene.scoreHandler = handleMerge
            
            skView.presentScene(scene)
        }
        // Do any additional setup after loading the view.
        
        appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerChangedStateWithNotification:", name: "MPC_DidChangeStateNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleReceivedDataWithNotification:", name: "MPC_DidReceiveDataNotification", object: nil)
        initialCountDown("3", changedType: "init_state")
        setScoreLabels()
    }
    
    func peerChangedStateWithNotification(notification:NSNotification){
        println("PEER CHANGED STATE?!?!")
        let userInfo = NSDictionary(dictionary: notification.userInfo!)
        
        let state = userInfo.objectForKey("state") as Int
        let otherUserPID = userInfo.objectForKey("peerID") as MCPeerID
        if state != MCSessionState.Connecting.rawValue {
//            self.navigationItem.title = "Connected"
        }
        
    }
    
    func handleReceivedDataWithNotification(notification:NSNotification){
        println("received some data with notification!")
        let userInfo = notification.userInfo! as Dictionary
        let receivedData:NSData = userInfo["data"] as NSData
        
        let message = NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments, error: nil) as NSDictionary
        let senderPeerId:MCPeerID = userInfo["peerID"] as MCPeerID
        let senderDisplayName = senderPeerId.displayName
        let msg_type: AnyObject? = message.objectForKey("type")
        let msg_type_init: AnyObject? = message.objectForKey("type_init")
        let msg_val: AnyObject? = message.objectForKey("value")
        
        if msg_type?.isEqualToString("score_update") == true {
            // if this is a score_update, then unwrap for the score changes to the peer
            peer_score = message.objectForKey("score") as Int
            setScoreLabels()
        }
        else if msg_type_init?.isEqualToString("init_state") == true{
            //Do everything here for beginning countdown
            
            var counter:Int = msg_val!.integerValue
            counter--
            
            if(counter == 0){
                //start the game
                initialCountDown(String(counter), changedType: "not_init_state")
                
            }
            else{
                initialCountDown(String(counter), changedType: "init_state")
                counterTimer.text = String(counter)
                NSThread.sleepForTimeInterval(3)
            }
        }
        
        
    }


    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setTargetNumber(num: Int) {
        self.targetNumber = num
    }
    func setScoreLabels() {
        PeerCurrentScore.text = String(peer_score)
        MyCurrentScore.text = String(score)
        counterTimer.text = "3"
    }
    
    func notifyScoreChanged() {
        var msg = ["type" : "score_update", "score": self.score]
        let messageData = NSJSONSerialization.dataWithJSONObject(msg, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        var error:NSError?
        
        appDelegate.mpcHandler.session.sendData(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
        
        println("just sent data: \(messageData)")
        if error != nil{
            println("error: \(error?.localizedDescription)")
        }
    }
    
    func initialCountDown(val:String, changedType:String){
        var msg = ["value" : val, "type_init": changedType]
        let messageData = NSJSONSerialization.dataWithJSONObject(msg, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        var error:NSError?
        
        appDelegate.mpcHandler.session.sendData(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
        
        if error != nil{
            println("error: \(error?.localizedDescription)")
        }
        
    }
    
    // BEGIN -- SCORE HANDLING
    /*
    takes in the target node that everything gets merged into,
    two operands and an operatorCircle
    
    Whether or not this new node is the designated target number should be handled elsewhere
    */
    func handleMerge(op1: Int, op2: Int, oper: Operator) -> (Int, Bool){
        var result: Int
        
        switch oper{
        case .PLUS: result = op1 + op2
        case .MINUS: result = op1 - op2
        case .MULTIPLY: result = op1 * op2
        case .DIVIDE: result = op1 / op2
        }
        
        if result == targetNumber{
            score += result * ScoreMultiplier.getMultiplierFactor(oper)
            setTargetNumber(10)
            
            // communicate that score has changed
            notifyScoreChanged()
            setScoreLabels()
        }
        
        let removeNode = (result == targetNumber || result == 0)
        
        return (result, removeNode)
    }
    
    // END-- SCORE HANDLING
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
