//
//  OperatorCircle.swift
//  Speedy
//
//  Created by Edward Chiou on 2/14/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import SpriteKit

struct ScoreMultiplier{
    static var multiplier_factor: [Operator: Int] = [.PLUS: 1, .MINUS: 2, .MULTIPLY: 1, .DIVIDE: 2]
    
    static func getMultiplierFactor(operatorSymbol: Operator) -> Int {
        if multiplier_factor[operatorSymbol] != nil {
            return multiplier_factor[operatorSymbol]!
        } else {
            return 1
        }
    }
}

class OperatorCircle: GameCircle{
    var op: Operator?
    let leftNode: NumberCircle?
    let rightNode: NumberCircle?
    
    convenience init(operatorSymbol: Operator){
        self.init()
        setOperator(operatorSymbol)
        setLabel(operatorSymbol)
    }
    
    private func setOperator(operatorSymbol: Operator){
        op = operatorSymbol
    }
    
    private func setLabel(op: Operator){
        var label: SKLabelNode
        
        switch op {
        case .PLUS: label = SKLabelNode(text: "➕")
        case .MINUS: label = SKLabelNode(text: "➖")
        case .MULTIPLY: label = SKLabelNode(text: "✖️")
        case .DIVIDE: label = SKLabelNode(text: "➗")
        default: label = SKLabelNode(text: "what")
        }
        
        label.fontSize = nodeTextFontSize
        label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        shapeNode!.addChild(label)
    }
}
