//
//  RandomEquation.swift
//  Speedy
//
//  Created by Edward Chiou on 1/22/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import Foundation

class RandomEquation {
    var target: Int
    var difficulty: Int
    
    //Bounds that determine how low/high the target value can be
    let minTarget = 5
    let targetRange = 5
    let maxRange = 25
    
    init(){
        target = 10
        difficulty = 1
    }
    
    init(difficulty: Int){
        self.difficulty = difficulty
        
        let range = difficulty * targetRange > maxRange ? maxRange : difficulty * targetRange
        self.target = Int(arc4random_uniform(UInt32(range))) + minTarget
    }
    
    func generateNumber() -> Int{
        var randomNumber = Int(arc4random_uniform(UInt32(99))) + 1
        
        return randomNumber
    }
    
    
}