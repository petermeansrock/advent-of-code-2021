import AdventOfCode
import XCTest

@testable import Library

class GameTests: XCTestCase {
    func testDeterministicallyWithSampleInput() {
        // Arrange
        let lines = """
            Player 1 starting position: 4
            Player 2 starting position: 8
            """.components(separatedBy: .newlines)
        let player1Start = parsePosition(lines[0])
        let player2Start = parsePosition(lines[1])
        let game = DeterministicGame(
            winningScore: 1000, player1Start: player1Start, player2Start: player2Start)

        // Act
        let result = game.play()

        // Assert
        XCTAssertEqual(result, 739785)
    }

    func testDeterministicallyWithDay21Input() {
        // Arrange
        let lines = InputFile(bundle: Bundle.module, day: 21).loadLines().filter { $0.count > 0 }
        let player1Start = parsePosition(lines[0])
        let player2Start = parsePosition(lines[1])
        let game = DeterministicGame(
            winningScore: 1000, player1Start: player1Start, player2Start: player2Start)

        // Act
        let result = game.play()

        // Assert
        XCTAssertEqual(result, 1_067_724)
    }

    func testExhaustivelyWithSampleInput() {
        // Arrange
        let lines = """
            Player 1 starting position: 4
            Player 2 starting position: 8
            """.components(separatedBy: .newlines)
        let player1Start = parsePosition(lines[0])
        let player2Start = parsePosition(lines[1])
        var game = ExhaustiveGame(
            winningScore: 21, player1Start: player1Start, player2Start: player2Start)

        // Act
        let result = game.play()

        // Assert
        XCTAssertEqual(result.counts.max()!, 444_356_092_776_315)
    }

    func testExhaustivelyWithDay21Input() {
        // Arrange
        let lines = InputFile(bundle: Bundle.module, day: 21).loadLines().filter { $0.count > 0 }
        let player1Start = parsePosition(lines[0])
        let player2Start = parsePosition(lines[1])
        var game = ExhaustiveGame(
            winningScore: 21, player1Start: player1Start, player2Start: player2Start)

        // Act
        let result = game.play()

        // Assert
        XCTAssertEqual(result.counts.max()!, 630_947_104_784_464)
    }

    func parsePosition(_ string: String) -> Int {
        return Int(
            try! string
                .firstMatch(pattern: #"starting position: (\d+)"#)!
                .captureGroups[0].substring
        )!
    }
}
