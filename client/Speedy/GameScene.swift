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
    let canvasHeight: UInt32 = 800 //CHANGE MAGIC NUMBER
    let canvasWidth:UInt32 = 800   //CHANGE MAGIC NUMBER
    let leftColumn:CGFloat = 50    //CHANGE MAGIC NUMBER
    let middleColumn:CGFloat = 190   //CHANGE MAGIC NUMBER
    let rightColumn:CGFloat = 325   //CHANGE MAGIC NUMBER
    let startHeight:CGFloat = 600   //CHANGE MAGIC NUMBER
    
    let Size = CGSize(width:24, height:30)           /*Code for GridLayout*/
    let GridSpacing = CGSize(width:120, height:20)
    let RowCount = 8
    let ColCount = 3
    
    let Node:UInt32 = 0x1 << 0;
    let NonNode:UInt32 = 0x1 << 1;
    
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
        self.physicsWorld.gravity = CGVectorMake(0, 0)
        // we put contraints on the top, left, right, bottom so that our balls can bounce off them
        let physicsBody = SKPhysicsBody (edgeLoopFromRect: self.frame)
        self.physicsBody = physicsBody
        self.physicsWorld.contactDelegate = self;
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
                
                //Physics to check collision
                shape.physicsBody?.contactTestBitMask = Node
                shape.physicsBody?.collisionBitMask = Node
                
                // we set initial random positions
                shape.position = Position
                // we add each circle to the display list
                self.addChild(shape)
                
                
                
                Position = CGPoint(x: Position.x + Size.width + GridSpacing.width, y: PositionY)
            }
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        println("CONTACT")
        var myJoint = SKPhysicsJointPin.jointWithBodyA(contact.bodyA,bodyB: contact.bodyB, anchor: contact.contactPoint)
        self.physicsWorld.addJoint(myJoint)
    }
    
     func didEndContact(contact: SKPhysicsContact) {
        println("Contact 2")
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
        let touchedNode = nodeAtPoint(touchLocation)
        /*Make the touched node do something*/
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        let touchedNode = nodeAtPoint(touchLocation)
        touchedNode.position.x = touchLocation.x
        touchedNode.position.y = touchLocation.y
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* called before each frame is rendered */
    }
}