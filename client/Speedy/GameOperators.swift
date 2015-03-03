//
//  GameOperators.swift
//  Speedy
//
//  Created by Edward Chiou on 2/14/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import Foundation
import SpriteKit

enum Operator{
    case PLUS
    case MINUS
    case MULTIPLY
    case DIVIDE
}

enum UpgradeOptions: Int{
    case None = 0
    case ScoreIncrease = 1
    case TimeIncrease = 2
    
    func upgradeColor() -> UIColor{
        switch self{
        case ScoreIncrease:
            return UIColor.greenColor()
        case TimeIncrease:
            return UIColor.blueColor()
        default:
            return UIColor.redColor()
        }
    }
}