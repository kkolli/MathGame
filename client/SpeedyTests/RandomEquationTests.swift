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
    let random        = RandomEquation(difficulty: 2)

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testInitDefault(){
        XCTAssertEqual(10, randomDefault.target, "Default target not set to 1")
        XCTAssertEqual(1, randomDefault.difficulty, "Default difficutly not set to 10")
    }
    
    func testInit(){
        XCTAssertGreaterThanOrEqual(30, random.target, "Generated target exceeds max target possible")
        XCTAssertLessThanOrEqual(random.minTarget, random.target, "Generated target is less than min target possible")
    }
    
    func testGenerateNumber(){
        for var i = 0; i < 12; ++i{
            var randomNumber = randomDefault.generateNumber()
            XCTAssertGreaterThanOrEqual(99, randomNumber, "generateNumber result is above bounds")
            XCTAssertLessThan(0, randomNumber, "generateNumber result is below bounds")
        }
    }

}
