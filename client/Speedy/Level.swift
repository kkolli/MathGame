//
//  Level.swift
//  Speedy
//
//  Created by Edward Chiou on 2/24/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import Foundation

class Level{
    
    var randomNumberGenerator: RandomNumbers
    var randomOpGenerator: RandomOperators
    
    init(){
        randomNumberGenerator = RandomNumbers(difficulty: 5)
        randomOpGenerator     = RandomOperators(difficulty: 5)
    }
}