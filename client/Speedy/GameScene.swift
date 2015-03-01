//
//  GameScene.swift
//  Speedy
//
//  Created by Tyler Levine on 1/27/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import SpriteKit

class GameScene : SKScene, SKPhysicsContactDelegate {
    var contentCreated = false
    var scoreHandler: ((op1: Int, op2: Int, oper: Operator) -> ((Int, Bool)))?

    var currentJoint: SKPhysicsJoint?
    var joinedNumber: NumberCircle?
    var joinedOperator: OperatorCircle?
    
    var targetNumber: Int?
    var activeNode: SKNode?
    
    var releaseNumber: NumberCircle?
    var releaseOperator: OperatorCircle?
    
    var boardController: BoardController?
    
    override func didMoveToView(view: SKView) {
        boardController = BoardController(scene: self, debug: true)
        
        setUpPhysics()
    }
    
    func setUpPhysics(){
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        // we put contraints on the top, left, right, bottom so that our balls can bounce off them
        let physicsBody = SKPhysicsBody (edgeLoopFromRect: self.frame)
        physicsBody.dynamic = false
        physicsBody.categoryBitMask = 0xFFFFFFFF
        self.physicsBody = physicsBody
        self.physicsBody?.restitution = 0.1
        self.physicsBody?.friction = 0.0
        self.physicsWorld.contactDelegate = self;
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var numberBody: SKPhysicsBody
        var opBody: SKPhysicsBody
        
        //A neccessary check to prevent contacts from throwing runtime errors
        if contact.bodyA.node != nil && contact.bodyB.node != nil && contact.bodyA.node!.parent != nil && contact.bodyB.node!.parent != nil{
            //This is dependant on the order of the nodes
            if contact.bodyA.node! is NumberCircle{
                numberBody = contact.bodyA
                
                if contact.bodyB.node! is OperatorCircle{
                    opBody = contact.bodyB
                    
                    let numberNode = numberBody.node! as NumberCircle
                    let opNode     = opBody.node! as OperatorCircle
                    
                    if numberNode.hasNeighbor() == false && opNode.hasNeighbor() == false{
                        if releaseNumber === numberNode && releaseOperator === opNode{
                            releaseNumber = nil
                            releaseOperator == nil
                        }else{
                            var myJoint = SKPhysicsJointPin.jointWithBodyA(numberBody, bodyB: opBody,
                                anchor: numberBody.node!.position)
                            
                            numberNode.setNeighbor(opNode)
                            opNode.setNeighbor(numberNode)
                            
                            myJoint.frictionTorque = 1.0
                            self.physicsWorld.addJoint(myJoint)
                            currentJoint = myJoint
                            joinedNumber = numberNode
                            joinedOperator = opNode
                        }
                        
                    }else{
                        let leftNumberCircle = opNode.neighbor as NumberCircle
                        let opCircle  = opNode
                        
                        mergeNodes(leftNumberCircle, rightNumberCircle: numberNode, opCircle: opCircle)
                    }
                }
            }else{
                if contact.bodyA.node! is OperatorCircle{
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
                            self.physicsWorld.addJoint(myJoint)
                            currentJoint = myJoint
                            joinedNumber = numberNode
                            joinedOperator = opNode
                        }else{
                            // if hitting all 3
                            let leftNumberCircle = opNode.neighbor as NumberCircle
                            let opCircle  = opNode
                            
                            mergeNodes(leftNumberCircle, rightNumberCircle: numberNode, opCircle: opCircle)
                        }
                    }
                }
            }
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
    
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* touch has begun */
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        var touchedNode = nodeAtPoint(touchLocation)
        
        while !(touchedNode is GameCircle) {
            if touchedNode is SKScene {
                // can't move the scene, finger probably fell off a circle?
                if let physBody = activeNode?.physicsBody {
                    physBody.dynamic = true
                }
                return
            }
            touchedNode = touchedNode.parent!
        }
        
        /*Make the touched node do something*/
        if let physBody = touchedNode.physicsBody {
            physBody.dynamic = false
        }
        activeNode = touchedNode
        
