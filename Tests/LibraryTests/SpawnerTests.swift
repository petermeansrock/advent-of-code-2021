import XCTest

@testable import Library

class SpawnerTests: XCTestCase {
    func testSpawnFor80DaysWithSampleInput() {
        // Arrange
        let values = [
            3,
            4,
            3,
            1,
            2,
        ]

        // Act
        let spawner = Spawner(with: values, through: 80, every: 7, plus: 2)

        // Assert
        XCTAssertEqual(spawner.count, 5934)
    }

    func testSpawnFor256DaysWithSampleInput() {
        // Arrange
        let values = [
            3,
            4,
            3,
            1,
            2,
        ]

        // Act
        let spawner = Spawner(with: values, through: 256, every: 7, plus: 2)

        // Assert
        XCTAssertEqual(spawner.count, 26_984_457_539)
    }

    func testSpawnFor80DaysWithDay6Input() {
        // Arrange
        let values = InputFile(day: 6).loadLines()[0].components(separatedBy: ",").map { Int($0)! }

        // Act
        let spawner = Spawner(with: values, through: 80, every: 7, plus: 2)

        // Assert
        XCTAssertEqual(spawner.count, 350917)
    }

    func testSpawnFor256DaysWithDay6Input() {
        // Arrange
        let values = InputFile(day: 6).loadLines()[0].components(separatedBy: ",").map { Int($0)! }

        // Act
        let spawner = Spawner(with: values, through: 256, every: 7, plus: 2)

        // Assert
        XCTAssertEqual(spawner.count, 1_592_918_715_629)
    }
}
