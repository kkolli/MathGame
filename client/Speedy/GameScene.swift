//
//  GameScene.swift
//  Speedy
//
//  Created by Tyler Levine on 1/27/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import SpriteKit

class GameScene : SKScene, SKPhysicsContactDelegate {
    //TODO: Put constant numbers in CAPS
    /*
    let canvasHeight: UInt32 = 800 //CHANGE MAGIC NUMBER
    let canvasWidth:UInt32 = 800   //CHANGE MAGIC NUMBER
    let leftColumn:CGFloat = 50    //CHANGE MAGIC NUMBER
    let middleColumn:CGFloat = 190   //CHANGE MAGIC NUMBER
    let rightColumn:CGFloat = 325   //CHANGE MAGIC NUMBER
    
    let Size = CGSize(width:24, height:30)           /*Code for GridLayout*/
    let GridSpacing = CGSize(width:120, height:20)
    let RowCount = 8
    let ColCount = 3
    
    //let Node:UInt32 = 0x1 << 0
    //let NonNode:UInt32 = 0x1 << 1
    
    */
    let randomNumbers = RandomNumbers(difficulty: 5) //Hardcoded difficulty value
    let randomOperators = RandomOperators(difficulty: 5) //Hardcoded difficulty value
    
    //var contentCreated = false
    //var wayPoints: [CGPoint] = []
    var activeNode: SKNode?
    
    override func didMoveToView(view: SKView) {
        let boardController = BoardController(scene: self, debug: true)
        
        setUpPhysics()
        /* Setup your scene here
        //drawSpeedy()
        if (!contentCreated) {
            createContent()
            contentCreated = true
            setupColumns()
        }*/
    }
    
    func setUpPhysics(){
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        // we put contraints on the top, left, right, bottom so that our balls can bounce off them
        let physicsBody = SKPhysicsBody (edgeLoopFromRect: self.frame)
        physicsBody.dynamic = false
        physicsBody.categoryBitMask = 0xFFFFFFFF
        self.physicsBody = physicsBody
        self.physicsBody?.restitution = 0.1
        self.physicsBody?.friction = 0.0
        self.physicsWorld.contactDelegate = self;
    }
   /*
    func drawSpeedy(){
        //Draw Column1
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Number";
        myLabel.fontSize = 18;
        myLabel.position = CGPoint(x:leftColumn, y:startHeight);
        self.addChild(myLabel)
        
        //Draw Column2
        let myLabel2 = SKLabelNode(fontNamed:"Chalkduster")
        myLabel2.text = "Operator";
        myLabel2.fontSize = 18;
        myLabel2.position = CGPoint(x:middleColumn, y:startHeight);
        self.addChild(myLabel2)
        
        //Draw Column3
        let myLabel3 = SKLabelNode(fontNamed:"Chalkduster")
        myLabel3.text = "Number";
        myLabel3.fontSize = 18;
        myLabel3.position = CGPoint(x:rightColumn, y:startHeight);
        self.addChild(myLabel3)
    }
    
    func setupColumns() {
        
        // 1
        let baseOrigin = CGPoint(x:leftColumn, y:startHeight - 530)  //Starting position to create Grid
        for var row = 1; row <= RowCount; row++ {

            // 3
            let PositionY = CGFloat(row) * (Size.height * 2) + baseOrigin.y
            var Position = CGPoint(x:baseOrigin.x, y:PositionY)
            
            // 4
            for var col = 1; col <= ColCount; col++ {
                if col % 2 == 0{
                    let op = OperatorCircle(col: col, operatorSymbol: randomOperators.generateOperator())
                    op.setPosition(Position)
                    
                    self.addChild(op.parentNode!)
                }else{
                    let number = NumberCircle(num: randomNumbers.generateNumber(), col: col)
                    number.setPosition(Position)
                    
                    self.addChild(number.parentNode!)
                }
                
                Position = CGPoint(x: Position.x + Size.width + GridSpacing.width, y: PositionY)
            }
        }
    }
    */
    
    func didBeginContact(contact: SKPhysicsContact) {
        println("CONTACT")
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.joints.count <= 1 && contact.bodyB.joints.count <= 1 {
            var myJoint = SKPhysicsJointPin.jointWithBodyA(contact.bodyA, bodyB: contact.bodyB,
                anchor: contact.bodyA.node!.position)
            myJoint.frictionTorque = 1.0
            self.physicsWorld.addJoint(myJoint)
        }
        
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        println("Contact 2")
    }
    
    let Size = CGSize(width:24, height:30)           /*Code for GridLayout*/
    let GridSpacing = CGSize(width:120, height:20)
    let RowCount = 8
    let ColCount = 3
    