        if touchedNode is NumberCircle{
            let liftup = SKAction.scaleTo(1.2, duration: 0.2)
            touchedNode.runAction(liftup, withKey: "pickup")
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        var touchedNode = nodeAtPoint(touchLocation)
        
        while !(touchedNode is GameCircle) {
            if touchedNode is SKScene {
                // can't move the scene, finger probably fell off a circle?
                if let physBody = activeNode?.physicsBody {
                    physBody.dynamic = true
                }
                return
            }
            touchedNode = touchedNode.parent!
        }
        
        //Only number circles can be moved
        if touchedNode is NumberCircle{
            touchedNode.position = touchLocation
        }
    }

    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        var touchedNode = nodeAtPoint(touchLocation)
        
        if touchedNode is SKLabelNode {
            touchedNode = touchedNode.parent!.parent!
        }
        
        //Break the node joint if touch is released
        breakJoint()

        if let physBody = activeNode?.physicsBody {
            physBody.dynamic = true
        }
        
        activeNode = nil
        
        if touchedNode is NumberCircle{
            let dropDown = SKAction.scaleTo(1.0, duration: 0.2)
            touchedNode.runAction(dropDown, withKey: "drop")
        }
    }

    func breakJoint(){
        if currentJoint != nil{
            self.physicsWorld.removeJoint(currentJoint!)
            currentJoint = nil
            
            if joinedNumber != nil{
                joinedNumber!.neighbor = nil
            }
            
            if joinedOperator != nil{
                joinedOperator!.neighbor = nil
            }
            
            releaseNumber = joinedNumber
            releaseOperator = joinedOperator
        }
    }
    
    func mergeNodes(leftNumberCircle: NumberCircle, rightNumberCircle: NumberCircle, opCircle: OperatorCircle){
        let leftNumber = leftNumberCircle.number!
        let rightNumber = rightNumberCircle.number!
        let op = opCircle.op!
        
        let (result, removeNode) = scoreHandler!(op1: leftNumber, op2: rightNumber, oper: op)
        
        if removeNode{
            leftNumberCircle.removeFromParent()
            rightNumberCircle.removeFromParent()
            opCircle.removeFromParent()
        }else{
            rightNumberCircle.setNumber(result)
            rightNumberCircle.neighbor = nil
            rightNumberCircle.setIsUpgraded(false)
            rightNumberCircle.resetFillColor()
            
            leftNumberCircle.removeFromParent()
            opCircle.removeFromParent()
        }
    }
    
    /*
    * Game will randomly choose a node at random intervals of time to "upgrade"
    * the value of a node.
    */
    
    //TODO: Move to GameViewController
    func upgradeCircle(){
        let shouldUpgrade = Int(arc4random_uniform(10) + 1)
            
        if shouldUpgrade == 1{
            
            let upgradeOption = Int(arc4random_uniform(2))
            
            let numberCircles = boardController!.getCircleList().filter{$0 is NumberCircle}
            let upgradedCircles = numberCircles.filter{($0 as NumberCircle).isUpgraded()}
            let unUpgradedCircles = numberCircles.filter{!($0 as NumberCircle).isUpgraded()}
            
            if upgradeOption == 0 {
                if upgradedCircles.count < 2{
                    let index = Int(arc4random_uniform(UInt32(unUpgradedCircles.count)))
                    
                    var nodeToUpgrade = unUpgradedCircles[index] as NumberCircle
                    if nodeToUpgrade !== activeNode{
                        nodeToUpgrade.score = nodeToUpgrade.score! * nodeToUpgrade.scoreMultiplier
                        nodeToUpgrade.shapeNode!.fillColor = SKColor.greenColor()
                        nodeToUpgrade.setIsUpgraded(true)
                    }
                }
            }else if upgradeOption == 1{
                if upgradedCircles.count < 2{
                    let index = Int(arc4random_uniform(UInt32(unUpgradedCircles.count)))
                    
                    //Add 5 seconds to time
                }
            }
        }
    }
}
