//
//  BoardHeader.swift
//  Speedy
//
//  Created by Tyler Levine on 3/6/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import Foundation
import SpriteKit

struct BoardHeaderProperties {
    static let backgroundColor = UIColor.darkGrayColor()
}

private struct BoardHeaderConstraints {
    static let leftColWidth: CGFloat = 0.25
    static let centerColWidth: CGFloat = 0.50
    static let rightColWidth: CGFloat = 0.25
    static let timerValueBaseline: CGFloat = 0.15
    static let sideLabelBaseline: CGFloat = 0.40
    static let sideValueBaseline: CGFloat = 0.10
}

class BoardHeader : SKSpriteNode {
    
    private let timerValue = SKLabelNode()
    private let scoreLabel = SKLabelNode()
    private let scoreValue = SKLabelNode()
    private let targetLabel = SKLabelNode()
    private let targetValue = SKLabelNode()
    
    // these may never be used, so declare them as lazy
    private lazy var opponentScoreLabel = SKLabelNode()
    private lazy var opponentScoreValue = SKLabelNode()
    
    private var time: Int?
    
    var target: Int {
        get {
            return targetValue.text.toInt()!
        }
        set {
            targetValue.text = "\(newValue)"
        }
    }
    
    var score: Int {
        get {
            return scoreValue.text.toInt()!
        }
        set {
            scoreValue.text = "\(newValue)"
        }
    }
    
    var timer: Int {
        get {
            return self.time!
        }
        set {
            self.time = newValue
            timerValue.text = convertIntToTimeString(newValue)
        }
    }
    
    var opponentName: String {
        get {
            return opponentScoreLabel.text
        }
        set {
            opponentScoreLabel.text = newValue
        }
    }
    
    var opponentScore: Int {
        get {
            return opponentScoreValue.text.toInt()!
        }
        set {
            opponentScoreValue.text = "\(newValue)"
        }
    }
    
    private convenience init(mode: BoardMode, frame: CGRect, targetNum: Int, time: Int) {
        self.init(color: BoardHeaderProperties.backgroundColor, size: frame.size)
        timer = time
        score = 0
        target = targetNum
        targetLabel.text = "Target"
        self.anchorPoint = CGPointMake(0, 0)
        self.position = frame.origin
    }
    
    // single player constructor
    convenience init(frame: CGRect, targetNum: Int, time: Int) {
        self.init(mode: .SINGLE, frame: frame, targetNum: targetNum, time: time)
        scoreLabel.text = "Score"
        addChildrenForSinglePlayer(frame)
    }
    
    // multiplayer constructor
    convenience init(frame: CGRect, targetNum: Int, time: Int, opponentName: String) {
        self.init(mode: .MULTI, frame: frame, targetNum: targetNum, time: time)
        self.opponentName = opponentName
        opponentScore = 0
        addChildrenForMultiPlayer(frame)
    }
    
/*
    private let timerValue = SKLabelNode()
    private let scoreLabel = SKLabelNode()
    private let scoreValue = SKLabelNode()
    private let targetLabel = SKLabelNode()
    private let targetValue = SKLabelNode()
    
    // these may never be used, so declare them as lazy
    private lazy var opponentScoreLabel = SKLabelNode()
    private lazy var opponentScoreValue = SKLabelNode()
*/
    func addChildrenForSinglePlayer(frame: CGRect) {
        let centerColStart = frame.width * BoardHeaderConstraints.leftColWidth
        let centerColEnd = centerColStart + frame.width * BoardHeaderConstraints.centerColWidth
        let centerColMid = centerColStart + (centerColEnd - centerColStart) / 2
        let leftColMid = (frame.width * BoardHeaderConstraints.leftColWidth) / 2
        let rightColMid =  centerColEnd + (frame.width - frame.width * (1 - BoardHeaderConstraints.rightColWidth)) / 2
        
        // setup timer value
        let timerLabelX = centerColMid
        let timerLabelY = frame.height * BoardHeaderConstraints.timerValueBaseline
        timerValue.position = CGPointMake(timerLabelX, timerLabelY)
        timerValue.fontSize = 60
        
        self.addChild(timerValue)
        
        // setup score label
        let scoreLabelX = leftColMid
        let scoreLabelY = frame.height * BoardHeaderConstraints.sideLabelBaseline
        scoreLabel.position = CGPointMake(scoreLabelX, scoreLabelY)
        scoreLabel.fontSize = 24
        
        self.addChild(scoreLabel)
        
        // setup score value
        let scoreValueX = leftColMid
        let scoreValueY = frame.height * BoardHeaderConstraints.sideValueBaseline
        scoreValue.position = CGPointMake(scoreValueX, scoreValueY)
        scoreValue.fontSize = 24
        
        self.addChild(scoreValue)
        
        // setup target label
        let targetLabelX = rightColMid
        let targetLabelY = scoreLabelY
        targetLabel.position = CGPointMake(targetLabelX, targetLabelY)
        targetLabel.fontSize = 24
        
        self.addChild(targetLabel)
        
        // setup target value
        let targetValueX = rightColMid
        let targetValueY = scoreValueY
        targetValue.position = CGPointMake(targetValueX, targetValueY)
        targetValue.fontSize = 24
        
        self.addChild(targetValue)
        
    }
    
    func addChildrenForMultiPlayer(frame: CGRect) {
        
    }
    
    func convertIntToTimeString(time: Int) -> String {
        let minutes = time / 600
        let seconds = (time % 600) / 10
        let tenths = time % 10
        
        if minutes == 0 {
            return "\(seconds).\(tenths)"
        }
        
        if seconds < 10 {
            return "\(minutes):0\(seconds).\(tenths)"
        }
        
        return "\(minutes):\(seconds).\(tenths)"
    }
    

}