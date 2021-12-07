import XCTest

@testable import Library

class FuelOptimizerTests: XCTestCase {
    func testSampleInputWithFlatFuelEfficiency() {
        // Arrange
        let positions = [16, 1, 2, 0, 4, 2, 7, 1, 2, 14]

        // Act
        let optimizer = FuelOptimizer(positions: positions, fuelEfficiency: FlatFuelEfficiency())

        // Assert
        XCTAssertEqual(optimizer.minimumFuel, 37)
    }

    func testDay7InputWithFlatFuelEfficiency() {
        // Arrange
        let positions = InputFile(day: 7).loadLines()[0].components(separatedBy: ",").map {
            Int($0)!
        }

        // Act
        let optimizer = FuelOptimizer(positions: positions, fuelEfficiency: FlatFuelEfficiency())

        // Assert
        XCTAssertEqual(optimizer.minimumFuel, 355150)
    }

    func testSampleInputWithLinearlyDecreasingFuelEfficiency() {
        // Arrange
        let positions = [16, 1, 2, 0, 4, 2, 7, 1, 2, 14]

        // Act
        let optimizer = FuelOptimizer(
            positions: positions, fuelEfficiency: LinearlyDecreasingFuelEfficiency())

        // Assert
        XCTAssertEqual(optimizer.minimumFuel, 168)
    }

    func testDay7InputWithLinearlyDecreasingFuelEfficiency() {
        // Arrange
        let positions = InputFile(day: 7).loadLines()[0].components(separatedBy: ",").map {
            Int($0)!
        }

        // Act
        let optimizer = FuelOptimizer(
            positions: positions, fuelEfficiency: LinearlyDecreasingFuelEfficiency())

        // Assert
        XCTAssertEqual(optimizer.minimumFuel, 98_368_490)
    }
}
