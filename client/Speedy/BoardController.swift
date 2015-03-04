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
        let header_height: CGFloat = 0.15
        let long_col_vert_padding: CGFloat = 0.10
        let short_col_vert_padding: CGFloat = 0.15
        let col_horiz_padding: CGFloat = 0.15
    }
    
    let constraints = BoardConstraints()
    
    // this is the number of NumberCircles in the long columns (# of numbers)
    let longColNodes = 5
    
    // this is the number of NumberCircles in the short columns (# of operators)
    let shortColNodes = 4
    
    // color to draw debug lines
    let debugColor = UIColor.yellowColor()
    let bgColor = SKColor.whiteColor()
    
    let scene: SKScene
    let frame: CGRect
    
    let debug: Bool
    
    let randomNumbers = RandomNumbers()
    let randomOperators = RandomOperators()
    
    var circleList: [GameCircle] = []
    var nodeRestPositions = [CGPoint]()
    var gameCircles = [GameCircle?]()
    
    init(scene s: SKScene, debug d: Bool) {
        scene = s
        frame = scene.frame
        debug = d
        
        if debug {
            drawDebugLines()
            //addDebugPhysBodies()
        }
        
        setupBoard()
        setupLongColFieldNodes()
        setupShortColFieldNodes()
        addGameCircles()
    }
    
    convenience init(scene: SKScene) {
        self.init(scene: scene, debug: false)
    }
    
    private func setupBoard() {
        //scene.backgroundColor = bgColor
    }
    
    private func drawHeaderLine() {
        let x = 0
        let y = frame.height - frame.height * constraints.header_height
        
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, 0, y)
        CGPathAddLineToPoint(path, nil, frame.width, y)
        
        let node = SKShapeNode(path: path)
        node.strokeColor = debugColor
        
        scene.addChild(node)
    }
    
    func nodeRemoved(pos: Int) {
        gameCircles[pos] = nil
    }
    
    func replaceMissingNodes() {
        func getTopOfColumn(posNum: Int) -> Int {
            if posNum < 2 * longColNodes {
                return posNum % 2
            }
            
            return 10
        }
        
        // move existing long column nodes down as far as possible
        for (var i = 2 * longColNodes - 1; i > 1; i--) {
            if gameCircles[i] != nil {
                continue
            }
            
            let nextNode = gameCircles[i - 2]
            nextNode!.physicsBody?.fieldBitMask = 1 << UInt32(i)
            nextNode!.boardPos = i
            gameCircles[i] = nextNode
            gameCircles[i - 2] = nil
        }
        
        // move short column nodes down as far as possible
        for (var i = gameCircles.count - 1; i > longColNodes * 2; i--) {
            if gameCircles[i] != nil {
                continue
            }
            
            let nextNode = gameCircles[i - 1]
            nextNode!.physicsBody?.fieldBitMask = 1 << UInt32(i)
            nextNode!.boardPos = i
            gameCircles[i] = nextNode
            gameCircles[i - 1] = nil
        }
        
        // bring in new nodes to fill the gaps at the top
        let topIdxs = [0, 1, 2 * longColNodes]
        for idx in topIdxs {
            if gameCircles[idx] != nil {
                continue
            }
            
            let node = (idx == 0 || idx == 1) ? NumberCircle(num: randomNumbers.generateNumber()) :
                OperatorCircle(operatorSymbol: randomOperators.generateOperator())
            let restPosition = nodeRestPositions[idx]
            
            // cause node to start slightly above the rest position
            node.position = CGPoint(x: restPosition.x, y: restPosition.y + node.nodeRadius)
            
            node.physicsBody = createGameCirclePhysBody(1 << UInt32(idx))
            node.setBoardPosition(idx)
            gameCircles[idx] = node
            scene.addChild(node)
        }
        
    }
    
    private func addGameCircles() {
        var physCategory: UInt32 = 0
        for i in 0...(2 * longColNodes + shortColNodes - 1) {
            let node = (i >= 2 * longColNodes) ? OperatorCircle(operatorSymbol: randomOperators.generateOperator()) : NumberCircle(num: randomNumbers.generateNumber())
            //let node = NumberCircle(num: i)
            //node.fillColor = UIColor.redColor()
            node.physicsBody = createGameCirclePhysBody(1 << physCategory)
            node.position = nodeRestPositions[i]
            physCategory++
            
            node.setBoardPosition(i)
            gameCircles.append(node)
            scene.addChild(node)
            circleList.append(node)
        }
    }
    
    /*
    private func addDebugPhysBodies() {
        var physCategory: UInt32 = 0
        for i in 0...(2 * longColNodes + shortColNodes - 1) {
            let node = SKShapeNode(circleOfRadius: 20.0)
            node.fillColor = UIColor.redColor()
            node.physicsBody = createTestPhysBody(1 << physCategory)
            node.position = CGPointMake(scene.frame.midX, scene.frame.midY)
            physCategory++
            
            scene.addChild(node)
        }
    }
*/
    
    private func createGameCirclePhysBody(category: UInt32) -> SKPhysicsBody {
        let physBody = SKPhysicsBody(circleOfRadius: 30.0)
        
        // friction when sliding against this physics body
        physBody.friction = 3.8
        
        // bounciness of this physics body when colliding
        physBody.restitution = 0.8
        
        // mass (and hence inertia) of this physics body
        physBody.mass = 1
        
        // this will allow the balls to rotate when bouncing off each other
        physBody.allowsRotation = false
        
        physBody.dynamic = true
        physBody.fieldBitMask = category
        
        physBody.linearDamping = 2.0
        
        // check for contact with other game circle phys bodies
        physBody.contactTestBitMask = 1
        
        return physBody
    }
    
    /*
    private func createTestPhysBody(category: UInt32) -> SKPhysicsBody {
        let physBody = SKPhysicsBody(circleOfRadius: 20.0)
        
        // friction when sliding against this physics body
        physBody.friction = 3.8
        
        // bounciness of this physics body when colliding
        physBody.restitution = 0.8
        
        // mass (and hence inertia) of this physics body
        physBody.mass = 1
        
        // this will allow the balls to rotate when bouncing off each other
        physBody.allowsRotation = false
        
        //Physics to check collision
        physBody.contactTestBitMask = 0
        physBody.collisionBitMask = 0
        
        physBody.dynamic = true
        physBody.fieldBitMask = category
        
        physBody.linearDamping = 2.0
        
        return physBody
    }
*/
    
    private func drawLongColLines() {
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
    
    private func drawShortColLine() {
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
    
    private func createFieldNode(category: UInt32) -> SKFieldNode {
        let node = SKFieldNode.radialGravityField()
        node.falloff = 0.01
        node.strength = 5.5
        node.minimumRadius = 10.0
        node.categoryBitMask = category
        
        let dragNode = SKFieldNode.dragField()
        dragNode.region = SKRegion(radius: 30.0)
        dragNode.strength = 20.0
        dragNode.categoryBitMask = category
        dragNode.exclusive = true
        //dragNode.minimumRadius = 5.0
        
        node.addChild(dragNode)
        
        return node
    }

    private func setupLongColFieldNodes() {
        let startY = frame.height - (constraints.header_height + constraints.long_col_vert_padding) * frame.height
        let endY = constraints.long_col_vert_padding * frame.height
        let leftX = constraints.col_horiz_padding * frame.width
        let rightX = frame.width - constraints.col_horiz_padding * frame.width
        let yDist = (startY - endY) / CGFloat(longColNodes - 1)
        
        var curOffset: CGFloat = 0.0
        var physCategory: UInt32 = 0
        for i in 1...longColNodes {
            let leftFieldNode = createFieldNode(1 << physCategory)
            physCategory++
            
            leftFieldNode.position = CGPointMake(leftX, startY - curOffset)
            
            let rightFieldNode = createFieldNode(1 << physCategory)
            physCategory++
            
            rightFieldNode.position = CGPointMake(rightX, startY - curOffset)
            
            if debug {
                let leftNode = SKShapeNode(circleOfRadius: 3.0)
                //leftNode.position = CGPointMake(leftX, startY - curOffset)
                leftNode.fillColor = debugColor
                
                let rightNode = SKShapeNode(circleOfRadius: 3.0)
                //rightNode.position = CGPointMake(rightX, startY - curOffset)
                rightNode.fillColor = debugColor
                
                leftFieldNode.addChild(leftNode)
                rightFieldNode.addChild(rightNode)
            }
            
            curOffset += yDist
            
            scene.addChild(leftFieldNode)
            scene.addChild(rightFieldNode)
            
            nodeRestPositions.append(leftFieldNode.position)
            nodeRestPositions.append(rightFieldNode.position)
        }
    }
    
    private func setupShortColFieldNodes() {
        let startY = frame.height - (constraints.header_height + constraints.short_col_vert_padding) * frame.height
        let endY = constraints.short_col_vert_padding * frame.height
        let x = frame.width / 2.0
        let yDist = (startY - endY) / CGFloat(shortColNodes - 1)
        
        var curOffset: CGFloat = 0.0
        var physCategory = 2 * UInt32(longColNodes)
        for i in 1...shortColNodes {
            
            let fieldNode = createFieldNode(1 << physCategory)
            physCategory++
            
            fieldNode.position = CGPointMake(x, startY - curOffset)
            
            if debug {
                let node = SKShapeNode(circleOfRadius: 3.0)
                //node.position = CGPointMake(x, startY - curOffset)
                node.fillColor = debugColor
                
                fieldNode.addChild(node)
            }
            
            curOffset += yDist
            
            scene.addChild(fieldNode)
            nodeRestPositions.append(fieldNode.position)
        }
    }
    
    private func drawDebugLines() {
        drawHeaderLine()
        drawLongColLines()
        drawShortColLine()
    }
    
    func getCircleList() -> [GameCircle]{
        return circleList
    }
}
