import AdventOfCode
import Foundation
import XCTest

@testable import Library

class DisplayTests: XCTestCase {
    func testDisplayWithSampleInput() {
        // Arrange
        let contents = """
            be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
            edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
            fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
            fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
            aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
            fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
            dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
            bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
            egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
            gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
            """
        let lines = contents.components(separatedBy: .newlines)

        // Act
        var displays = [SevenSegmentDisplay]()
        for line in lines {
            displays.append(SevenSegmentDisplay(display: line))
        }
        let relevantDigits: [SevenSegmentDigit] = [
            .one,
            .four,
            .seven,
            .eight,
        ]
        let relevantSegmentCounts = relevantDigits.map { $0.segmentCount }
        let count =
            displays
            .map { $0.outputValue }  // Examine only the output value for the display
            .flatMap { $0.signals }  // Flatten all signals in output values
            .map { $0.count }  // Examine only the signal length
            .filter { relevantSegmentCounts.contains($0) }  // Filter to relevant segment counts
            .count  // Count the number of results

        // Assert
        XCTAssertEqual(count, 26)
    }

    func testDisplayWithDay8Input() {
        // Arrange
        let lines = InputFile(bundle: Bundle.module, day: 8).loadLines().filter { $0.count > 0 }

        // Act
        var displays = [SevenSegmentDisplay]()
        for line in lines {
            displays.append(SevenSegmentDisplay(display: line))
        }
        let relevantDigits: [SevenSegmentDigit] = [
            .one,
            .four,
            .seven,
            .eight,
        ]
        let relevantSegmentCounts = relevantDigits.map { $0.segmentCount }
        let count =
            displays
            .map { $0.outputValue }  // Examine only the output value for the display
            .flatMap { $0.signals }  // Flatten all signals in output values
            .map { $0.count }  // Examine only the signal length
            .filter { relevantSegmentCounts.contains($0) }  // Filter to relevant segment counts
            .count  // Count the number of results

        // Assert
        XCTAssertEqual(count, 367)
    }

    func testDisplayUnscrambleWithSmallSampleInput() {
        // Arrange
        let contents = """
            acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf
            """
        let lines = contents.components(separatedBy: .newlines)

        // Act
        let display = SevenSegmentDisplay(display: lines[0])
        let value = display.unscramble()

        // Assert
        XCTAssertEqual(value, 5353)
    }

    func testDisplayUnscrambleWithSampleInput() {
        // Arrange
        let contents = """
            be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
            edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
            fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
            fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
            aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
            fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
            dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
            bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
            egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
            gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
            """
        let lines = contents.components(separatedBy: .newlines).filter { $0.count > 0 }

        // Act
        let value =
            lines
            .map(SevenSegmentDisplay.init)
            .map { $0.unscramble() }
            .reduce(0, +)

        // Assert
        XCTAssertEqual(value, 61229)
    }

    func testDisplayUnscrambleWithDay8Input() {
        // Arrange
        let lines = InputFile(bundle: Bundle.module, day: 8).loadLines().filter { $0.count > 0 }

        // Act
        let value =
            lines
            .map(SevenSegmentDisplay.init)
            .map { $0.unscramble() }
            .reduce(0, +)

        // Assert
        XCTAssertEqual(value, 974512)
    }
}
