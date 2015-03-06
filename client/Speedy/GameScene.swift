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
    var joinedNodeA: NumberCircle?
    var joinedNodeB: OperatorCircle?
    
    var targetNumber: Int?
    var activeNode: SKNode?
    var freezeAction = false
    
    var releaseNumber: NumberCircle?
    var releaseOperator: OperatorCircle?
    
    var boardController: BoardController?
    
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
        // println("in touchesbegan and freezeaction is: " + String(freezeAction.description))
        if (freezeAction == true) {
            return
        }

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
        
        if activeNode! is NumberCircle{
            let liftup = SKAction.scaleTo(1.2, duration: 0.2)
            activeNode!.runAction(liftup, withKey: "pickup")
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        // println("in touchesmoved and freezeaction is: " + String(freezeAction.description))
        if (freezeAction == true) {
            return
        }
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)

        if activeNode != nil{
            while !(activeNode is GameCircle) {
                if activeNode is SKScene {
                    // can't move the scene, finger probably fell off a circle?
                    if let physBody = activeNode?.physicsBody {
                        physBody.dynamic = true
                    }
                    return
                }
                activeNode = activeNode!.parent!
            }
            
            //Only number circles can be moved
            if activeNode is NumberCircle{
                activeNode!.position = touchLocation
            }
        }
    }

    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        //Break the node joint if touch is released
        breakJoint()

        if let physBody = activeNode?.physicsBody {
            physBody.dynamic = true
        }
        
        if activeNode != nil && activeNode! is NumberCircle{
            let dropDown = SKAction.scaleTo(1.0, duration: 0.2)
            activeNode!.runAction(dropDown, withKey: "drop")
        }
        
        activeNode = nil
    }

    func breakJoint(){
        if currentJoint != nil {
            println("breakjoint")
            self.physicsWorld.removeJoint(currentJoint!)
            currentJoint = nil
            
            if joinedNodeA != nil{
                joinedNodeA!.neighbor = nil
            }
            
            if joinedNodeB != nil{
                joinedNodeB!.neighbor = nil
            }
            
            releaseNumber = joinedNodeA
            releaseOperator = joinedNodeB
            joinedNodeA = nil
            joinedNodeB = nil
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
            let upgradeOption = UpgradeOptions(rawValue: Int(arc4random_uniform(2)))
            
            let numberCircles = boardController!.getCircleList().filter{$0 is NumberCircle}
            let upgradedCircles = numberCircles.filter{($0 as NumberCircle).upgrade != .None}
            let unUpgradedCircles = numberCircles.filter{($0 as NumberCircle).upgrade == .None}
            
            if upgradeOption != .None && upgradedCircles.count < 2{
                let index = Int(arc4random_uniform(UInt32(unUpgradedCircles.count)))
                
                var nodeToUpgrade = unUpgradedCircles[index] as NumberCircle
                if nodeToUpgrade !== activeNode{
                    nodeToUpgrade.setUpgrade(upgradeOption!)
                    nodeToUpgrade.setFillColor(upgradeOption!.upgradeColor())
                }
            }
        }
    }
}
