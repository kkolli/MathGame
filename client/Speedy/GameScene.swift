//
//  GameScene.swift
//  Speedy
//
//  Created by Tyler Levine on 1/27/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import SpriteKit

class GameScene : SKScene {
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        drawSpeedy()
    }
    
    func drawSpeedy(){
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Speedy!";
        myLabel.fontSize = 35;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        self.addChild(myLabel)

    }
    
    func drawCircles(){
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* touch has begun */
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* called before each frame is rendered */
    }
}
