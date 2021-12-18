import Collections
import Foundation

/// A snailfish number is represented as a pair of elements, where each element may consist of a
/// regular number (e.g., `5`) or another pair.
///
/// The following is a legal snailfish number:
///
/// ```
/// [[3,4],5]
/// ```
/// The above consists of a single top-level pair (as all snailfish numbers do) consisting of two
/// elements:
/// 1. Another pair of regular numbers `[3, 4]`
/// 2. A regular number `5`
public struct SnailfishNumber: LosslessStringConvertible {
    private let pair: PairElement
    /// The magnitude of this number.
    public let magnitude: Int
    /// The string representation of this number.
    public let description: String

    /// Creates a new instance from its string representation.
    public init?(_ description: String) {
        guard let pair = PairElement(description) else {
            return nil
        }

        self.init(pair: pair)
    }

    private init(pair: PairElement) {
        // Reduce pair if necessary
        self.pair = pair.reduce()
        self.magnitude = self.pair.magnitude
        self.description = self.pair.description
    }

    static func + (lhs: SnailfishNumber, rhs: SnailfishNumber) -> SnailfishNumber {
        return SnailfishNumber(pair: PairElement(left: lhs.pair, right: rhs.pair))
    }
}

private protocol Element: LosslessStringConvertible {
    var magnitude: Int { get }
}

private struct RegularNumberElement: Element {
    let value: Int
    let magnitude: Int
    let description: String

    init(value: Int) {
        self.value = value
        self.magnitude = self.value
        self.description = String(self.value)
    }

    init?(_ description: String) {
        guard let value = Int(description) else {
            return nil
        }

        self.init(value: value)
    }
}

private struct PairElement: Element {
    let left: Element
    let right: Element
    let magnitude: Int
    let description: String

    init(left: Element, right: Element) {
        self.left = left
        self.right = right
        self.magnitude = (3 * self.left.magnitude) + (2 * self.right.magnitude)
        self.description = "[" + self.left.description + "," + self.right.description + "]"
    }

    init?(_ description: String) {
        guard description.prefix(1) == "[" && description.suffix(1) == "]" else {
            return nil
        }

        let innerDescription = description.dropFirst().dropLast()

        // Search for comma separating left and right sides
        var commaIndex: Substring.Index? = nil
        if !innerDescription.starts(with: "[") {
            // If the first element is a regular number, the first comma is the one we'll use to
            // split the pair
            commaIndex = innerDescription.firstIndex(of: ",")
        } else {
            var bracketCount = 0
            for i in innerDescription.indices {
                // Keep track of the bracket counts
                if innerDescription[i] == "[" {
                    bracketCount += 1
                } else if innerDescription[i] == "]" {
                    bracketCount -= 1
                }

                // If we find pairs for all brackets, the next character will be the comma to split
                // on
                if bracketCount == 0 {
                    commaIndex = innerDescription.index(i, offsetBy: 1)
                    break
                }
            }
        }

        guard let commaIndex = commaIndex else {
            return nil
        }

        let leftDescription = innerDescription[..<commaIndex]
        let rightDescription = innerDescription[
            (innerDescription.index(commaIndex, offsetBy: 1))...]

        let left = PairElement.createElement(String(leftDescription))!
        let right = PairElement.createElement(String(rightDescription))!

        self.init(left: left, right: right)
    }

    fileprivate func reduce() -> PairElement {
        // Convert to string representation
        var currentString = self.description

        while true {
            let explodedString = PairElement.explode(currentString)
            if currentString == explodedString {
                let splitString = PairElement.split(currentString)
                if currentString == splitString {
                    break
                } else {
                    currentString = splitString
                }
            } else {
                currentString = explodedString
            }
        }

        return PairElement(currentString)!
    }

    private static func explode(_ string: String) -> String {
        var explodeRange: Range<String.Index>? = nil

        var bracketCount = 0
        for i in string.indices {
            // Keep track of the bracket counts
            if string[i] == "[" {
                bracketCount += 1
            } else if string[i] == "]" {
                bracketCount -= 1
            }

            // The number pair to explode will appear at this bracket count (or higher)
            if bracketCount >= 5 {
                // Search from the previous character through to the end of the string for the pair
                // to explode (which must exist at this depth)
                let start = string.index(i, offsetBy: -1)
                let remaining = start..<string.endIndex
                explodeRange = string.range(
                    of: #"\[\d+,\d+]"#,
                    options: .regularExpression,
                    range: remaining
                )!
                break
            }
        }

        // If a pair to explode has been found, perform the operation
        if let range = explodeRange {
            let explodePair = PairElement(String(string[range]))!
            let explodeLeft = (explodePair.left as! RegularNumberElement).value
            let explodeRight = (explodePair.right as! RegularNumberElement).value

            // Search left to find integer
            let leftString = try! String(string[string.startIndex..<range.lowerBound])
                .replaceLastMatch(pattern: #"\d+"#) { String(Int($0)! + explodeLeft) }

            // Search right to find integer
            let rightString = try! String(string[range.upperBound..<string.endIndex])
                .replaceFirstMatch(pattern: #"\d+"#) { String(Int($0)! + explodeRight) }

            return leftString + "0" + rightString
        }

        return string
    }

    private static func split(_ string: String) -> String {
        return try! string.replaceFirstMatch(pattern: #"\d\d+"#) { substring in
            let value = Int(substring)!

            let leftValue = value / 2
            let rightValue: Int
            if value % 2 == 0 {
                rightValue = leftValue
            } else {
                rightValue = leftValue + 1
            }

            let pair = PairElement(
                left: RegularNumberElement(value: leftValue),
                right: RegularNumberElement(value: rightValue))

            return pair.description
        }
    }

    private static func createElement(_ description: String) -> Element? {
        if description.contains("[") {
            return PairElement(description)
        } else {
            return RegularNumberElement(description)
        }
    }
}
