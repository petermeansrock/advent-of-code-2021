import AdventOfCode
import XCTest

@testable import Library

class TrajectoryTests: XCTestCase {
    private static let inputRegex = try! NSRegularExpression(
        pattern: #"^target area: x=(-?\d+)..(-?\d+), y=(-?\d+)..(-?\d+)$"#
    )

    func testCannonAimWithSampleInput() {
        // Arrange
        let input = parseInput("target area: x=20..30, y=-10..-5")
        let cannon = Cannon()

        // Act
        let stats = cannon.aim(targetX: input.xRange, targetY: input.yRange)

        // Assert
        XCTAssertEqual(stats.maxHeight, 45)
        XCTAssertEqual(stats.velocityCandidateCount, 112)
    }

    func testCannonAimWithDay17Input() {
        // Arrange
        let input = parseInput(InputFile(bundle: Bundle.module, day: 17).loadLines()[0])
        let cannon = Cannon()

        // Act
        let stats = cannon.aim(targetX: input.xRange, targetY: input.yRange)

        // Assert
        XCTAssertEqual(stats.maxHeight, 13041)
        XCTAssertEqual(stats.velocityCandidateCount, 1031)
    }

    func parseInput(_ input: String) -> (xRange: ClosedRange<Int>, yRange: ClosedRange<Int>) {
        let match = TrajectoryTests.inputRegex
            .firstMatch(in: input, range: NSRange(input.startIndex..., in: input))!

        let xMin = Int(input[Range(match.range(at: 1), in: input)!])!
        let xMax = Int(input[Range(match.range(at: 2), in: input)!])!
        let yMin = Int(input[Range(match.range(at: 3), in: input)!])!
        let yMax = Int(input[Range(match.range(at: 4), in: input)!])!

        return (xRange: xMin...xMax, yRange: yMin...yMax)
    }
}
