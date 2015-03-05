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
        //self.physicsWorld.contactDelegate = self;
    }
    
    func determineClosestAnchorPair(position: CGPoint, nodeA: GameCircle, nodeB: GameCircle) -> (CGPoint, CGPoint) {
        func distBetweenPoints(pointA: CGPoint, pointB: CGPoint) -> CGFloat {
            let dx = CGFloat(abs(pointA.x - pointB.x))
            let dy = CGFloat(abs(pointA.y - pointB.y))
            
            let sumSquares = dx * dx + dy * dy
            
            return sqrt(sumSquares)
        }
        
        let aLeftAnchor = nodeA.getLeftAnchor()
        let aRightAnchor = nodeA.getRightAnchor()
        let bLeftAnchor = nodeB.getLeftAnchor()
        let bRightAnchor = nodeB.getRightAnchor()
        
        let aLeftDist = distBetweenPoints(position, aLeftAnchor)
        let bLeftDist = distBetweenPoints(position, bLeftAnchor)
        let aRightDist = distBetweenPoints(position, aRightAnchor)
        let bRightDist = distBetweenPoints(position, bRightAnchor)
        
        let d1 = aLeftDist + bRightDist
        let d2 = aRightDist + bLeftDist
        
        return (d1 < d2) ? (nodeA.getLeftAnchor(), nodeB.getRightAnchor()) : (nodeA.getRightAnchor(),nodeB.getLeftAnchor())
    }
    
    func createBestJoint(touchPoint: CGPoint, nodeA: GameCircle, nodeB: GameCircle) -> SKPhysicsJoint {
        let (anchorPointA, anchorPointB) = determineClosestAnchorPair(touchPoint, nodeA: nodeA, nodeB: nodeB)
        let myJoint = SKPhysicsJointPin.jointWithBodyA(nodeA.physicsBody, bodyB: nodeB.physicsBody, anchor: anchorPointA)
        myJoint.frictionTorque = 1.0
        currentJoint = myJoint
        return myJoint
    }
    
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
        
        //Break the node joint if touch is released
        breakJoint()

       // wayPoints.removeAll(keepCapacity: false)
        if let physBody = activeNode?.physicsBody {
            physBody.dynamic = true
        }
        
        activeNode = nil
    }

    func breakJoint(){
        if currentJoint != nil {
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
    
}
