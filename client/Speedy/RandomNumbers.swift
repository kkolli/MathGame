//
//  RandomNumbers.swift
//  Speedy
//
//  Created by Edward Chiou on 1/31/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import Foundation

class RandomNumbers {
    var target: Int?
    var difficulty: Int
    var weights: [Double]
    var weightedList: [Int]
    
    //Bounds that determine how low/high the target value can be
    let minTarget = 10
    let targetRange = 10
    let maxRange = 95
    
    init(){
        target = 10
        difficulty = 1
        weights = []
        weightedList = []
    }
    
    //Use this constructor
    init(difficulty: Int){
        self.difficulty = difficulty
        self.weights = []
        self.weightedList = []
        
        self.weights = generateWeights()
        self.weightedList = generateWeightedList(weights)
    }
    
    /*
     * We want 1-10 to appear more than 11-100, so 1-10 is assigned a 
     * higher probability.
     */
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
    
    /*
     * Generates weighted number list to provide the RNG that we want.
     * List contains 1000 numbers. If probability of a number is x, then
     * it will appear x * 1000 times.
     */
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
    
    /*
     * Call this to generate a random number.
     */
    func generateNumber() -> Int{
        var randomNumber = Int(arc4random_uniform(UInt32(1000)))
        
        while weightedList[randomNumber] == target{
            randomNumber = Int(arc4random_uniform(UInt32(1000)))
        }
        
        return weightedList[randomNumber]
    }
    
    func generateTarget() -> Int{
        let range = difficulty * targetRange > maxRange ? maxRange : difficulty * targetRange
        return Int(arc4random_uniform(UInt32(maxRange))) + minTarget
    }
    
    func generateTarget(numbers: [Int]) -> Int{
        var generatedTarget = generateTarget()
        var filteredNumbers = numbers.filter{$0 == generatedTarget}
        
        while filteredNumbers.count > 0{
            generatedTarget = generateTarget()
            filteredNumbers = numbers.filter{$0 == generatedTarget}
        }
        
        target = generatedTarget
        return generatedTarget
    }
}
