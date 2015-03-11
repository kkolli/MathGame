//
//  GameViewController.swift
//  Speedy
//
//  Created by Tyler Levine on 1/27/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//
// NS Timer Reference- http://ios-blog.co.uk/tutorials/swift-nstimer-tutorial-lets-create-a-counter-application/


import SpriteKit
import UIKit
import Alamofire

class GameViewController : UIViewController, SKPhysicsContactDelegate {
    
   // @IBOutlet weak var GameTimerLabel: UILabel!
   // @IBOutlet weak var GameScoreLabel: UILabel!
   // @IBOutlet weak var GameTargetNumLabel: UILabel!
    var user : FBGraphUser!
    var appDelegate:AppDelegate!
    var timer: Timer!
    var game_start_time = 60 // TODO - modify this somehow later
    //var score = 0
    //var targetNumber: Int?
    let TIME_DEBUG = false
    var scene: GameScene?
    var boardController: BoardController?
    var numTargetNumbersMatched:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.navigationController?.navigationBarHidden = true
        self.tabBarController?.tabBar.hidden = true
        self.user = appDelegate.user
        println("In Game View controller")
        
        // start the counter to go!
        timer = Timer(duration: game_start_time, {(elapsedTime: Int) -> () in
            if self.timer.getTime() <= 0 {
                //self.GameTimerLabel.text = "done"
                //self.postScore(self.GameScoreLabel.text!)
                self.performSegueToSummary()
            } else {
                if self.TIME_DEBUG {
                  println("time printout: " + String(self.timer.getTime()))
                }
                
                if self.boardController != nil {
                    self.boardController?.setTimeInHeader(self.timer.getTime())
                }
                //self.GameTimerLabel.text = self.timer.convertIntToTime(self.timer.getTime())
            }
        })
        numTargetNumbersMatched = 0
        
        //GameTimerLabel.text = timer.convertIntToTime(self.timer.getTime())
        
        //GameScoreLabel.text = String(score)
        
        scene = GameScene(size: view.frame.size)
    
        boardController = BoardController(scene: scene!, mode: .SINGLE)
        boardController!.notifyScoreChanged = updateScoreAndTime
        //scene!.boardController = boardController
        //updateTargetNumber()
        
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
        skView.presentScene(scene)
        
        timer.start()
    }
    
    
    func updateScoreAndTime(){
        if numTargetNumbersMatched > 0 {
            timer.addTime(timer.getExtraTimeSub())
        } else {
            timer.addTime(timer.getExtraTimeFirst())
        }
        numTargetNumbersMatched!++
    }

    
    func postScore(score:String){
        var uri = "http://mathisspeedy.herokuapp.com/HighScores/" + user.objectID
        let parameters = [
            "score": score
        ]
        Alamofire.request(.POST, uri, parameters: parameters, encoding: .JSON)
    }
    
    /*
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
*/
    
    
    /*
    this takes something like 0 and turns it into 00:00
    and if it takes something like 60 -> 01:00
    if it takes 170 -> 02:10
    func convertIntToTime(secondsPassed: Int) -> String {
        var count = game_max_time - secondsPassed
        
        let seconds_per_minute = 60
        var minutes = count / seconds_per_minute
        var seconds = count % seconds_per_minute
        
        var minute_display = "", second_display = ""
        
        if (minutes >= 10) {
            minute_display = String(minutes)
        } else {
            minute_display = "0" + String(minutes)
        }
        
        if (seconds >= 10) {
            second_display = String(seconds)
        } else {
            second_display = "0" + String(seconds)
        }
        
        if (TIME_DEBUG) {
            println("seconds: \(seconds)" + " second display : " + second_display)
            println("displaying: " + minute_display + ":" + second_display)
        }
        return minute_display + ":" + second_display
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
                        
                        boardController!.handleMerge(leftNumberCircle, rightNumberCircle: numberNode, opCircle: opCircle)
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
                        
                        boardController!.handleMerge(leftNumberCircle, rightNumberCircle: numberNode, opCircle: opCircle)
                    }
                }
            }else{
                return
            }
        }
    }
    
    //TODO: Refactor mergeNodes and handleMerge together
    /*
    func mergeNodes(leftNumberCircle: NumberCircle, rightNumberCircle: NumberCircle, opCircle: OperatorCircle){
        let (result, removeNode) = boardController!.handleMerge(leftNumberCircle, rightNumberCircle: rightNumberCircle, opCircle: opCircle)

        /*
        let op1Upgrade = leftNumberCircle.upgrade
        let op2Upgrade = rightNumberCircle.upgrade
        */
        
        if removeNode {
            //rightNumberCircle.removeFromParent()
            //boardController!.nodeRemoved(rightNumberCircle.boardPos!)
        } else {
            rightNumberCircle.setNumber(result)
            rightNumberCircle.neighbor = nil
        }
        
        leftNumberCircle.removeFromParent()
        opCircle.removeFromParent()
        
    }
    */
    
    func didEndContact(contact: SKPhysicsContact) {}
    //func didEndContact(contact: SKPhysicsContact) {}
    func performSegueToSummary() {
        self.performSegueWithIdentifier("segueToSummary", sender: nil)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "segueToSummary" {
            println("performing segue to summary")
            let vc = segue.destinationViewController as SummaryViewController
            vc.operatorsUsed = boardController!.operatorsUsed
            vc.score = boardController!.score
            vc.numTargetNumbersMatched = numTargetNumbersMatched
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
}
