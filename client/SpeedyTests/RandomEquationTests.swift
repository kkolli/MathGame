//
//  RandomEquationTests.swift
//  Speedy
//
//  Created by Edward Chiou on 1/24/15.
//  Copyright (c) 2015 Krishna Kolli. All rights reserved.
//

import UIKit
import XCTest

class RandomEquationTests: XCTestCase {
    let randomDefault = RandomEquation()
    let random        = RandomEquation(difficulty: 5)

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitDefault(){
        XCTAssertEqual(10, randomDefault.target, "Default target not set to 1")
        XCTAssertEqual(1, randomDefault.difficulty, "Default difficutly not set to 10")
    }
    
    func testInit(){
        XCTAssertGreaterThanOrEqual(30, random.target, "Generated target exceeds max target possible")
        XCTAssertLessThanOrEqual(random.minTarget, random.target, "Generated target is less than min target possible")
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
