import AdventOfCode
import XCTest

@testable import Library

class SubmarineTests: XCTestCase {
    func testSubmarineMoveWithSampleInput() throws {
        // Arrange
        var submarine = Submarine()
        let commands = [
            "forward 5",
            "down 5",
            "forward 8",
            "up 3",
            "down 8",
            "forward 2",
        ]

        // Act
        for command in commands {
            submarine.move(command: command)
        }

        // Assert
        XCTAssertEqual(submarine.position.product, 150)
    }

    func testSubmarineMoveWithDay2Input() throws {
        // Arrange
        var submarine = Submarine()
        let commands = InputFile(bundle: Bundle.module, day: 2).loadLines().filter { !$0.isEmpty }

        // Act
        for command in commands {
            submarine.move(command: command)
        }

        // Assert
        XCTAssertEqual(submarine.position.product, 1_670_340)
    }

    func testAimedSubmarineMoveWithSampleInput() throws {
        // Arrange
        var submarine = Submarine(with: ChargingAim())
        let commands = [
            "forward 5",
            "down 5",
            "forward 8",
            "up 3",
            "down 8",
            "forward 2",
        ]

        // Act
        for command in commands {
            submarine.move(command: command)
        }

        // Assert
        XCTAssertEqual(submarine.position.product, 900)
    }

    func testAimedSubmarineMoveWithDay2Input() throws {
        // Arrange
        var submarine = Submarine(with: ChargingAim())
        let commands = InputFile(bundle: Bundle.module, day: 2).loadLines().filter { !$0.isEmpty }

        // Act
        for command in commands {
            submarine.move(command: command)
        }

        // Assert
        XCTAssertEqual(submarine.position.product, 1_954_293_920)
    }
}
