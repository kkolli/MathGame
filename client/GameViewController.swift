//
//  GameViewController.swift
//  Speedy
//
//  Created by Tyler Levine on 1/27/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//
// NS Timer Reference- http://ios-blog.co.uk/tutorials/swift-nstimer-tutorial-lets-create-a-counter-application/


import SpriteKit
import UIKit

class GameViewController : UIViewController {
    
    @IBOutlet weak var GameTimerLabel: UILabel!
    @IBOutlet weak var GameScoreLabel: UILabel!
    @IBOutlet weak var GameTargetNumLabel: UILabel!
    var timer = NSTimer()
    var counter = 0
    var game_max_time = 60 // TODO - modify this somehow later
    var score = 0
    var targetNumber: Int?
    var scene: GameScene!
    let TIME_DEBUG = false
    
    override func viewDidLoad() {
        super.viewDidLoad();
        println("In Game View controller")
        
        // start the counter to go!
        GameScoreLabel.text = String(score)
        GameTimerLabel.text = convertIntToTime(counter)
        startTimer()
        
        scene = GameScene(size: view.frame.size)
        // Configure the view.
        let skView = self.view as SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        //skView.showsPhysics = true
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = false
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        scene.scoreHandler = handleMerge
            
        skView.presentScene(scene)
    }
    
    // BEGIN -- SCORE HANDLING
    /*
    takes in the target node that everything gets merged into, 
    two operands and an operatorCircle
    
    Whether or not this new node is the designated target number should be handled elsewhere
    */
    func handleMerge(op1: Int, op2: Int, oper: Operator) -> (Int, Bool){
        var result: Int
        
        switch oper{
        case .PLUS: result = op1 + op2
        case .MINUS: result = op1 - op2
        case .MULTIPLY: result = op1 * op2
        case .DIVIDE: result = op1 / op2
        }
        
        if result == targetNumber{
            score += result * ScoreMultiplier.getMultiplierFactor(oper)
            updateScore()
            updateTargetNumber()
        }
        
        let removeNode = (result == targetNumber || result == 0)
        
        return (result, removeNode)
    }
    
    func updateScore(){
        GameScoreLabel.text = String(score)
    }
    
    func updateTargetNumber(){
        GameTargetNumLabel.text = String(targetNumber!)
    }
    
    func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("onTick"), userInfo: nil, repeats: true)
    }
    
    func onTick() {
        updateCounter()
        scene.upgradeCircle()
    }
    
    func updateCounter() {
        counter++;
        if (game_max_time - counter < 0) {
            // Stop the timer completely
            GameTimerLabel.text = "Done"
            stopPauseTimer()
        } else {
            GameTimerLabel.text = convertIntToTime(counter)
        }
    }
    
    func stopPauseTimer() {
        timer.invalidate()
    }
    
    /*
    this takes something like 0 and turns it into 00:00
    and if it takes something like 60 -> 01:00
    if it takes 170 -> 02:10
    */
    func convertIntToTime(secondsPassed: Int) -> String {
        var count = game_max_time - secondsPassed
        
        let seconds_per_minute = 60
        var minutes = count / seconds_per_minute
        var seconds = count % seconds_per_minute
        
        var minute_display = "", second_display = ""
        
        if (minutes >= 10) {
            minute_display = String(minutes)
        } else {
            minute_display = "0" + String(minutes)
        }
        
        if (seconds >= 10) {
            second_display = String(seconds)
        } else {
            second_display = "0" + String(seconds)
        }
        
        if (TIME_DEBUG) {
            println("seconds: \(seconds)" + " second display : " + second_display)
            println("displaying: " + minute_display + ":" + second_display)
        }
        return minute_display + ":" + second_display
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        println("preparing for segue!!")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
}
