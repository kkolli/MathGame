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
    var neighbor: GameCircle?
    
    let nodeRadius: CGFloat = 20
    let nodeStrokeColor = UIColor.yellowColor()
    let nodeTextFontSize: CGFloat = 16.0
    let nodeLineWidth: CGFloat = 4
    let nodeFillColor = UIColor.redColor()
    
    override init() {
        super.init()
        setupNodes()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupNodes() {
        shapeNode = SKShapeNode(circleOfRadius: nodeRadius)
        shapeNode!.strokeColor = nodeStrokeColor
        shapeNode!.lineWidth = nodeLineWidth
        shapeNode!.antialiased = true
        shapeNode!.fillColor = nodeFillColor
        
        self.addChild(shapeNode!)
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
}
