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
    
    /*
    let Node:UInt32 = 0x1 << 0;
    let Number:UInt32 = 0x1 << 2;
    let Operator:UInt32 = 0x1 << 3;
    */
    
    let nodeFont = "AmericanTypewriter-Bold"
    let leftNode: Operator?
    let rightNode: Operator?
    
    convenience init(num: Int)    {
        self.init()
        setNumber(num)
        setLabel()
    }
    
    func setNumber(num: Int) {
        number = num
    }
    
    func setLabel(){
        let text = SKLabelNode(text: "\(number!)")
        text.fontSize = nodeTextFontSize
        text.fontName = nodeFont
        text.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        text.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        shapeNode!.addChild(text)
    }
}