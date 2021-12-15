import AdventOfCode
import XCTest

@testable import Library

class ChitonTests: XCTestCase {
    func testNoMultiplierWithSnakingSolution() {
        // Arrange
        let grid = """
            119999
            919111
            911191
            999991
            """.components(separatedBy: .newlines)
            .map { Array($0).map { $0.wholeNumberValue! } }
        let graph = WeightedGraph(grid: grid)

        // Act
        let totalRisk = graph.findPathWithLowestRisk()

        // Assert
        XCTAssertEqual(totalRisk, 10)
    }

    func testNoMultiplierWithSampleInput() {
        // Arrange
        let grid = """
            1163751742
            1381373672
            2136511328
            3694931569
            7463417111
            1319128137
            1359912421
            3125421639
            1293138521
            2311944581
            """.components(separatedBy: .newlines)
            .map { Array($0).map { $0.wholeNumberValue! } }
        let graph = WeightedGraph(grid: grid)

        // Act
        let totalRisk = graph.findPathWithLowestRisk()

        // Assert
        XCTAssertEqual(totalRisk, 40)
    }

    func testNoMultiplierWithDay15Input() {
        // Arrange
        let grid = InputFile(bundle: Bundle.module, day: 15).loadLines()
            .filter { $0.count > 0 }
            .map { Array($0).map { $0.wholeNumberValue! } }
        let graph = WeightedGraph(grid: grid)

        // Act
        let totalRisk = graph.findPathWithLowestRisk()

        // Assert
        XCTAssertEqual(totalRisk, 429)
    }

    func test5xMultiplierWithSampleInput() {
        // Arrange
        let grid = """
            1163751742
            1381373672
            2136511328
            3694931569
            7463417111
            1319128137
            1359912421
            3125421639
            1293138521
            2311944581
            """.components(separatedBy: .newlines)
            .map { Array($0).map { $0.wholeNumberValue! } }
        let graph = WeightedGraph(grid: grid, multiplier: 5)

        // Act
        let totalRisk = graph.findPathWithLowestRisk()

        // Assert
        XCTAssertEqual(totalRisk, 315)
    }

    func test5xMultiplierWithDay15Input() {
        // Arrange
        let grid = InputFile(bundle: Bundle.module, day: 15).loadLines()
            .filter { $0.count > 0 }
            .map { Array($0).map { $0.wholeNumberValue! } }
        let graph = WeightedGraph(grid: grid, multiplier: 5)

        // Act
        let totalRisk = graph.findPathWithLowestRisk()

        // Assert
        XCTAssertEqual(totalRisk, 2844)
    }
}
