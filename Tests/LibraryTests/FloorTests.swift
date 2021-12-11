import AdventOfCode
import XCTest

@testable import Library

class FloorTests: XCTestCase {
    func testFindBasinsWithSampleInput() {
        // Arrange
        let grid = """
            2199943210
            3987894921
            9856789892
            8767896789
            9899965678
            """.components(separatedBy: .newlines)
            .map { Array($0).map { $0.wholeNumberValue! } }
        let oceanFloor = OceanFloor(grid: grid)

        // Act
        let basins = oceanFloor.findBasins()

        // Assert
        let riskLevelSum =
            basins
            .map { $0.riskLevel }
            .reduce(0, +)
        let productOfLargestBasinSizes =
            basins
            .map { $0.size }
            .sorted(by: >)
            .prefix(3)
            .reduce(1, *)
        XCTAssertEqual(riskLevelSum, 15)
        XCTAssertEqual(productOfLargestBasinSizes, 1134)
    }

    func testFindBasinsWithDay9Input() {
        // Arrange
        let grid = InputFile(bundle: Bundle.module, day: 9).loadLines()
            .filter { $0.count > 0 }
            .map { Array($0).map { $0.wholeNumberValue! } }
        let oceanFloor = OceanFloor(grid: grid)

        // Act
        let basins = oceanFloor.findBasins()

        // Assert
        let riskLevelSum =
            basins
            .map { $0.riskLevel }
            .reduce(0, +)
        let productOfLargestBasinSizes =
            basins
            .map { $0.size }
            .sorted(by: >)
            .prefix(3)
            .reduce(1, *)
        XCTAssertEqual(riskLevelSum, 465)
        XCTAssertEqual(productOfLargestBasinSizes, 1_269_555)
    }
}