    var contentCreated = false
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        drawSpeedy()
        if (!contentCreated) {
            createContent()
            contentCreated = true
            setupColumns()
            setUpPhysics()
        }
    }
    
    func setUpPhysics(){
        self.physicsWorld.gravity = CGVectorMake(-1, -1)
        // we put contraints on the top, left, right, bottom so that our balls can bounce off them
        let physicsBody = SKPhysicsBody (edgeLoopFromRect: self.frame)
        self.physicsBody = physicsBody
    }
    
    func createContent() {
        self.backgroundColor = SKColor.lightGrayColor()
    }
    
    func drawSpeedy(){
        //Draw Column1
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Number";
        myLabel.fontSize = 18;
        myLabel.position = CGPoint(x:leftColumn, y:startHeight);
        self.addChild(myLabel)
        
        //Draw Column2
        let myLabel2 = SKLabelNode(fontNamed:"Chalkduster")
        myLabel2.text = "Operator";
        myLabel2.fontSize = 18;
        myLabel2.position = CGPoint(x:middleColumn, y:startHeight);
        self.addChild(myLabel2)
        
        //Draw Column3
        let myLabel3 = SKLabelNode(fontNamed:"Chalkduster")
        myLabel3.text = "Number";
        myLabel3.fontSize = 18;
        myLabel3.position = CGPoint(x:rightColumn, y:startHeight);
        self.addChild(myLabel3)
    }
    
    func setupColumns() {
        
        // 1
        let baseOrigin = CGPoint(x:leftColumn, y:startHeight - 530)  //Starting position to create Grid
        for var row = 1; row <= RowCount; row++ {

            
            // 3
            let PositionY = CGFloat(row) * (Size.height * 2) + baseOrigin.y
            var Position = CGPoint(x:baseOrigin.x, y:PositionY)
            
            // 4
            for var col = 1; col <= ColCount; col++ {
                
                let shape = SKShapeNode(circleOfRadius: 20)
                shape.strokeColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.5)
                shape.lineWidth = 4
                let text = SKLabelNode(text: String(3))
                // we set the font
                text.fontSize = 16.0
                // we nest the text label in our circle
                shape.addChild(text)
                shape.physicsBody = SKPhysicsBody(circleOfRadius: shape.frame.size.width/2)
                // this defines the mass, roughness and bounciness
                shape.physicsBody?.friction = 0.3
                shape.physicsBody?.restitution = 0.8
                shape.physicsBody?.mass = 0.5
                // this will allow the balls to rotate when bouncing off each other
                shape.physicsBody?.allowsRotation = false
                
                // we set initial random positions
                shape.position = Position
                // we add each circle to the display list
                self.addChild(shape)
                
                
                
                Position = CGPoint(x: Position.x + Size.width + GridSpacing.width, y: PositionY)
            }
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* touch has begun */
        /*for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let touchedNode = nodeAtPoint(location)
            touchedNode.position.x = event.
        }*/
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        var touchedNode = nodeAtPoint(touchLocation)
        
        /*
        if touchedNode is GameCircle {
            println("GameCircle touched")
        }
        
        if touchedNode is SKLabelNode {
            println("Label node touched")
        }
        */
        
        while !(touchedNode is GameCircle) {
            if touchedNode is SKScene {
                // can't move the scene, finger probably fell off a circle?
                if let physBody = activeNode?.physicsBody {
                    physBody.dynamic = true
                }
                return
            }
            touchedNode = touchedNode.parent!
        }
        
        /*Make the touched node do something*/
        if let physBody = touchedNode.physicsBody {
            physBody.dynamic = false
        }
        activeNode = touchedNode
    }
    
<<<<<<< HEAD
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        var touchedNode = nodeAtPoint(touchLocation)
        while !(touchedNode is GameCircle) {
            if touchedNode is SKScene {
                // can't move the scene, finger probably fell off a circle?
                if let physBody = activeNode?.physicsBody {
                    physBody.dynamic = true
                }
                return
            }
            touchedNode = touchedNode.parent!
        }
        
        touchedNode.position.x = touchLocation.x
        touchedNode.position.y = touchLocation.y
        
        //addPoint(touchLocation)
    }


    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
       // wayPoints.removeAll(keepCapacity: false)
        if let physBody = activeNode?.physicsBody {
            physBody.dynamic = true
        }
        
        activeNode = nil
    }
    /*
    override func update(currentTime: CFTimeInterval) {
        /* called before each frame is rendered */
        drawLine()
    }
    
    func drawLine(){
        enumerateChildNodesWithName("line", usingBlock: {node, stop in
            node.removeFromParent()
        })
            
        if let path = createPath(){
            let shapeNode = SKShapeNode()
            shapeNode.path = path
            shapeNode.name = "line"
            shapeNode.strokeColor = UIColor.blueColor()
            shapeNode.lineWidth = 2
            shapeNode.zPosition = 1
            
            self.addChild(shapeNode)
        }
    }
    
    func createPath() -> CGPathRef? {
        if wayPoints.count <= 1 {
            return nil
        }
        
        var ref = CGPathCreateMutable()
        
        for var i = 0; i < wayPoints.count; ++i{
            let p = wayPoints[i]
            
            if i == 0{
                CGPathMoveToPoint(ref, nil, p.x, p.y)
            }else{
                CGPathAddLineToPoint(ref, nil, p.x, p.y)
            }
        }
        
        return ref
    }
    
    func addPoint(point: CGPoint){
        wayPoints.append(point)
    }
*/
}
