//
//  GameScene.swift
//  Speedy
//
//  Created by Tyler Levine on 1/27/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import SpriteKit

class GameScene : SKScene {
    let canvasHeight: UInt32 = 800  //CHANGE MAGIC NUMBER
    let canvasWidth:UInt32 = 800   //CHANGE MAGIC NUMBER
    
    var contentCreated = false
    
    enum InvaderType {
        case A
        case B
        case C
    }
    
    let kInvaderSize = CGSize(width:24, height:16)
    let kInvaderGridSpacing = CGSize(width:12, height:12)
    let kInvaderRowCount = 6
    let kInvaderColCount = 6
    
    let kInvaderName = "invader"
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        drawSpeedy()
        if (!contentCreated) {
            createContent()
            contentCreated = true
            setupInvaders()
        }
    }
    
    func createContent() {
        
        let invader = SKSpriteNode()
        invader.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(invader)
        self.backgroundColor = SKColor.lightGrayColor()
    }
    
    func drawSpeedy(){
        //Draw Column1
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Number!";
        myLabel.fontSize = 35;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        self.addChild(myLabel)
        
        
    }
    
    func makeInvaderOfType(invaderType: InvaderType) -> (SKNode) {
        
        // 1
        var invaderColor: SKColor
        
        switch(invaderType) {
        case .A:
            invaderColor = SKColor.redColor()
        case .B:
            invaderColor = SKColor.greenColor()
        case .C:
            invaderColor = SKColor.blueColor()
        default:
            invaderColor = SKColor.blueColor()
        }
        
        // 2
        let invader = SKSpriteNode(color: invaderColor, size: kInvaderSize)
        invader.name = kInvaderName
        
        return invader
    }
    
    func setupInvaders() {
        
        // 1
        let baseOrigin = CGPoint(x:size.width / 3, y:180)
        for var row = 1; row <= kInvaderRowCount; row++ {
            
            var invaderType: InvaderType
            if row % 3 == 0 {
                invaderType = .A
            } else if row % 3 == 1 {
                invaderType = .B
            } else {
                invaderType = .C
            }
            
            // 3
            let invaderPositionY = CGFloat(row) * (kInvaderSize.height * 2) + baseOrigin.y
            var invaderPosition = CGPoint(x:baseOrigin.x, y:invaderPositionY)
            
            // 4
            for var col = 1; col <= kInvaderColCount; col++ {
                
                var invader = makeInvaderOfType(invaderType)
                invader.position = invaderPosition
                addChild(invader)
                
                invaderPosition = CGPoint(x: invaderPosition.x + kInvaderSize.width + kInvaderGridSpacing.width, y: invaderPositionY)
            }
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* touch has begun */
        
        let shape = SKShapeNode(circleOfRadius: 20)
        shape.strokeColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.5)
        shape.lineWidth = 4
        let text = SKLabelNode(text: String(3))
        // we set the font
        text.fontSize = 6.0
        // we nest the text label in our ball
        shape.addChild(text)
        
        // we set initial random positions
        shape.position = CGPoint (x: CGFloat(arc4random()%(canvasWidth)), y: CGFloat(arc4random()%(canvasHeight)))
        // we add each circle to the display list
        self.addChild(shape)
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* called before each frame is rendered */
    }
}
