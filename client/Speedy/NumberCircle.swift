//
//  NumberCircle.swift
//  Speedy
//
//  Created by Tyler Levine on 2/5/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//
import SpriteKit

class NumberCircle : GameCircle {
    var number: Int?
    
    convenience init(num: Int, col: Int)    {
        self.init(col: col)
        setNumber(num)
        setLabel()
        setCollision()
    }
    
    func setNumber(num: Int) {
        number = num
    }
    
    func setCollision(){
        parentNode!.physicsBody!.categoryBitMask = NumberMask
        parentNode!.physicsBody!.contactTestBitMask = NumberMask | OperatorMask
        parentNode!.physicsBody!.collisionBitMask = NumberMask | OperatorMask
    }
    
    func setLabel(){
        let text = SKLabelNode(text: String(number!))
        text.fontSize = nodeTextFontSize
        text.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        text.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        parentNode!.addChild(text)
    }
}