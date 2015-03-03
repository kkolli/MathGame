//
//  NumberCircle.swift
//  Speedy
//
//  Created by Tyler Levine on 2/5/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//
import SpriteKit

class NumberCircle : GameCircle {
    var number: Int?
    var score: Int?
    
    let nodeFont = "AmericanTypewriter-Bold"
    var text: SKLabelNode?
    var scoreMultiplier = 1
    var upgrade: UpgradeOptions = UpgradeOptions.None
    
    convenience init(num: Int)    {
        self.init()
        setNumber(num)
        initScore()
    }
    
    func initScore() {
        score = 0
    }
    
    func setScore(num: Int) {
        score = num
    }
    func getScore() -> Int {
        return score!
    }
    
    func setNumber(num: Int) {
        number = num
        setLabel()
    }
    
    func setScoreMultiplier(multiplier: Int){
        scoreMultiplier = multiplier
    }
    
    func setUpgrade(upgrade: UpgradeOptions){
        self.upgrade = upgrade
    }
    
    func setFillColor(color: UIColor){
        shapeNode!.fillColor = color
    }
    
    func resetFillColor(){
        shapeNode!.fillColor = UIColor.redColor()
    }
    
    func setLabel(){
        if text != nil{
            text!.text = "\(number!)"
        }else{
            text = SKLabelNode(text: "\(number!)")
            text!.fontSize = nodeTextFontSize
            text!.fontName = nodeFont
            text!.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
            text!.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
            shapeNode!.addChild(text!)
        }
       
    }
}
