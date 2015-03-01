//
//  RandomOperators.swift
//  Speedy
//
//  Created by Edward Chiou on 2/14/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import Foundation

class RandomOperators{
    var difficulty: Int
    var weights: [Operator: Double] = [:]
    var weightedList: [Operator] = []
    
    let numOfOperators = 4
    
    //Hardcoded probability values, will need to develop a way to scale
    //difficulty dynamically with difficulty
    let plusProb = 0.3
    let minusProb = 0.3
    let multiplyProb = 0.2
    let divideProb = 0.2
    
    init(){
        self.difficulty = 1
    }
    
    init(difficulty: Int){
        self.difficulty = difficulty
        self.weights = generateWeights()
        self.weightedList = generateWeightedList()
    }
    
    //This is also hardcoded
    func generateWeights() -> [Operator: Double]{
        var weights: [Operator: Double] = [:]
        
        weights[Operator.PLUS] = plusProb
        weights[Operator.MINUS] = minusProb
        weights[Operator.MULTIPLY] = multiplyProb
        weights[Operator.DIVIDE] = divideProb
        
        return weights
    }
    
    func generateWeightedList() -> [Operator]{
        var weightedList: [Operator] = []
        
        for (index, weight) in weights{
            var multiples = Int(weight * 1000)
            
            for(var i = 0; i < multiples; i++){
                weightedList.append(index)
            }
        }
        
        return weightedList
    }
    
    func generateOperator() -> Operator{
        var randomNumber = Int(arc4random_uniform(UInt32(1000)))
        
        return weightedList[randomNumber]
    }
}