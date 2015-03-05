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

class GameViewController : UIViewController, SKPhysicsContactDelegate {
    
    @IBOutlet weak var GameTimerLabel: UILabel!
    @IBOutlet weak var GameScoreLabel: UILabel!
    @IBOutlet weak var GameTargetNumLabel: UILabel!
    var timer = NSTimer()
    var counter = 0
    var game_max_time = 60 // TODO - modify this somehow later
    var score = 0
    var targetNumber: Int?
    let TIME_DEBUG = false
    var scene: GameScene?
    var boardController: BoardController?
    
    override func viewDidLoad() {
        super.viewDidLoad();
        println("In Game View controller")
        
        // start the counter to go!
        GameScoreLabel.text = String(score)
        GameTimerLabel.text = convertIntToTime(counter)
        startTimer()
        
        scene = GameScene(size: view.frame.size)
        boardController = BoardController(scene: scene!)
<<<<<<< HEAD
=======
        scene!.boardController = boardController
        updateTargetNumber()
>>>>>>> d114428d3121e6ebbee48463ab847e5a4d2e2f8f
        
        // Configure the view.
        let skView = self.view as SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        //skView.showsPhysics = true
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = false
        
        /* Set the scale mode to scale to fit the window */
<<<<<<< HEAD
        scene!.scaleMode = .AspectFill
        //scene!.scoreHandler = handleMerge
        scene!.physicsWorld.contactDelegate = self
        
        skView.presentScene(scene)
    }
    
    // BEGIN -- SCORE HANDLING
    /*
    takes in the target node that everything gets merged into, 
    two operands and an operatorCircle
    
    Whether or not this new node is the designated target number should be handled elsewhere
    */
=======

