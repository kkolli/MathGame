//
//  GameCircle.swift
//  Speedy
//
//  Created by Edward Chiou on 2/14/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import SpriteKit

class GameCircle: SKNode{
    var column: Int?
    var parentNode: SKShapeNode?
    var neighbor: GameCircle?
    
    let NumberMask:UInt32 = 0x1 << 2;
    let OperatorMask:UInt32 = 0x1 << 3;
    
    let nodeRadius: CGFloat = 20
    let nodeStrokeColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.5)
    let nodeTextFontSize: CGFloat = 16.0
    let nodeLineWidth: CGFloat = 4
    
    let physicsFriction: CGFloat = 0.1
    let physicsRestitution: CGFloat = 0.8
    let physicsMass: CGFloat = 0.1
    let physicsAllowRotation: Bool = false
    let physicsImpulse: CGVector = CGVectorMake(10.0, -10.0)
    let physicsUsePreciseCollisionDetection: Bool = true
    
    convenience init(col: Int)    {
        self.init()
        setColumn(col)
        setupNodes()
        setupPhysicsBody()
    }
    
    func setColumn(col: Int){
        column = col
    }

    func setupNodes() {
        parentNode = SKShapeNode(circleOfRadius: nodeRadius)
        parentNode!.strokeColor = nodeStrokeColor
        parentNode!.lineWidth = nodeLineWidth
        parentNode!.antialiased = true
        
        self.addChild(parentNode!)
    }
    
    func setupPhysicsBody() {
        parentNode!.physicsBody = SKPhysicsBody(circleOfRadius: parentNode!.frame.size.width / 2)
        parentNode!.physicsBody!.friction = physicsFriction
        parentNode!.physicsBody!.restitution = physicsRestitution
        parentNode!.physicsBody!.mass = physicsMass
        parentNode!.physicsBody!.allowsRotation = physicsAllowRotation
        parentNode!.physicsBody!.applyImpulse(physicsImpulse)
        parentNode!.physicsBody!.usesPreciseCollisionDetection = physicsUsePreciseCollisionDetection
        parentNode!.physicsBody!.dynamic = true
    }
    
    func setPosition(position: CGPoint) {
        parentNode?.position = position
    }
    
    func setNeighbor(neighborNode: GameCircle){
        neighbor = neighborNode
    }
    
    func hasNeighbor() -> Bool{
        if let neighbor = self.neighbor{
            return true
        }else{
            return false
        }
    }
    
    func setResultLabel(result: Int){
        if parentNode!.children.count > 0{
            parentNode!.removeAllChildren()
        }
        
        let resultLabel = SKLabelNode(text: String(result))
        resultLabel.fontSize = nodeTextFontSize
        resultLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        resultLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        parentNode!.addChild(resultLabel)
    }
}