import AdventOfCode
import XCTest

@testable import Library

class CucumberTests: XCTestCase {
    func testWithSampleInput() {
        // Arrange
        let lines = """
            v...>>.vv>
            .vv>>.vv..
            >>.>v>...v
            >>v>>.>.v.
            v>v.vv.v..
            >.>>..v...
            .vv..>.>v.
            v.v..>>v.v
            ....v..v.>
            """.components(separatedBy: .newlines)
        let cucumbers = Cucumbers(lines: lines)

        // Act
        let stepCount = cucumbers.simulate()

        // Assert
        XCTAssertEqual(stepCount, 58)
    }

    func testWithDay25Input() {
        // Arrange
        let lines = InputFile(bundle: Bundle.module, day: 25).loadLines().filter { $0.count > 0 }
        let cucumbers = Cucumbers(lines: lines)

        // Act
        let stepCount = cucumbers.simulate()

        // Assert
        XCTAssertEqual(stepCount, 337)
    }
}