        scene!.scaleMode = .AspectFill
        //scene!.scoreHandler = handleMerge
        scene!.physicsWorld.contactDelegate = self
        skView.presentScene(scene)
    }
    
    func updateScore(){
        GameScoreLabel.text = String(score)
    }
    
    func updateTargetNumber(){
        if targetNumber != nil{
            let numberCircleList = boardController!.circleList.filter{$0 is NumberCircle}
            let numberList = numberCircleList.map{($0 as NumberCircle).number!}
            targetNumber = boardController!.randomNumbers.generateTarget(numberList)
        }else{
            targetNumber = boardController!.randomNumbers.generateTarget()

>>>>>>> d114428d3121e6ebbee48463ab847e5a4d2e2f8f
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
        }
        
<<<<<<< HEAD
        let removeNode = (result == targetNumber || result == 0)
        
        return (result, removeNode)
=======
        GameTargetNumLabel.text = String(targetNumber!)
>>>>>>> d114428d3121e6ebbee48463ab847e5a4d2e2f8f
    }
    
    // END-- SCORE HANDLING
    
    func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("onTick"), userInfo: nil, repeats: true)
    }
    
    func onTick() {
        updateCounter()
        scene!.upgradeCircle()
    }
    
    func updateCounter() {
        counter++;
        if (game_max_time - counter < 0) {
            // Stop the timer completely
            GameTimerLabel.text = "Done"
            stopPauseTimer()
        } else {
            GameTimerLabel.text = convertIntToTime(counter)
        }
    }
    
    func stopPauseTimer() {
        timer.invalidate()
    }
    
    /*
    this takes something like 0 and turns it into 00:00
    and if it takes something like 60 -> 01:00
    if it takes 170 -> 02:10
    */
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
    
    func didBeginContact(contact: SKPhysicsContact) {
        var numberBody: SKPhysicsBody
        var opBody: SKPhysicsBody
        
        //A neccessary check to prevent contacts from throwing runtime errors
        if !(contact.bodyA.node != nil && contact.bodyB.node != nil && contact.bodyA.node!.parent != nil && contact.bodyB.node!.parent != nil) {
            return;
        }
        
        //This is dependant on the order of the nodes
        if contact.bodyA.node! is NumberCircle{
            numberBody = contact.bodyA
            
            if contact.bodyB.node! is OperatorCircle{
                opBody = contact.bodyB
                
                let numberNode = numberBody.node! as NumberCircle
                let opNode     = opBody.node! as OperatorCircle
                
                if !numberNode.hasNeighbor() && !opNode.hasNeighbor() {
                    numberNode.setNeighbor(opNode)
                    opNode.setNeighbor(numberNode)
<<<<<<< HEAD
                    
=======

>>>>>>> d114428d3121e6ebbee48463ab847e5a4d2e2f8f
                    let joint = scene!.createBestJoint(contact.contactPoint, nodeA: numberNode, nodeB: opNode)
                    scene!.physicsWorld.addJoint(joint)
                    scene!.joinedNodeA = numberNode
                    scene!.joinedNodeB = opNode
<<<<<<< HEAD
=======

>>>>>>> d114428d3121e6ebbee48463ab847e5a4d2e2f8f
                }else{
                    if let leftNumberCircle = opNode.neighbor as? NumberCircle {
                        let opCircle  = opNode
                        
                        mergeNodes(leftNumberCircle, rightNumberCircle: numberNode, opCircle: opCircle)
                    }
                }
            }
        }else if contact.bodyA.node! is OperatorCircle{
            opBody = contact.bodyA
            
            if contact.bodyB.node! is NumberCircle{
                numberBody = contact.bodyB
                
                let numberNode = numberBody.node! as NumberCircle
                let opNode     = opBody.node! as OperatorCircle
                
                // all nodes touching together have no neighbors (1st contact)
                if numberNode.hasNeighbor() == false && opNode.hasNeighbor() == false{
                    var myJoint = SKPhysicsJointPin.jointWithBodyA(numberBody, bodyB: opBody,
                        anchor: numberBody.node!.position)
                    
                    numberNode.setNeighbor(opNode)
                    opNode.setNeighbor(numberNode)
<<<<<<< HEAD
                    
=======
>>>>>>> d114428d3121e6ebbee48463ab847e5a4d2e2f8f
                    myJoint.frictionTorque = 1.0
                    scene!.physicsWorld.addJoint(myJoint)
                    scene!.currentJoint = myJoint
                    scene!.joinedNodeA = numberNode
                    scene!.joinedNodeB = opNode
                }else{
                    // if hitting all 3
                    let leftNumberCircle = opNode.neighbor as NumberCircle
                    let opCircle  = opNode
                    
                    mergeNodes(leftNumberCircle, rightNumberCircle: numberNode, opCircle: opCircle)
                }
            }
        }
    }
    
<<<<<<< HEAD
    func mergeNodes(leftNumberCircle: NumberCircle, rightNumberCircle: NumberCircle, opCircle: OperatorCircle){
        let leftNumber = leftNumberCircle.number!
        let rightNumber = rightNumberCircle.number!
        let op = opCircle.op!
        
        let (result, removeNode) = handleMerge(leftNumber, op2: rightNumber, oper: op)
=======
    //TODO: Refactor mergeNodes and handleMerge together
    func mergeNodes(leftNumberCircle: NumberCircle, rightNumberCircle: NumberCircle, opCircle: OperatorCircle){
        let (result, removeNode) = handleMerge(leftNumberCircle, rightNumberCircle: rightNumberCircle, opCircle: opCircle)
        
        let op1Upgrade = leftNumberCircle.upgrade
        let op2Upgrade = rightNumberCircle.upgrade
>>>>>>> d114428d3121e6ebbee48463ab847e5a4d2e2f8f
        
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
<<<<<<< HEAD
        
        /*
        if let num = rightNumberCircle.number {
            if num == self.targetNumber {
                println("YOU WIN")
            }
        }
        */
=======
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
            updateScore()
            updateTargetNumber()
        }else{
            rightNumberCircle.setScore(nodeScore)
        }
        
        let removeNode = (result == targetNumber || result == 0)
        
        return (result, removeNode)
>>>>>>> d114428d3121e6ebbee48463ab847e5a4d2e2f8f
    }
    
    //func didEndContact(contact: SKPhysicsContact) {}
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        println("preparing for segue!!")
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
