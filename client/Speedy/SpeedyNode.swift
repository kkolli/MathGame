//
//  SpeedyNode.swift
//  Speedy
//
//  Created by Tyler Levine on 1/29/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import SpriteKit

class SpeedyNode : SKNode {
    
    let number: Int?
    let op: String?
    let radius: CGFloat = 20.0
    let strokeColor = UIColor.redColor()
    let lineWidth: CGFloat = 4
    let fontSize: CGFloat = 16.0
    let fontColor = UIColor.blackColor()
    
    var active = false
    
    init(num: Int) {
        self.number = num
        super.init()
        create()
    }
    
    init(op: String) {
        self.op = op
        super.init()
        create()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        create()
    }
    
    func create() {
        self.userInteractionEnabled = true
        self.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        
        let shape = SKShapeNode(circleOfRadius: radius)
        shape.strokeColor = strokeColor
        shape.lineWidth = lineWidth
        
        let text = SKLabelNode()
        if let num = number {
            text.text = "\(num)"
        } else if let op = op {
            text.text = op
        }
        
        text.fontSize = fontSize
        text.fontColor = fontColor
        
        shape.addChild(text)
        self.addChild(shape)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        println("\(number): that tickles")
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        println("\(number): touch moved")
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        println("\(number) was set down")
    }
    
}