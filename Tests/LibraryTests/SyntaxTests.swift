import AdventOfCode
import XCTest

@testable import Library

class SyntaxTests: XCTestCase {
    func testParseCorruptedLinesWithSampleInput() {
        // Arrange
        let parser = ChunkLineParser()
        let lines = """
            [({(<(())[]>[[{[]{<()<>>
            [(()[<>])]({[<{<<[]>>(
            {([(<{}[<>[]}>{[]{[(<()>
            (((({<>}<{<{<>}{[]{[]{}
            [[<[([]))<([[{}[[()]]]
            [{[{({}]{}}([{[{{{}}([]
            {<[[]]>}<{[{[{[]{()[[[]
            [<(<(<(<{}))><([]([]()
            <{([([[(<>()){}]>(<<{{
            <{([{{}}[<[[[<>{}]]]>[]]
            """.components(separatedBy: .newlines)

        // Act
        let errorScore =
            lines
            .map { parser.parse(string: $0) }
            .map {
                switch $0 {
                case .corrupted(let errorScore):
                    return errorScore
                default:
                    return 0
                }
            }
            .reduce(0, +)

        // Assert
        XCTAssertEqual(errorScore, 26397)
    }

    func testParseCorruptedLinesWithDay10Input() {
        // Arrange
        let parser = ChunkLineParser()
        let lines = InputFile(bundle: Bundle.module, day: 10).loadLines().filter { $0.count > 0 }

        // Act
        let errorScore =
            lines
            .map { parser.parse(string: $0) }
            .map {
                switch $0 {
                case .corrupted(let errorScore):
                    return errorScore
                default:
                    return 0
                }
            }
            .reduce(0, +)

        // Assert
        XCTAssertEqual(errorScore, 399153)
    }

    func testParseIncompleteLinesWithSampleInput() {
        // Arrange
        let parser = ChunkLineParser()
        let lines = """
            [({(<(())[]>[[{[]{<()<>>
            [(()[<>])]({[<{<<[]>>(
            {([(<{}[<>[]}>{[]{[(<()>
            (((({<>}<{<{<>}{[]{[]{}
            [[<[([]))<([[{}[[()]]]
            [{[{({}]{}}([{[{{{}}([]
            {<[[]]>}<{[{[{[]{()[[[]
            [<(<(<(<{}))><([]([]()
            <{([([[(<>()){}]>(<<{{
            <{([{{}}[<[[[<>{}]]]>[]]
            """.components(separatedBy: .newlines)

        // Act
        let completionScores: [Int] =
            lines
            .map { parser.parse(string: $0) }
            .compactMap {
                switch $0 {
                case .incomplete(let completionScore):
                    return completionScore
                default:
                    return nil
                }
            }
            .sorted()
        let medianCompletionScore = completionScores[completionScores.count / 2]

        // Assert
        XCTAssertEqual(medianCompletionScore, 288957)
    }

    func testParseIncompleteLinesWithDay10Input() {
        // Arrange
        let parser = ChunkLineParser()
        let lines = InputFile(bundle: Bundle.module, day: 10).loadLines().filter { $0.count > 0 }

        // Act
        let completionScores: [Int] =
            lines
            .map { parser.parse(string: $0) }
            .compactMap {
                switch $0 {
                case .incomplete(let completionScore):
                    return completionScore
                default:
                    return nil
                }
            }
            .sorted()
        let medianCompletionScore = completionScores[completionScores.count / 2]

        // Assert
        XCTAssertEqual(medianCompletionScore, 2_995_077_699)
    }

    func testParseCompleteLine() {
        // Arrange
        let parser = ChunkLineParser()
        let line = "[<>({}){}[([])<>]]"

        // Act
        let chunkLine = parser.parse(string: line)

        // Assert
        XCTAssertEqual(chunkLine, .complete)
    }
}
