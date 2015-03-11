//
//  BoardHeaderController.swift
//  Speedy
//
//  Created by Tyler Levine on 3/6/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import Foundation
import SpriteKit

class BoardHeaderController {
    let scene: GameScene
    let frame: CGRect
    let view: BoardHeader
    let board: BoardController

    init(mode: BoardMode, scene s: GameScene, frame f: CGRect, board b: BoardController) {
        scene = s
        frame = f
        board = b
        
        if mode == .SINGLE {
            view = BoardHeader(frame: f, targetNum: b.targetNumber!, time: 600)
            s.addChild(view)
        } else {
            view = BoardHeader(frame: f, targetNum: b.targetNumber!, time: 600, opponentName: "Bob")
            s.addChild(view)
        }
    }
    
    func setTargetNumber(num: Int) {
        view.target = num
    }
    
    func setTimeRemaining(time: Int) {
        view.timer = time
    }
    
    func setScore(currentScore: Int) {
        view.score = currentScore
    }
    
    func setOpponentName(opponent: String) {
        view.opponentName = opponent
    }
    
    func setOpponentScore(opponentScore: Int) {
        view.opponentScore = opponentScore
    }
}