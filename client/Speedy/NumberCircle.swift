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
    
    let Node:UInt32 = 0x1 << 0;
    let Number:UInt32 = 0x1 << 2;
    let Operator:UInt32 = 0x1 << 3;
    
    convenience init(num: Int, col: Int)    {
        self.init(col: col)
        setNumber(num)
        setLabel()
    }
    
    func setNumber(num: Int) {
        number = num
    }
    
    func setLabel(){
        let text = SKLabelNode(text: String(number!))
        text.fontSize = nodeTextFontSize
        text.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        text.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        parentNode!.addChild(text)
    }
}