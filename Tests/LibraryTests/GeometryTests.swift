import AdventOfCode
import XCTest

@testable import Library

class PlotTests: XCTestCase {
    func testPlotWithDay5InputIgnoringDiagonals() throws {
        // Arrange
        let lines = InputFile(bundle: Bundle.module, day: 5).loadLines().filter { $0.count > 0 }
        let segments = lines.map { try! LineSegment(in: $0) }.filter { $0.orientation != .diagonal }
        let coordinates = segments.flatMap { [$0.start, $0.end] }
        let maxX = coordinates.map { $0.x }.max()!
        let maxY = coordinates.map { $0.y }.max()!

        // Act
        var plot = Plot(maxX: maxX, maxY: maxY)
        for segment in segments {
            plot.plot(line: segment)
        }

        // Assert
        let overlappingCount = plot.grid.flatMap { $0 }.filter { $0 >= 2 }.count
        XCTAssertEqual(overlappingCount, 7269)
    }

    func testPlotWithDay5InputConsideringDiagonals() throws {
        // Arrange
        let lines = InputFile(bundle: Bundle.module, day: 5).loadLines().filter { $0.count > 0 }
        let segments = lines.map { try! LineSegment(in: $0) }
        let coordinates = segments.flatMap { [$0.start, $0.end] }
        let maxX = coordinates.map { $0.x }.max()!
        let maxY = coordinates.map { $0.y }.max()!

        // Act
        var plot = Plot(maxX: maxX, maxY: maxY)
        for segment in segments {
            plot.plot(line: segment)
        }

        // Assert
        let overlappingCount = plot.grid.flatMap { $0 }.filter { $0 >= 2 }.count
        XCTAssertEqual(overlappingCount, 21140)
    }
}
