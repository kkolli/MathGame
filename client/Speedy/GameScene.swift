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
    
    // this shouldn't be here?
    //var boardController: BoardController?
    
    var gameFrame: CGRect?
    
    var header: BoardHeader?
    
    override func didMoveToView(view: SKView) {
        //setUpPhysics()
    }
    
    func setGameFrame(frame: CGRect) {
        gameFrame = frame
        setupBoardHeader()
    }
    
    func setupBoardHeader() {
        if let gf = gameFrame {
            let frame = CGRectMake(gf.origin.x, gf.origin.y, gf.width, self.frame.height - gf.height)
            
            //header = BoardHeader(size: frame, )
            
        }
    }
    
    func getActiveNode() -> SKNode? {
        return activeNode
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
            let liftup = SKAction.scaleTo(GameCircleProperties.pickupScaleFactor, duration: 0.2)
            activeNode!.runAction(liftup)
        }
    }
    
    func adjustPositionIntoGameFrame(position: CGPoint) -> CGPoint {
        if let frame = gameFrame {
            let nodeRadius = GameCircleProperties.nodeRadius * GameCircleProperties.pickupScaleFactor
            let maxHeight = frame.height - nodeRadius
            if maxHeight < position.y {
                return CGPointMake(position.x, maxHeight)
            }
        }
        
        return position
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        // println("in touchesmoved and freezeaction is: " + String(freezeAction.description))
        releaseNumber = nil
        releaseOperator = nil
        
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
                activeNode!.position = adjustPositionIntoGameFrame(touchLocation)
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
}
