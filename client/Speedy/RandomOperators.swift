//
//  RandomOperators.swift
//  Speedy
//
//  Created by Edward Chiou on 2/14/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import Foundation

class RandomOperators{
    var weights: [Operator: Double] = [:]
    var weightedList: [Operator] = []
    var prevOp: Operator?
    
    let numOfOperators = 4
    
    //Hardcoded probability values, will need to develop a way to scale
    //difficulty dynamically with difficulty
    let plusProb = 0.25
    let minusProb = 0.25
    let multiplyProb = 0.25
    let divideProb = 0.25
    
    init(){
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
        var randomOp = weightedList[randomNumber]
        
        while prevOp != nil && randomOp == prevOp{
            randomNumber = Int(arc4random_uniform(UInt32(1000)))
            randomOp = weightedList[randomNumber]
        }
        
        prevOp = randomOp
        return randomOp
    }
}