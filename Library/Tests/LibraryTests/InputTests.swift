//
//  InputTests.swift
//  
//
//  Created by Peter VanLund on 11/30/21.
//

import XCTest
@testable import Library

class InputTests: XCTestCase {
    func testInputFileLoadLines() throws {
        // Arrange
        let inputFile = InputFile(day: 1)
        
        // Act
        let lines = inputFile.loadLines()
        
        // Assert
        XCTAssertEqual(lines[0], "1891")
    }
}
