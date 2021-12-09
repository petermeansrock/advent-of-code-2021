import Foundation

/// Enumerates the digits supported on a seven-segment display.
public enum SevenSegmentDigit: Int, CaseIterable {
    case zero = 0
    case one = 1
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case six = 6
    case seven = 7
    case eight = 8
    case nine = 9

    /// The unscrambled signal representing a digit.
    public var signal: Set<Character> {
        switch self {
        case .zero:
            return ["a", "b", "c", "e", "f", "g"]
        case .one:
            return ["c", "f"]
        case .two:
            return ["a", "c", "d", "e", "g"]
        case .three:
            return ["a", "c", "d", "f", "g"]
        case .four:
            return ["b", "c", "d", "f"]
        case .five:
            return ["a", "b", "d", "f", "g"]
        case .six:
            return ["a", "b", "d", "e", "f", "g"]
        case .seven:
            return ["a", "c", "f"]
        case .eight:
            return ["a", "b", "c", "d", "e", "f", "g"]
        case .nine:
            return ["a", "b", "c", "d", "f", "g"]
        }
    }

    /// The number of segments needed to display a digit.
    public var segmentCount: Int {
        return self.signal.count
    }
}

/// A signal pattern contains a list of scrambled signals, each representing a different
/// ``SevenSegmentDigit``.
public struct SignalPattern {
    /// The list of scrambled signals comprising the pattern.
    public let signals: [Set<Character>]

    /// Finds all scrambled signals represented as the provided number of segments.
    ///
    /// - Parameter segments: The number of segments each returned signal will represent.
    /// - Returns: All scrambled signals represented as the provided number of segments.
    public func findSignals(with segments: Int) -> [Set<Character>] {
        return signals.filter { $0.count == segments }
    }
}

/// An output value for each ``SevenSegmentDisplay``.
public struct OutputValue {
    /// The list of scrambled signals representing this value.
    public let signals: [Set<Character>]
}

/// A seven segment display contains a scrambled output value that can only be unscrambled using the
/// provided signal pattern.
public struct SevenSegmentDisplay {
    /// The signal pattern for this display.
    public let signalPattern: SignalPattern
    /// The scrambled outout value for this display.
    public let outputValue: OutputValue

    internal init(signalPattern: SignalPattern, outputValue: OutputValue) {
        self.signalPattern = signalPattern
        self.outputValue = outputValue
    }

    /// Creates a new instance.
    ///
    /// The provided string should consist of 9 scrambled signals (representing the signal pattern),
    /// followed by a pipe, followed by 4 scrambled signals (representing the output value). For
    /// example:
    ///
    /// ```
    /// acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf
    /// ```
    ///
    /// - Parameter display: The display as a string.
    public init(display: String) {
        let components = display.components(separatedBy: " | ")
        let signalPattern = SignalPattern(
            signals: components[0].components(separatedBy: " ").map { Set(Array($0)) })
        let outputValue = OutputValue(
            signals: components[1].components(separatedBy: " ").map { Set(Array($0)) })
        self.init(signalPattern: signalPattern, outputValue: outputValue)
    }

