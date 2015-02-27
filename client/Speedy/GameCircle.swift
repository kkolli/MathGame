//
//  GameCircle.swift
//  Speedy
//
//  Created by Edward Chiou on 2/14/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import SpriteKit

class GameCircle: SKNode{
    //var column: Int?
    var shapeNode: SKShapeNode?
    
    let nodeRadius: CGFloat = 20
    //let nodeStrokeColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.5)
    let nodeStrokeColor = UIColor.yellowColor()
    let nodeTextFontSize: CGFloat = 16.0
    let nodeLineWidth: CGFloat = 4
    let nodeFillColor = UIColor.redColor()
    
    /*
    let physicsFriction: CGFloat = 0.1
    let physicsRestitution: CGFloat = 0.8
    let physicsMass: CGFloat = 0.1
    let physicsAllowRotation: Bool = false
    let physicsImpulse: CGVector = CGVectorMake(10.0, -10.0)
    let physicsUsePreciseCollisionDetection: Bool = true
    */
    
    override init() {
        super.init()
        setupNodes()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /*
    func setColumn(col: Int){
        column = col
    }
    */

    func setupNodes() {
        shapeNode = SKShapeNode(circleOfRadius: nodeRadius)
        shapeNode!.strokeColor = nodeStrokeColor
        shapeNode!.lineWidth = nodeLineWidth
        shapeNode!.antialiased = true
        shapeNode!.fillColor = nodeFillColor
        
        self.addChild(shapeNode!)
    }
    
    /*
    func setupPhysicsBody() {
        shapeNode!.physicsBody = SKPhysicsBody(circleOfRadius: shapeNode!.frame.size.width / 2)
        shapeNode!.physicsBody!.friction = physicsFriction
        shapeNode!.physicsBody!.restitution = physicsRestitution
        shapeNode!.physicsBody!.mass = physicsMass
        shapeNode!.physicsBody!.allowsRotation = physicsAllowRotation
        shapeNode!.physicsBody!.applyImpulse(physicsImpulse)
        shapeNode!.physicsBody!.usesPreciseCollisionDetection = physicsUsePreciseCollisionDetection
        shapeNode!.physicsBody!.dynamic = true
    }

    func setPosition(position: CGPoint) {
        shapeNode?.position = position
    }
    */
}
