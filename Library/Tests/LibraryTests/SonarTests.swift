//
//  SonarTests.swift
//  
//
//  Created by Peter VanLund on 11/30/21.
//

import XCTest
@testable import Library

class SonarTests: XCTestCase {
    func testSampleInput() throws {
        // Arrange
        let sonar = Sonar()
        let depths = [
            199,
            200,
            208,
            210,
            200,
            207,
            240,
            269,
            260,
            263,
        ]
        
        // Act
        let count = sonar.sweep(depths: depths)
        
        // Assert
        XCTAssertEqual(count, 7)
    }
    
    func testDay1Input() throws {
        // Arrange
        let sonar = Sonar()
        let depths = InputFile(day: 1).loadLines().compactMap{ Int($0) }
        
        // Act
        let count = sonar.sweep(depths: depths)
        
        // Assert
        XCTAssertEqual(count, 1477)
    }
}