    /// Unscrambles the display, returning its output value as a number.
    ///
    /// - Returns: The output value as number.
    public func unscramble() -> Int {
        // NOTE: The variable names throughout this method may seem a bit arcane, but they
        //       all follow the same pattern:
        //       - Each variable's type is Set<Character>, where the set contains scrambled segments
        //         as characters, from "a" through "g".
        //       - They begin with one or more letters from lettered segments, from "a" through "g".
        //         These letters represent the *unscrambled* segments encoded within the variable's
        //         value.
        //       - They will end with an integer, from 0 through 9, if the set represents a sevent-
        //         segment digit of that value.

        // Fetch scrambled sets of characters for the following unambigous numbers:
        //
        // 1 = ["c", "f"]
        // 4 = ["b", "c", "d", "f"]
        // 7 = ["a", "c", "f"]
        // 8 = ["a", "b", "c", "d", "e", "f", "g"]
        let cf1 = self.signalPattern.findSignals(with: SevenSegmentDigit.one.segmentCount)[0]
        let bcdf4 = self.signalPattern.findSignals(with: SevenSegmentDigit.four.segmentCount)[0]
        let acf7 = self.signalPattern.findSignals(with: SevenSegmentDigit.seven.segmentCount)[0]
        let abcdefg8 = self.signalPattern.findSignals(with: SevenSegmentDigit.eight.segmentCount)[0]

        // Calculcate known scrambled subsets for lookups later
        let a = acf7.subtracting(cf1)
        let bdeg = abcdefg8.subtracting(acf7)
        let aeg = abcdefg8.subtracting(bcdf4)
        let eg = aeg.subtracting(a)
        let bd = bdeg.subtracting(eg)

        // The remaining unknown digits include:
        //
        // 0 = ["a", "b", "c", "e", "f", "g"] missing ["d"]
        // 2 = ["a", "c", "d", "e", "g"]      missing ["b", "f"]
        // 3 = ["a", "c", "d", "f", "g"]      missing ["b", "e"]
        // 5 = ["a", "b", "d", "f", "g"]      missing ["c", "e"]
        // 6 = ["a", "b", "d", "e", "f", "g"] missing ["c"]
        // 9 = ["a", "b", "c", "d", "f", "g"] missing ["e"]
        //
        // We can start by looping through all six digit scrambled sets and use their intersections
        // with known sets to determine their values. Specifically:
        //
        // 6 = ["a", "b", "d", "e", "f", "g"] intersection with ["c", "f"] will equal ["f"]
        // 9 = ["a", "b", "c", "d", "f", "g"] intersection with ["e", "g"] will equal ["g"]
        // 0 = ["a", "b", "c", "e", "f", "g"] intersection with the same sets will contain two items
        //
        // These same intersections against
        var f: Set<Character> = []
        var abcefg0: Set<Character> = []
        var abdefg6: Set<Character> = []
        var abcdfg9: Set<Character> = []
        let sixDigitSignals = self.signalPattern.findSignals(with: 6)
        for sixDigitSignal in sixDigitSignals {
            let cfIntersection = sixDigitSignal.intersection(cf1)
            let egIntersection = sixDigitSignal.intersection(eg)

            if cfIntersection.count == 1 {
                f = cfIntersection
                abdefg6 = sixDigitSignal
            } else if egIntersection.count == 1 {
                abcdfg9 = sixDigitSignal
            } else {
                abcefg0 = sixDigitSignal
            }
        }

        // Now we can derive the one character sets based on each's missing segment
        let d = abcdefg8.subtracting(abcefg0)
        let c = abcdefg8.subtracting(abdefg6)
        let e = abcdefg8.subtracting(abcdfg9)

        // We can then derive the one character set for ["b"]
        let b = bd.subtracting(d)

        // The remaining unknown digits include:
        //
        // 2 = ["a", "c", "d", "e", "g"] missing ["b", "f"]
        // 3 = ["a", "c", "d", "f", "g"] missing ["b", "e"]
        // 5 = ["a", "b", "d", "f", "g"] missing ["c", "e"]
        //
        // We can finish by simply use set operations to find the remaining scrambled sets
        let acdeg2 = abcdefg8.subtracting(b).subtracting(f)
        let acdfg3 = abcdefg8.subtracting(b).subtracting(e)
        let abdfg5 = abcdefg8.subtracting(c).subtracting(e)

        // We can finally create a translation map from each scrambled set to their nubmers
        let translationMap = [
            abcefg0: "0",
            cf1: "1",
            acdeg2: "2",
            acdfg3: "3",
            bcdf4: "4",
            abdfg5: "5",
            abdefg6: "6",
            acf7: "7",
            abcdefg8: "8",
            abcdfg9: "9",
        ]
        return Int(
            self.outputValue.signals
                .map { translationMap[$0]! }
                .reduce("", +)
        )!
    }
}
