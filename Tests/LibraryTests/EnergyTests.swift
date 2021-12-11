import AdventOfCode
import XCTest

@testable import Library

class EnergyTests: XCTestCase {
    func testSimulate100StepsWithSampleInput() {
        // Arrange
        let lines = """
            5483143223
            2745854711
            5264556173
            6141336146
            6357385478
            4167524645
            2176841721
            6882881134
            4846848554
            5283751526
            """
        let grid = lines.components(separatedBy: .newlines)
            .map { Array($0).map { $0.wholeNumberValue! } }
        let simulator = EnergySimulator(grid: grid)

        // Act
        let flashCount = simulator.simulate(for: 100)

        // Assert
        XCTAssertEqual(flashCount, 1656)
    }

    func testSimulate100StepsWithDay11Input() {
        // Arrange
        let lines = InputFile(bundle: Bundle.module, day: 11).loadLines().filter { $0.count > 0 }
        let grid =
            lines
            .map { Array($0).map { $0.wholeNumberValue! } }
        let simulator = EnergySimulator(grid: grid)

        // Act
        let flashCount = simulator.simulate(for: 100)

        // Assert
        XCTAssertEqual(flashCount, 1705)
    }

    func testSimulateUntilSynchronizedWithSampleInput() {
        // Arrange
        let lines = """
            5483143223
            2745854711
            5264556173
            6141336146
            6357385478
            4167524645
            2176841721
            6882881134
            4846848554
            5283751526
            """
        let grid = lines.components(separatedBy: .newlines)
            .map { Array($0).map { $0.wholeNumberValue! } }
        let simulator = EnergySimulator(grid: grid)

        // Act
        let stepCount = simulator.simulateUntilSynchronized()

        // Assert
        XCTAssertEqual(stepCount, 195)
    }

    func testSimulateUntilSynchronizedWithDay11Input() {
        // Arrange
        let lines = InputFile(bundle: Bundle.module, day: 11).loadLines().filter { $0.count > 0 }
        let grid =
            lines
            .map { Array($0).map { $0.wholeNumberValue! } }
        let simulator = EnergySimulator(grid: grid)

        // Act
        let stepCount = simulator.simulateUntilSynchronized()

        // Assert
        XCTAssertEqual(stepCount, 265)
    }
}
