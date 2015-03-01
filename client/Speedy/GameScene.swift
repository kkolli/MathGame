//
//  GameScene.swift
//  Speedy
//
//  Created by Tyler Levine on 1/27/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import SpriteKit

class GameScene : SKScene, SKPhysicsContactDelegate {
    let randomNumbers = RandomNumbers(difficulty: 5) //Hardcoded difficulty value
    let randomOperators = RandomOperators(difficulty: 5) //Hardcoded difficulty value
    
    var contentCreated = false
    var scoreHandler: ((op1: Int, op2: Int, oper: Operator) -> ((Int, Bool)))?

    var currentJoint: SKPhysicsJoint?
    var joinedNodeA: GameCircle?
    var joinedNodeB: GameCircle?
    
    var targetNumber: Int?


    var activeNode: SKNode?
    
    override func didMoveToView(view: SKView) {
        let boardController = BoardController(scene: self, debug: true)
        
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
                        var myJoint = SKPhysicsJointPin.jointWithBodyA(numberBody, bodyB: opBody,
                            anchor: numberBody.node!.position)
                        
                        numberNode.setNeighbor(opNode)
                        opNode.setNeighbor(numberNode)
                        
                        myJoint.frictionTorque = 1.0
                        self.physicsWorld.addJoint(myJoint)
                        currentJoint = myJoint
                        joinedNodeA = numberNode
                        joinedNodeB = opNode
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
                            joinedNodeA = numberNode
                            joinedNodeB = opNode
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
    
    func didEndContact(contact: SKPhysicsContact) {}
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* touch has begun */
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        var touchedNode = nodeAtPoint(touchLocation)
        
        /*
        if touchedNode is GameCircle {
            println("GameCircle touched")
        }
        
        if touchedNode is SKLabelNode {
            println("Label node touched")
        }
        */
        
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
        
        if touchedNode is NumberCircle{
            //Only number circles can be moved
            touchedNode.position.x = touchLocation.x
            touchedNode.position.y = touchLocation.y
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

       // wayPoints.removeAll(keepCapacity: false)
        if let physBody = activeNode?.physicsBody {
            physBody.dynamic = true
        }
        
        activeNode = nil
    }

    func breakJoint(){
        if currentJoint != nil{
            self.physicsWorld.removeJoint(currentJoint!)
            currentJoint = nil
            
            if joinedNodeA != nil{
                joinedNodeA!.neighbor = nil
            }
            
            if joinedNodeB != nil{
                joinedNodeB!.neighbor = nil
            }
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
            
            leftNumberCircle.removeFromParent()
            opCircle.removeFromParent()
        }
    }
}
