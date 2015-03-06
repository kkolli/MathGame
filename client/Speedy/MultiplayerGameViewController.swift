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

class MultiplayerGameViewController: UIViewController, SKPhysicsContactDelegate {
    var timer: Timer!
    var countDown = 3
    var game_max_time = 60 // TODO - modify this somehow later
    var score = 0
    var peer_score = 0
    var targetNumber: Int?
    let TIME_DEBUG = false
    var appDelegate:AppDelegate!
    var scene: GameScene?
    var boardController: BoardController?
    var finishedInit: Bool!
    
    @IBOutlet weak var GameTargetNumLabel: UILabel!
    @IBOutlet weak var GameTimerLabel: UILabel!
    @IBOutlet weak var counterTimer: UILabel!
    @IBOutlet weak var PeerCurrentScore: UILabel!
    @IBOutlet weak var MyCurrentScore: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        
        println("in multiplayer view controller")

        scene = GameScene(size: view.frame.size)
        boardController = BoardController(scene: scene!)
        scene!.boardController = boardController
        updateTargetNumber()
        finishedInit = false
        
        // Configure the view.
        let skView = self.view as SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        //skView.showsPhysics = true
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = false
        
        /* Set the scale mode to scale to fit the window */
        scene!.scaleMode = .AspectFill
        //scene!.scoreHandler = handleMerge
        scene!.physicsWorld.contactDelegate = self
        // start off frozen
        scene!.freezeAction = true
        
        skView.presentScene(scene)
        // Do any additional setup after loading the view.
        
        appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerChangedStateWithNotification:", name: "MPC_DidChangeStateNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleReceivedDataWithNotification:", name: "MPC_DidReceiveDataNotification", object: nil)
        initialCountDown(String(countDown), changedType: "init_state")
        setScoreLabels()
        
        // start the counter to go!
        timer = Timer(duration: game_max_time, {(elapsedTime: Int) -> () in
            if self.TIME_DEBUG {
                println("time printout: " + String(self.timer.getTime()))
            }
            if self.timer.getTime() < 0 {
                self.GameTimerLabel.text = "done"
            } else {
                self.GameTimerLabel.text = self.timer.convertIntToTime(self.timer.getTime())
            }
        })
        
        GameTimerLabel.text = timer.convertIntToTime(self.timer.getTime())
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
//        let msg_type_init: AnyObject? = message.objectForKey("type_init")
        let msg_val: AnyObject? = message.objectForKey("value")
        
