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
    var timer: Timer!
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
        timer = Timer(duration: game_max_time, {(elapsedTime: Int) -> () in
            if self.timer.getTime() < 0 {
                self.GameTimerLabel.text = "done"
            } else {
                if self.TIME_DEBUG {
                  println("time printout: " + String(self.timer.getTime()))
                }
                self.GameTimerLabel.text = self.timer.convertIntToTime(self.timer.getTime())
            }
        })
        
        GameTimerLabel.text = timer.convertIntToTime(self.timer.getTime())
        timer.start()
        
        scene = GameScene(size: view.frame.size)
        boardController = BoardController(scene: scene!)
        
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
        
        println("targetnum: \(targetNumber) and result: \(result)")
        if result == targetNumber{
            score += result * ScoreMultiplier.getMultiplierFactor(oper)
        }
        
        let removeNode = (result == targetNumber || result == 0)
        
        return (result, removeNode)
    }
    
    // END-- SCORE HANDLING
    
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

                    let joint = scene!.createBestJoint(contact.contactPoint, nodeA: numberNode, nodeB: opNode)
                    scene!.physicsWorld.addJoint(joint)
                    scene!.joinedNodeA = numberNode
                    scene!.joinedNodeB = opNode
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
    
    func mergeNodes(leftNumberCircle: NumberCircle, rightNumberCircle: NumberCircle, opCircle: OperatorCircle){
        let leftNumber = leftNumberCircle.number!
        let rightNumber = rightNumberCircle.number!
        let op = opCircle.op!
        
        let (result, removeNode) = handleMerge(leftNumber, op2: rightNumber, oper: op)
        
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
        
        /*
        if let num = rightNumberCircle.number {
            if num == self.targetNumber {
                println("YOU WIN")
            }
        }
        */
    }
    
    //func didEndContact(contact: SKPhysicsContact) {}
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        println("preparing for segue!!")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
        
    }
}
