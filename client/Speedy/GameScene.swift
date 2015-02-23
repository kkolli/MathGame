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
    
    let randomNumbers = RandomNumbers(difficulty: 5) //Hardcoded difficulty value
    let randomOperators = RandomOperators(difficulty: 5) //Hardcoded difficulty value
    
    var contentCreated = false
    var currentJoint: SKPhysicsJoint?
    
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
        physicsBody.dynamic = false
        self.physicsBody = physicsBody
        self.physicsBody?.restitution = 0.1
        self.physicsBody?.friction = 0.0
        self.physicsWorld.contactDelegate = self;
        
        let physField = SKFieldNode.springField()
        physField.position = CGPointMake(self.size.width / 2, self.size.height / 2)
        physField.exclusive = true
        // disable for now, we know it works
        physField.enabled = false
        physField.falloff = 0.001
        physField.strength = 20
        physField.region = SKRegion(size: self.frame.size)
        self.addChild(physField)
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
                if col % 2 == 0{
                    let op = OperatorCircle(col: col, operatorSymbol: randomOperators.generateOperator())
                    op.setPosition(Position)
                    
                    self.addChild(op)
                }else{
                    let number = NumberCircle(num: randomNumbers.generateNumber(), col: col)
                    number.setPosition(Position)
                    
                    self.addChild(number)
                }
                
                Position = CGPoint(x: Position.x + Size.width + GridSpacing.width, y: PositionY)
            }
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var numberBody: SKPhysicsBody
        var opBody: SKPhysicsBody
        
        //A neccessary check to prevent contacts from throwing runtime errors
        if contact.bodyA.node != nil && contact.bodyB.node != nil && contact.bodyA.node!.parent != nil && contact.bodyB.node!.parent != nil{
            //This is dependant on the order of the nodes
            if contact.bodyA.node!.parent! is NumberCircle{
                numberBody = contact.bodyA
                
                if contact.bodyB.node!.parent! is OperatorCircle{
                    opBody = contact.bodyB
                    
                    let numberNode = numberBody.node!.parent! as NumberCircle
                    let opNode     = opBody.node!.parent! as OperatorCircle
                    
                    if numberNode.hasNeighbor() == false && opNode.hasNeighbor() == false{
                        var myJoint = SKPhysicsJointPin.jointWithBodyA(numberBody, bodyB: opBody,
                            anchor: numberBody.node!.position)
                        
                        numberNode.setNeighbor(opNode)
                        opNode.setNeighbor(numberNode)
                        
                        myJoint.frictionTorque = 1.0
                        self.physicsWorld.addJoint(myJoint)
                        currentJoint = myJoint
                    }else{
                        let lhs = (opNode.neighbor as NumberCircle).number
                        let op  = opNode.op
                        
                        numberNode.setResultLabel(lhs!, rhs: numberNode.number!, op: op!)
                        opNode.removeFromParent()
                        opNode.neighbor?.removeFromParent()
                    }
                }
            }else{
                if contact.bodyA.node!.parent! is OperatorCircle{
                    opBody = contact.bodyA
                    
                    if contact.bodyB.node!.parent! is NumberCircle{
                        numberBody = contact.bodyB
                        
                        let numberNode = numberBody.node!.parent! as NumberCircle
                        let opNode     = opBody.node!.parent! as OperatorCircle
                        
                        if numberNode.hasNeighbor() == false && opNode.hasNeighbor() == false{
                            var myJoint = SKPhysicsJointPin.jointWithBodyA(numberBody, bodyB: opBody,
                                anchor: numberBody.node!.position)
                            
                            numberNode.setNeighbor(opNode)
                            opNode.setNeighbor(numberNode)
                            
                            myJoint.frictionTorque = 1.0
                            self.physicsWorld.addJoint(myJoint)
                            currentJoint = myJoint
                        }else{
                            let lhs = (opNode.neighbor as NumberCircle).number
                            let op  = opNode.op
                            
                            numberNode.setResultLabel(lhs!, rhs: numberNode.number!, op: op!)
                            opNode.removeFromParent()
                            opNode.neighbor?.removeFromParent()
                        }
                    }
                }
            }
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {}
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* touch has begun */
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        let touchedNode = nodeAtPoint(touchLocation).parent

        /*Make the touched node do something*/
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        var touchedNode = nodeAtPoint(touchLocation)
        
        if touchedNode is SKLabelNode {
            touchedNode = touchedNode.parent!
        }
        
        if touchedNode is SKScene {
            // can't move the scene, finger probably fell off a circle?
            return
        }else if touchedNode.parent! is NumberCircle{
            //Only number circles can be moved
            touchedNode.position.x = touchLocation.x
            touchedNode.position.y = touchLocation.y
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        let touch = touches.anyObject() as UITouch
        let touchLocation = touch.locationInNode(self)
        var touchedNode = nodeAtPoint(touchLocation)
        
        if touchedNode is SKLabelNode {
            touchedNode = touchedNode.parent!.parent!
            
        }
        
        //Break the node joint if touch is released
        breakJoint()
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* called before each frame is rendered */
    }

    func breakJoint(){
        if currentJoint != nil{
            self.physicsWorld.removeJoint(currentJoint!)
            currentJoint = nil
        }
    }
}
