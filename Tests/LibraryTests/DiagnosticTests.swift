import AdventOfCode
import XCTest

@testable import Library

class DiagnosticTests: XCTestCase {
    func testSampleInput() throws {
        // Arrange
        let lines = [
            "00100",
            "11110",
            "10110",
            "10111",
            "10101",
            "01111",
            "00111",
            "11100",
            "10000",
            "11001",
            "00010",
            "01010",
        ]

        // Act
        let report = DiagnosticReport(lines: lines)

        // Assert
        XCTAssertEqual(report.powerConsumption, 198)
        XCTAssertEqual(report.lifeSupportRate, 230)
    }

    func testDay3Input() throws {
        // Arrange
        let lines = InputFile(bundle: Bundle.module, day: 3).loadLines().filter { $0.count > 0 }

        // Act
        let report = DiagnosticReport(lines: lines)

        // Assert
        XCTAssertEqual(report.powerConsumption, 3_882_564)
        XCTAssertEqual(report.lifeSupportRate, 3_385_170)
    }
}
