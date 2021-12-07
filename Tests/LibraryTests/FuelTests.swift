import XCTest

@testable import Library

class FuelOptimizerTests: XCTestCase {
    func testSampleInputWithFlatFuelEfficiency() {
        // Arrange
        let optimizer = FuelOptimizer(fuelEfficiency: FlatFuelEfficiency())
        let positions = [16, 1, 2, 0, 4, 2, 7, 1, 2, 14]

        // Act
        let fuel = optimizer.minimumFuelToAlign(positions: positions)

        // Assert
        XCTAssertEqual(fuel, 37)
    }

    func testDay7InputWithFlatFuelEfficiency() {
        // Arrange
        let optimizer = FuelOptimizer(fuelEfficiency: FlatFuelEfficiency())
        let positions = InputFile(day: 7).loadLines()[0].components(separatedBy: ",").map {
            Int($0)!
        }

        // Act
        let fuel = optimizer.minimumFuelToAlign(positions: positions)

        // Assert
        XCTAssertEqual(fuel, 355150)
    }

    func testSampleInputWithLinearlyDecreasingFuelEfficiency() {
        // Arrange
        let optimizer = FuelOptimizer(fuelEfficiency: LinearlyDecreasingFuelEfficiency())
        let positions = [16, 1, 2, 0, 4, 2, 7, 1, 2, 14]

        // Act
        let fuel = optimizer.minimumFuelToAlign(positions: positions)

        // Assert
        XCTAssertEqual(fuel, 168)
    }

    func testDay7InputWithLinearlyDecreasingFuelEfficiency() {
        // Arrange
        let optimizer = FuelOptimizer(fuelEfficiency: LinearlyDecreasingFuelEfficiency())
        let positions = InputFile(day: 7).loadLines()[0].components(separatedBy: ",").map {
            Int($0)!
        }

        // Act
        let fuel = optimizer.minimumFuelToAlign(positions: positions)

        // Assert
        XCTAssertEqual(fuel, 98_368_490)
    }
}
