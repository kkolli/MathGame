//
//  NumberCircle.swift
//  Speedy
//
//  Created by Tyler Levine on 2/5/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//
import SpriteKit

class NumberCircle : SKNode {
    var number: Int?
    var parentNode: SKShapeNode?
    
    let nodeRadius: CGFloat = 20
    let nodeStrokeColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.5)
    let nodeTextFontSize: CGFloat = 16.0
    let nodeLineWidth: CGFloat = 4
    
    let physicsFriction: CGFloat = 0.1
    let physicsRestitution: CGFloat = 0.8
    let physicsMass: CGFloat = 0.1
    
    convenience init(num: Int) {
        self.init()
        setupNodes()
        setNumber(num)
    }
    
    func setNumber(num: Int) {
        number = num
    }
    
    func setupNodes() {
        parentNode = SKShapeNode(circleOfRadius: nodeRadius)
        parentNode!.strokeColor = nodeStrokeColor
        parentNode!.lineWidth = nodeLineWidth
        
        let text = SKLabelNode(text: String(number!))
        text.fontSize = nodeTextFontSize
        parentNode!.addChild(text)
    }
    
    func setupPhysicsBody() {
        parentNode!.physicsBody = SKPhysicsBody(circleOfRadius: parentNode!.frame.size.width / 2)
        physicsBody!.friction = physicsFriction
        physicsBody!.restitution = physicsRestitution
        physicsBody!.mass = physicsMass
        
    }
    
    func setPosition(x: CGFloat, y: CGFloat) {
        parentNode?.position = CGPoint(x: x, y: y)
    }
}