//
//  RandomNumbers.swift
//  Speedy
//
//  Created by Edward Chiou on 1/31/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import Foundation

import Foundation

class RandomNumbers {
    var target: Int
    var difficulty: Int
    var weights: [Double]
    var weightedList: [Int]
    
    //Bounds that determine how low/high the target value can be
    let minTarget = 5
    let targetRange = 5
    let maxRange = 25
    
    init(){
        target = 10
        difficulty = 1
        weights = []
        weightedList = []
    }
    
    init(difficulty: Int){
        self.difficulty = difficulty
        self.target = 0
        self.weights = []
        self.weightedList = []
        
        self.target = generateTarget()
        self.weights = generateWeights()
        self.weightedList = generateWeightedList(weights)
    }
    
    func generateGeometricDist() -> Int{
        let p = 0.25
        var random = Double(arc4random() / UInt32.max)
        var denom = log(1.0 - p)
        var exponentialDist = log(random) / denom
        
        return Int(floor(exponentialDist))
    }
    
    func generateWeights() -> [Double]{
        let primaryProbability = 0.055
        let secondaryProbability = 0.005
        
        var weights: [Double] = []
        var remainingProb = 1.0
        
        for(var i = 0; i < 100; ++i){
            if(i < 10){
                weights.append(primaryProbability)
                remainingProb -= primaryProbability
            }else{
                weights.append(secondaryProbability)
                remainingProb -= secondaryProbability
            }
        }
        
        return weights
    }
    
    func generateWeightedList(weights: [Double]) -> [Int]{
        var weightedList: [Int] = []
        
        for (index, weight) in enumerate(weights) {
            var multiples = Int(weight * 1000)
            
            for(var j = 0; j < multiples; ++j){
                weightedList.append(index + 1)
            }
        }
        
        return weightedList
    }
    
    func generateNumber() -> Int{
        var randomNumber = Int(arc4random_uniform(UInt32(1000)))
        
        return weightedList[randomNumber]
    }
    
    func generateTarget() -> Int{
        let range = difficulty * targetRange > maxRange ? maxRange : difficulty * targetRange
        return Int(arc4random_uniform(UInt32(range))) + minTarget
    }
}