        if msg_type?.isEqualToString("score_update") == true {
            // if this is a score_update, then unwrap for the score changes to the peer
            peer_score = message.objectForKey("score") as Int
            setScoreLabels()
        }
        else if msg_type?.isEqualToString("init_state") == true && !self.finishedInit{
            //Do everything here for beginning countdown
            var recv_counter:Int = msg_val!.integerValue
            var old_counter = countDown
            println("I just received value: " + String(recv_counter) + " while counter is : " + String(countDown))
            if recv_counter > countDown || countDown <= 0 {
                if recv_counter == 0 && self.scene!.freezeAction == true {
                    startGame()
                }
                return
            }
            
            countDown = countDown-1
            setScoreLabels()
            
            if recv_counter == 0 {
                startGame()
                return
            }
            println("counter is now at: " + String(countDown) + "ready to timeout")
            
            timeoutCtr("timing out initialization at: " + String(msg_val!.integerValue),
                resolve: {
                    println("finished timeout-- counter is at: " + String(self.countDown))
                    if(self.countDown == 0){
                            self.initialCountDown(String(self.countDown), changedType: "init_state")
                    }
                    else{
                        self.initialCountDown(String(self.countDown), changedType: "init_state")
                    }
                },
                reject: {
                    // handle errors
            })
        }
    }
    
    func startGame() {
        println("about to unfreeze!")

        self.timer.start()
        //start the game
        self.scene!.freezeAction = false
        self.countDown = 0
        self.initialCountDown(String(self.countDown), changedType: "init_state")
        self.finishedInit = true
    }
    
    func timeoutCtr(txt: String, resolve: () -> (), reject: () -> ()) {
        var delta: Int64 = 1 * Int64(NSEC_PER_SEC)
        var time = dispatch_time(DISPATCH_TIME_NOW, delta)
        
        dispatch_after(time, dispatch_get_main_queue(), {
            println("closures are " + txt)
            resolve()
        });
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
        if (countDown == 0) {
            counterTimer.hidden = true
        } else {
          counterTimer.text = String(countDown)
        }
    }
    
    func updateTargetNumber(){
        if targetNumber != nil{
            let numberCircleList = boardController!.circleList.filter{$0 is NumberCircle}
            let numberList = numberCircleList.map{($0 as NumberCircle).number!}
            targetNumber = boardController!.randomNumbers.generateTarget(numberList)
        }else{
            targetNumber = boardController!.randomNumbers.generateTarget()
        }
        GameTargetNumLabel.text = String(targetNumber!)
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
        println("sending initial count down: " + val)
        var msg = ["value" : val, "type": changedType]
        let messageData = NSJSONSerialization.dataWithJSONObject(msg, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        var error:NSError?
        
        appDelegate.mpcHandler.session.sendData(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
        
        if error != nil{
            println("error: \(error?.localizedDescription)")
        }
        
    }
    
    func handleMerge(leftNumberCircle: NumberCircle, rightNumberCircle: NumberCircle, opCircle: OperatorCircle) -> (Int, Bool){
        var result: Int
        var nodeScore: Int
        
        let op1 = leftNumberCircle.number!
        let op2 = rightNumberCircle.number!
        let oper = opCircle.op!
        
        switch oper{
        case .PLUS:
            result = op1 + op2
        case .MINUS:
            result = op1 - op2
        case .MULTIPLY:
            result = op1 * op2
        case .DIVIDE:
            result = op1 / op2
        }
        
        nodeScore = leftNumberCircle.getScore() + rightNumberCircle.getScore() * ScoreMultiplier.getMultiplierFactor(oper)
        if result == targetNumber{
            score += nodeScore
            notifyScoreChanged()
            setScoreLabels()
            updateTargetNumber()
        }else{
            rightNumberCircle.setScore(nodeScore)
        }
        
        let removeNode = (result == targetNumber || result == 0)
        
        return (result, removeNode)
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func didBeginContact(contact: SKPhysicsContact) {
        var numberBody: SKPhysicsBody
        var opBody: SKPhysicsBody
        
        //A neccessary check to prevent contacts from throwing runtime errors
        if !(contact.bodyA.node != nil && contact.bodyB.node != nil && contact.bodyA.node!.parent != nil && contact.bodyB.node!.parent != nil) {
            return
        }
        
        if contact.bodyA.node! is NumberCircle{
            numberBody = contact.bodyA
            
            if contact.bodyB.node! is OperatorCircle{
                opBody = contact.bodyB
                
                let numberNode = numberBody.node! as NumberCircle
                let opNode     = opBody.node! as OperatorCircle
                
                if !numberNode.hasNeighbor() && !opNode.hasNeighbor() {
                    if scene!.releaseNumber != nil && scene!.releaseOperator != nil{
                        println("NO")
                        return
                    }
                    numberNode.setNeighbor(opNode)
                    opNode.setNeighbor(numberNode)
                    
                    let joint = scene!.createBestJoint(contact.contactPoint, nodeA: numberNode, nodeB: opNode)
                    scene!.physicsWorld.addJoint(joint)
                    scene!.currentJoint = joint
                    scene!.joinedNodeA = numberNode
                    scene!.joinedNodeB = opNode
                    
                }else{
                    if let leftNumberCircle = opNode.neighbor as? NumberCircle {
                        let opCircle  = opNode
                        
                        mergeNodes(leftNumberCircle, rightNumberCircle: numberNode, opCircle: opCircle)
                    }
                }
            }else{
                return
            }
        }else if contact.bodyA.node! is OperatorCircle{
            opBody = contact.bodyA
            
            if contact.bodyB.node! is NumberCircle{
                numberBody = contact.bodyB
                
                let numberNode = numberBody.node! as NumberCircle
                let opNode     = opBody.node! as OperatorCircle
                
                // all nodes touching together have no neighbors (1st contact)
                if numberNode.hasNeighbor() == false && opNode.hasNeighbor() == false{
                    if scene!.releaseNumber != nil && scene!.releaseOperator != nil{
                        return
                    }
                    numberNode.setNeighbor(opNode)
                    opNode.setNeighbor(numberNode)
                    
                    let joint = scene!.createBestJoint(contact.contactPoint, nodeA: numberNode, nodeB: opNode)
                    scene!.physicsWorld.addJoint(joint)
                    scene!.currentJoint = joint
                    scene!.joinedNodeA = numberNode
                    scene!.joinedNodeB = opNode
                }else{
                    // if hitting all 3
                    if let leftNumberCircle = opNode.neighbor as? NumberCircle {
                        let opCircle  = opNode
                        
                        mergeNodes(leftNumberCircle, rightNumberCircle: numberNode, opCircle: opCircle)
                    }
                }
            }else{
                return
            }
        }
    }
    
   //TODO: Refactor mergeNodes and handleMerge together
    func mergeNodes(leftNumberCircle: NumberCircle, rightNumberCircle: NumberCircle, opCircle: OperatorCircle){
        let (result, removeNode) = handleMerge(leftNumberCircle, rightNumberCircle: rightNumberCircle, opCircle: opCircle)
        
        let op1Upgrade = leftNumberCircle.upgrade
        let op2Upgrade = rightNumberCircle.upgrade
        
        if removeNode {
            rightNumberCircle.removeFromParent()
            boardController!.nodeRemoved(rightNumberCircle.boardPos!)
        } else {
            rightNumberCircle.setNumber(result)
            rightNumberCircle.neighbor = nil
        }
        
        leftNumberCircle.removeFromParent()
        opCircle.removeFromParent()
        
        boardController!.nodeRemoved(leftNumberCircle.boardPos!)
        boardController!.nodeRemoved(opCircle.boardPos!)
        
        boardController!.replaceMissingNodes()
    }
}
