//
//  BoardController.swift
//  Speedy
//
//  Created by Tyler Levine on 2/12/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//
import SpriteKit

enum BoardMode {
    case SINGLE
    case MULTI
}

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
    
    let scene: GameScene
    let frame: CGRect
    
    let debug: Bool
    
    let randomNumbers = RandomNumbers()
    let randomOperators = RandomOperators()
    
    //var circleList: [GameCircle] = []
    var nodeRestPositions = [CGPoint]()
    var gameCircles = [GameCircle?]()
    
    let headerController: BoardHeaderController?
    let mode: BoardMode?
    
    var targetNumber: Int?
    var score = 0
    
    var operatorsUsed: [Operator]!
    var notifyScoreChanged: (() -> ())!
    
    init(mode m: BoardMode, scene s: GameScene, debug d: Bool) {
        scene = s
        frame = scene.frame
        debug = d
        mode = m;
        
        
        if debug {
            drawDebugLines()
            //addDebugPhysBodies()
        }
        
        setUpScenePhysics()
        setupBoard()
        
        headerController = BoardHeaderController(mode: m, scene: s, frame: createHeaderFrame(), board: self)
        
        addGameCircles()
        
        operatorsUsed = []
    }
    
    func setTimeInHeader(time: Int) {
        headerController?.setTimeRemaining(time)
    }
    
    func setOpponentScore(score: Int) {
        println("SETTING OPPONENT SCORE")
        headerController!.setOpponentScore(score)
    }
    
    func setOpponentName(opponent: String) {
        headerController!.setOpponentName(opponent)
    }
    
    convenience init(scene: GameScene, mode: BoardMode) {
        self.init(mode: mode, scene: scene, debug: false)
    }
    
    private func setupBoard() {
        generateNewTargetNumber()
        setupLongColFieldNodes()
        setupShortColFieldNodes()
    }
    
    private func createHeaderFrame() -> CGRect {
        let x = frame.origin.x
        let y = frame.origin.y + frame.height * (1 - constraints.header_height)
        let width = frame.width
        let height = frame.height * constraints.header_height
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func handleMerge(leftNumberCircle: NumberCircle, rightNumberCircle: NumberCircle, opCircle: OperatorCircle) {
        println("HANDLING MERGE...")
        var result: Int
        var nodeScore: Int
        
        let op1 = leftNumberCircle.number!
        let op2 = rightNumberCircle.number!
        let oper = opCircle.op!
        
        switch oper{
        case .PLUS:
            result = op1 + op2
        case .MINUS:
            result = op1 - op2
        case .MULTIPLY:
            result = op1 * op2
        case .DIVIDE:
            result = op1 / op2
        }
        
        nodeScore = leftNumberCircle.getScore() + rightNumberCircle.getScore() * ScoreMultiplier.getMultiplierFactor(oper)
        
        
        nodeRemoved(leftNumberCircle.boardPos!)
        nodeRemoved(opCircle.boardPos!)
        
        // clear phys bodies so we don't get weird physics glitches
        leftNumberCircle.physicsBody = nil
        opCircle.physicsBody = nil
        
        let mergeAction = actionAnimateNodeMerge(rightNumberCircle)
        let removeAction = SKAction.runBlock {
            leftNumberCircle.removeFromParent()
            opCircle.removeFromParent()
        }
        
        let sequence = SKAction.sequence([mergeAction, removeAction])
        
        leftNumberCircle.runAction(sequence)
        opCircle.runAction(sequence)
        
        if result == targetNumber {
            println("TARGET NUMBER MATCHED: \(result)")
            // update the score, update the target number, and notify changed
            targetNumberMatched(nodeScore)
            
            rightNumberCircle.physicsBody = nil
            
            let waitAction = SKAction.waitForDuration(NSTimeInterval(sequence.duration + 0.1))
            let scoreAction = actionAnimateNodeToScore(rightNumberCircle)
            let removeAction = SKAction.runBlock {
                rightNumberCircle.removeFromParent()
            }
            
            let sequence = SKAction.sequence([waitAction, scoreAction, removeAction])
            rightNumberCircle.runAction(sequence)
            
            nodeRemoved(rightNumberCircle.boardPos!)
        }else if result == 0 {
            let waitAction = SKAction.waitForDuration(NSTimeInterval(sequence.duration + 0.1))
            let disappearAction = actionAnimateNodeDisappear(rightNumberCircle)
            let removeAction = SKAction.runBlock {
                rightNumberCircle.removeFromParent()
            }
            
            let sequence = SKAction.sequence([waitAction, disappearAction, removeAction])
            rightNumberCircle.runAction(sequence)
            
            rightNumberCircle.setNumber(result)
            nodeRemoved(rightNumberCircle.boardPos!)
        }
        else {
            rightNumberCircle.setScore(nodeScore)
            rightNumberCircle.setNumber(result)
            rightNumberCircle.neighbor = nil
        }
        
        operatorsUsed!.append(oper)
        
        replaceMissingNodes()
    }
    
    func actionAnimateNodeToScore(node: SKNode) -> SKAction {
        var targetPos = headerController!.getScorePosition()
        targetPos.y = targetPos.y + frame.height * (1 - constraints.header_height)
        let moveAction = SKAction.moveTo(targetPos, duration: NSTimeInterval(0.4))
        let scaleAction = SKAction.scaleTo(0.0, duration: NSTimeInterval(0.4))
        let actionGroup = SKAction.group([moveAction, scaleAction])
        
        return actionGroup
    }
    
    func actionAnimateNodeMerge(nodeTarget: SKNode) -> SKAction {
        let targetPos = nodeTarget.position
        let moveAction = SKAction.moveTo(targetPos, duration: NSTimeInterval(0.2))
        let scaleAction = SKAction.scaleTo(0.0, duration: NSTimeInterval(0.15))
        let actionGroup = SKAction.group([moveAction, scaleAction])
        
        return actionGroup
    }
    
    func actionAnimateNodeDisappear(node: SKNode) -> SKAction {
        return SKAction.scaleTo(0.0, duration: NSTimeInterval(0.2))
    }
    
    func targetNumberMatched(nodeScore: Int) {
        score += nodeScore
        headerController!.setScore(score)
        generateNewTargetNumber()
        notifyScoreChanged()
    }
    
    
    func generateNewTargetNumber(){
        if targetNumber != nil{
            let numberList = gameCircles.filter{$0 is NumberCircle}.map{($0 as NumberCircle).number!}
            targetNumber = randomNumbers.generateTarget(numberList)
        }else{
            targetNumber = randomNumbers.generateTarget()
        }
        headerController?.setTargetNumber(targetNumber!)
        //GameTargetNumLabel.text = String(targetNumber!)
    }
    
    func setUpScenePhysics() {
        scene.physicsWorld.gravity = CGVectorMake(0, 0)
        scene.physicsBody = createScenePhysBody()
        
        scene.setGameFrame(getGameBoardRect())
    }
    
    private func createScenePhysBody() -> SKPhysicsBody {
        // we put contraints on the top, left, right, bottom so that our balls can bounce off them
        
        let physicsBody = SKPhysicsBody(edgeLoopFromRect: getGameBoardRect())
        
        physicsBody.dynamic = false
        physicsBody.categoryBitMask = 0xFFFFFFFF
        physicsBody.restitution = 0.1
        physicsBody.friction = 0.0
        
        return physicsBody
    }
    
    private func getGameBoardRect() -> CGRect {
        let origin = scene.frame.origin
        let width = scene.frame.width
        let height = scene.frame.height * (1 - constraints.header_height)
        
        return CGRectMake(origin.x, origin.y, width, height)
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
    
    func upgradeCircle(){
        let shouldUpgrade = Int(arc4random_uniform(10) + 1)
            
        if shouldUpgrade == 1{
            let upgradeOption = UpgradeOptions(rawValue: Int(arc4random_uniform(2)))
            
            let numberCircles = gameCircles.filter{$0 is NumberCircle}
            let upgradedCircles = numberCircles.filter{($0 as NumberCircle).upgrade != .None}
            let unUpgradedCircles = numberCircles.filter{($0 as NumberCircle).upgrade == .None}
            
            if upgradeOption != .None && upgradedCircles.count < 2{
                let index = Int(arc4random_uniform(UInt32(unUpgradedCircles.count)))
                
                var nodeToUpgrade = unUpgradedCircles[index] as NumberCircle
                if nodeToUpgrade !== scene.getActiveNode() {
                    nodeToUpgrade.setUpgrade(upgradeOption!)
                    nodeToUpgrade.setFillColor(upgradeOption!.upgradeColor())
                }
            }
        }
    }
    
    func replaceMissingNodes() {
        func topColIdx(idx: Int) -> Int {
            if idx < 2 * longColNodes {
                // in a long column
                return idx % 2
            } else {
                // in the short column
                return 2 * longColNodes
            }
        }
        
        // move existing long column nodes down as far as possible
        for (var i = 2 * longColNodes - 1; i > 1; i--) {
            if gameCircles[i] != nil {
                continue
            }
            
            for (var j = i - 2; j >= topColIdx(i); j -= 2) {
                if let nextNode = gameCircles[j] {
                    // move this node into the i'th spot
                    nextNode.physicsBody?.fieldBitMask = 1 << UInt32(i)
                    nextNode.boardPos = i
                    gameCircles[i] = nextNode
                    gameCircles[j] = nil
                    break
                }
            }
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
        
        var nodesAdded = (leftCol: 0.0, rightCol: 0.0)
        
        // bring in new nodes to fill the gaps at the top
        for (var idx = gameCircles.count - 1; idx >= 0; idx--) {
            if gameCircles[idx] != nil {
                continue
            }
            
            //println("replacing node \(idx)")
            
            let node = (idx < 2 * longColNodes) ? NumberCircle(num: randomNumbers.generateNumber()) :
                OperatorCircle(operatorSymbol: randomOperators.generateOperator())
            
            var delayMultiplier: CGFloat = 1.0
            if node is NumberCircle {
                if idx % 2 == 0 {
                    nodesAdded.leftCol++
                    delayMultiplier = CGFloat(4 * nodesAdded.leftCol)
                } else {
                    nodesAdded.rightCol++
                    delayMultiplier = CGFloat(4 * nodesAdded.rightCol)
                }
            }
            
            // cause node to start slightly above the rest position
            let restPosition = nodeRestPositions[topColIdx(idx)]
            node.position = CGPoint(x: restPosition.x, y: restPosition.y + GameCircleProperties.nodeRadius)
            node.setScale(0.0)
            node.setBoardPosition(idx)
            gameCircles[idx] = node
            
            let delayAction = SKAction.waitForDuration(NSTimeInterval(0.1 * delayMultiplier))
            let scaleAction = SKAction.scaleTo(1.0, duration: NSTimeInterval(0.2))
            scaleAction.timingMode = SKActionTimingMode.EaseIn
            let physBody = self.createGameCirclePhysBody(1 << UInt32(idx))
            let bitmaskAction = SKAction.runBlock {
                node.physicsBody = physBody
            }
            let seqAction = SKAction.sequence([delayAction, scaleAction, bitmaskAction])
            node.runAction(seqAction)
            
            scene.addChild(node)
        }
        
    }
    
    private func addGameCircles() {
        var physCategory: UInt32 = 0
        var scaleDelay: CGFloat = 0.2
        var scaleDelayIncrement: CGFloat = 0.1
        var scaleDuration: CGFloat = 0.2
        for i in 0...(2 * longColNodes + shortColNodes - 1) {
            let node = (i >= 2 * longColNodes) ? OperatorCircle(operatorSymbol: randomOperators.generateOperator()) : NumberCircle(num: randomNumbers.generateNumber())
            //let node = NumberCircle(num: i)
            //node.fillColor = UIColor.redColor()
            node.physicsBody = createGameCirclePhysBody(1 << physCategory)
            node.position = nodeRestPositions[i]
            node.setScale(0.0)
            physCategory++
            
            if i == 2 * longColNodes {
                scaleDelay = 0.2
            }
            
            let delayAction = SKAction.waitForDuration(NSTimeInterval(scaleDelay))
            let scaleAction = SKAction.scaleTo(1.0, duration: NSTimeInterval(scaleDuration))
            scaleAction.timingMode = SKActionTimingMode.EaseIn
            let groupAction = SKAction.sequence([delayAction, scaleAction])
            node.runAction(groupAction)
            
            if i % 2 == 1 {
                scaleDelay += scaleDelayIncrement
            }
            
            node.setBoardPosition(i)
            gameCircles.append(node)
            scene.addChild(node)
            //circleList.append(node)
        }
    }
    
    private func createGameCirclePhysBody(category: UInt32) -> SKPhysicsBody {
        let physBody = SKPhysicsBody(circleOfRadius: GameCircleProperties.nodeRadius)
        
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
}
