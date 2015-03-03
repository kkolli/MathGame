//
//  RandomNumbersTest.swift
//  Speedy
//
//  Created by Edward Chiou on 1/31/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import UIKit
import XCTest

class RandomNumbersTest: XCTestCase {

    let randomDefault = RandomNumbers()
    let random        = RandomNumbers(difficulty: 5)
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGenerateTarget(){
        for(var i = 0; i < 100; ++i){
            var randomTarget = random.generateTarget()
            XCTAssertGreaterThanOrEqual(random.minTarget + random.maxRange, randomTarget, "Generated target is greater than max value allowed")
            XCTAssertLessThanOrEqual(0, randomTarget, "Generated target is negative")
        }
    }
    
    func testGenerateNumber(){
        for var i = 0; i < 100; ++i{
            var randomNumber = random.generateNumber()
            XCTAssertGreaterThanOrEqual(99, randomNumber, "generateNumber result is above bounds")
            XCTAssertLessThan(0, randomNumber, "generateNumber result is below bounds")
        }
    }

}
