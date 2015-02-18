//
//  BoardController.swift
//  Speedy
//
//  Created by Tyler Levine on 2/12/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//
import SpriteKit

class BoardController {
    // defines board element positioning, in relative percents
    struct BoardConstraints {
        let header_height: CGFloat = 0.1
        let long_col_vert_padding: CGFloat = 0.05
        let short_col_vert_padding: CGFloat = 0.10
        let col_horiz_padding: CGFloat = 0.15
    }
    
    let constraints = BoardConstraints()
    
    // this is the number of NumberCircles in the long columns (# of numbers)
    let longColNodes = 7
    
    // this is the number of NumberCircles in the short columns (# of operators)
    let shortColNodes = 5
    
    // color to draw debug lines
    let debugColor = UIColor.yellowColor()
    let bgColor = SKColor.whiteColor()
    
    let scene: SKScene
    let frame: CGRect
    
    init(scene s: SKScene) {
        scene = s
        frame = scene.frame
    }
    
    func setupBoard() {
        scene.backgroundColor = bgColor
    }
    
    func drawHeaderLine() {
        let x = 0
        let y = frame.height - frame.height * constraints.header_height
        
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, 0, y)
        CGPathAddLineToPoint(path, nil, frame.width, y)
        
        let node = SKShapeNode(path: path)
        node.strokeColor = debugColor
        
        scene.addChild(node)
    }
    
    func drawLongCols() {
        let starty = frame.height - (constraints.header_height + constraints.long_col_vert_padding) * frame.height
        let endy = constraints.long_col_vert_padding * frame.height
        let leftX = constraints.col_horiz_padding * frame.width
        let rightX = frame.width - constraints.col_horiz_padding * frame.width
        
        // draw left col
        let leftPath = CGPathCreateMutable()
        CGPathMoveToPoint(leftPath, nil, leftX, starty)
        CGPathAddLineToPoint(leftPath, nil, leftX, endy)
        
        let leftNode = SKShapeNode(path: leftPath)
        leftNode.strokeColor = debugColor
        
        // draw right col
        let rightPath = CGPathCreateMutable()
        CGPathMoveToPoint(rightPath, nil, rightX, starty)
        CGPathAddLineToPoint(rightPath, nil, rightX, endy)
        
        let rightNode = SKShapeNode(path: rightPath)
        rightNode.strokeColor = debugColor
        
        scene.addChild(leftNode)
        scene.addChild(rightNode)
    }
    
    func drawShortCol() {
        let starty = frame.height - (constraints.header_height + constraints.short_col_vert_padding) * frame.height
        let endy = constraints.short_col_vert_padding * frame.height
        let x = frame.width / 2.0
        
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, x, starty)
        CGPathAddLineToPoint(path, nil, x, endy)
        
        let node = SKShapeNode(path: path)
        node.strokeColor = debugColor
        
        scene.addChild(node)
    }
    
    func drawLongColNests() {
        let startY = frame.height - (constraints.header_height + constraints.long_col_vert_padding) * frame.height
        let endY = constraints.long_col_vert_padding * frame.height
        let leftX = constraints.col_horiz_padding * frame.width
        let rightX = frame.width - constraints.col_horiz_padding * frame.width
        let yDist = (startY - endY) / CGFloat(longColNodes - 1)
        
        var curOffset: CGFloat = 0.0
        for i in 1...longColNodes {
            let leftNode = SKShapeNode(circleOfRadius: 3.0)
            leftNode.position = CGPointMake(leftX, startY - curOffset)
            leftNode.fillColor = debugColor
            
            let rightNode = SKShapeNode(circleOfRadius: 3.0)
            rightNode.position = CGPointMake(rightX, startY - curOffset)
            rightNode.fillColor = debugColor
            
            curOffset += yDist
            
            scene.addChild(leftNode)
            scene.addChild(rightNode)
        }
    }
    
    func drawShortColNests() {
        let startY = frame.height - (constraints.header_height + constraints.short_col_vert_padding) * frame.height
        let endY = constraints.short_col_vert_padding * frame.height
        let x = frame.width / 2.0
        let yDist = (startY - endY) / CGFloat(shortColNodes - 1)
        
        var curOffset: CGFloat = 0.0
        for i in 1...shortColNodes {
            let node = SKShapeNode(circleOfRadius: 3.0)
            node.position = CGPointMake(x, startY - curOffset)
            node.fillColor = debugColor
            
            curOffset += yDist
            
            scene.addChild(node)
        }
    }
    
    func drawDebug() {
        // draw header separator
        drawHeaderLine()
        drawLongCols()
        drawShortCol()
        drawLongColNests()
        drawShortColNests()
    }
    
}