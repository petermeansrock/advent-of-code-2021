import AdventOfCode
import XCTest

@testable import Library

class BurrowSolverTests: XCTestCase {
    func testWithSampleInput() {
        // Arrange
        let description = """
            #############
            #...........#
            ###B#C#B#D###
              #A#D#C#A#
              #########
            """
        let burrow = Burrow(description)!
        var solver = BurrowSolver(with: burrow)

        // Act
        let cost = solver.findMinimumAlignmentCost()

        // Assert
        XCTAssertEqual(cost, 12521)
    }

    func testWithDay23Input() {
        // Arrange
        let description = InputFile(bundle: Bundle.module, day: 23).loadContents()
        let burrow = Burrow(description)!
        var solver = BurrowSolver(with: burrow)

        // Act
        let cost = solver.findMinimumAlignmentCost()

        // Assert
        XCTAssertEqual(cost, 15472)
    }

    func testWithExpandedSampleInput() {
        // Arrange
        let originalDescription = """
            #############
            #...........#
            ###B#C#B#D###
              #A#D#C#A#
              #########
            """
        var lines = originalDescription.components(separatedBy: .newlines)
        lines.insert("  #D#C#B#A#", at: 3)
        lines.insert("  #D#B#A#C#", at: 4)
        let description = lines.joined(separator: "\n")  // TODO: Replace with constant?
        let burrow = Burrow(description)!
        var solver = BurrowSolver(with: burrow)

        // Act
        let cost = solver.findMinimumAlignmentCost()

        // Assert
        XCTAssertEqual(cost, 44169)
    }

    func testWithExpandedDay23Input() {
        // Arrange
        var lines = InputFile(bundle: Bundle.module, day: 23).loadLines()
        lines.insert("  #D#C#B#A#", at: 3)
        lines.insert("  #D#B#A#C#", at: 4)
        let description = lines.joined(separator: "\n")  // TODO: Replace with constant?
        let burrow = Burrow(description)!
        var solver = BurrowSolver(with: burrow)

        // Act
        let cost = solver.findMinimumAlignmentCost()

        // Assert
        XCTAssertEqual(cost, 46182)
    }
}

class BurrowTests: XCTestCase {
    func testDescriptionWithSampleInput() {
        // Arrange
        let description = """
            #############
            #...........#
            ###B#C#B#D###
              #A#D#C#A#
              #########
            """

        // Act
        let burrow = Burrow(description)!

        // Assert
        XCTAssertEqual(burrow.description, description)
    }

    func testDescriptionWithBlanks() {
        // Arrange
        let description = """
            #############
            #...........#
            ###.#C#B#.###
              #A#.#C#A#
              #########
            """

        // Act
        let burrow = Burrow(description)!

        // Assert
        XCTAssertEqual(burrow.description, description)
    }

    func testAlignedWithIncompleteState() {
        // Arrange
        let description = """
            #############
            #...........#
            ###B#C#B#D###
              #A#D#C#A#
              #########
            """

        // Act
        let aligned = Burrow(description)!.aligned

        // Assert
        XCTAssertFalse(aligned)
    }

    func testAlignedWithFinalState() {
        // Arrange
        let description = """
            #############
            #...........#
            ###A#B#C#D###
              #A#B#C#D#
              #########
            """

        // Act
        let aligned = Burrow(description)!.aligned

        // Assert
        XCTAssertTrue(aligned)
    }

    func testLegalMoveFromHallwayToEmptyRoom() {
        // Arrange
        let description = """
            #############
            #..........B#
            ###.#.#.#.###
              #.#.#.#.#
              #########
            """
        let burrow = Burrow(description)!

        // Act
        let moves = burrow.legalMoves
        let (resultBurrow, cost) = burrow.move(with: moves[0])

        // Assert
        let expected = """
            #############
            #...........#
            ###.#.#.#.###
              #.#B#.#.#
              #########
            """
        XCTAssertEqual(moves.count, 1)
        XCTAssertEqual(resultBurrow.description, expected)
        XCTAssertEqual(cost, 80)
    }

    func testLegalMoveFromRoomToEmptyRoom() {
        // Arrange
        let description = """
            #############
            #...........#
            ###.#C#.#.###
              #.#B#.#.#
              #########
            """
        let burrow = Burrow(description)!

        // Act
        let moves = burrow.legalMoves
        let (resultBurrow, cost) = burrow.move(with: moves[0])

        // Assert
        let expected = """
            #############
            #...........#
            ###.#.#.#.###
              #.#B#C#.#
              #########
            """
        XCTAssertEqual(moves.count, 1)
        XCTAssertEqual(resultBurrow.description, expected)
        XCTAssertEqual(cost, 500)
    }

    func testLegalMoveFromPreferredRoomToHallway() {
        // Arrange
        let description = """
            #############
            #...........#
            ###A#.#.#.###
              #B#.#.#.#
              #########
            """
        let burrow = Burrow(description)!

        // Act
        let moves = burrow.legalMoves
        let sources =
            moves
            .map { $0.source }
            .reduce(into: Set()) { $0.insert($1) }

        // Assert
        XCTAssertEqual(moves.count, 7)
        XCTAssertEqual(sources.count, 1)
    }
}
