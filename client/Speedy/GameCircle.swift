//
//  GameCircle.swift
//  Speedy
//
//  Created by Edward Chiou on 2/14/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import SpriteKit

struct GameCircleProperties {
    static let nodeRadius: CGFloat = 23
    static let nodeStrokeColor = UIColor.yellowColor()
    static let nodeTextFontSize: CGFloat = 16.0
    static let nodeLineWidth: CGFloat = 4
    static let nodeFillColor = UIColor.redColor()
    static let pickupScaleFactor: CGFloat = 1.2
}

class GameCircle: SKNode{
    //var column: Int?
    var shapeNode: SKShapeNode?
    var neighbor: GameCircle?
    
    var boardPos: Int?
    
    override init() {
        super.init()
        setupNodes()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupNodes() {
        shapeNode = SKShapeNode(circleOfRadius: GameCircleProperties.nodeRadius)
        shapeNode!.strokeColor = GameCircleProperties.nodeStrokeColor
        shapeNode!.lineWidth = GameCircleProperties.nodeLineWidth
        shapeNode!.antialiased = true
        shapeNode!.fillColor = GameCircleProperties.nodeFillColor
        
        self.addChild(shapeNode!)
    }
    
    func setNeighbor(neighborNode: GameCircle){
        neighbor = neighborNode
    }
    
    func hasNeighbor() -> Bool{
        return self.neighbor != nil;
    }
    
    func getLeftAnchor() -> CGPoint {
        return CGPoint(x: self.position.x - GameCircleProperties.nodeRadius, y: self.position.y)
    }
    
    func getRightAnchor() -> CGPoint {
        return CGPoint(x: self.position.x + GameCircleProperties.nodeRadius, y: self.position.y)
    }
    
    func setBoardPosition(pos: Int) {
        boardPos = pos
    }
}
