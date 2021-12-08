import XCTest

@testable import Library

class SpawnerTests: XCTestCase {
    func testSpawnFor80DaysWithSampleInput() {
        // Arrange
        let spawner = Spawner()
        let values = [
            3,
            4,
            3,
            1,
            2,
        ]

        // Act
        let count = spawner.spawn(with: values, through: 80, every: 7, plus: 2)

        // Assert
        XCTAssertEqual(count, 5934)
    }

    func testSpawnFor256DaysWithSampleInput() {
        // Arrange
        let spawner = Spawner()
        let values = [
            3,
            4,
            3,
            1,
            2,
        ]

        // Act
        let count = spawner.spawn(with: values, through: 256, every: 7, plus: 2)

        // Assert
        XCTAssertEqual(count, 26_984_457_539)
    }

    func testSpawnFor80DaysWithDay6Input() {
        // Arrange
        let spawner = Spawner()
        let values = InputFile(day: 6).loadLines()[0].components(separatedBy: ",").map { Int($0)! }

        // Act
        let count = spawner.spawn(with: values, through: 80, every: 7, plus: 2)

        // Assert
        XCTAssertEqual(count, 350917)
    }

    func testSpawnFor256DaysWithDay6Input() {
        // Arrange
        let spawner = Spawner()
        let values = InputFile(day: 6).loadLines()[0].components(separatedBy: ",").map { Int($0)! }

        // Act
        let count = spawner.spawn(with: values, through: 256, every: 7, plus: 2)

        // Assert
        XCTAssertEqual(count, 1_592_918_715_629)
    }
}
