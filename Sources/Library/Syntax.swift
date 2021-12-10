import Foundation

/// Represents an opening or closing character for a chunk.
public enum ChunkCharacter: Character, CaseIterable {
    case leftParenthesis = "("
    case rightParenthesis = ")"
    case leftBracket = "["
    case rightBracket = "]"
    case leftBrace = "{"
    case rightBrace = "}"
    case leftChevron = "<"
    case rightChevron = ">"

    /// Whether or this is an opening or closing character for a chunk.
    public var opens: Bool {
        switch self {
        case .leftParenthesis, .leftBracket, .leftBrace, .leftChevron:
            return true
        default:
            return false
        }
    }

    /// The character paired with this chunk character.
    ///
    /// For an opening character, this will represent its paired closing character (and vice versa).
    public var partner: ChunkCharacter {
        let index = ChunkCharacter.allCases.firstIndex(of: self)!
        if self.opens {
            return ChunkCharacter.allCases[index + 1]
        } else {
            return ChunkCharacter.allCases[index - 1]
        }
    }

    /// The associated error score if a closing character appears without an associated opening
    /// character preceding it.
    public var errorScore: Int? {
        switch self {
        case .rightParenthesis:
            return 3
        case .rightBracket:
            return 57
        case .rightBrace:
            return 1197
        case .rightChevron:
            return 25137
        default:
            return nil
        }
    }

    /// The associated completion score if a closing character is used as part of a sequence to
    /// close one or more chunks.
    public var completionScore: Int? {
        switch self {
        case .rightParenthesis:
            return 1
        case .rightBracket:
            return 2
        case .rightBrace:
            return 3
        case .rightChevron:
            return 4
        default:
            return nil
        }
    }
}

/// Represents the state of a parsed line of chunks.
public enum ChunkLine: Equatable {
    /// A corrupted line contains a closing character which appears without an associated opening
    /// character preceding it.
    ///
    /// - Parameter errorScore: The `ChunkLineCharacter`.``ChunkCharacter/errorScore`` for the
    ///   mismatched closing character.
    case corrupted(errorScore: Int)
    /// An incomplete line is missing one or more closing characters.
    ///
    /// - Parameter completionScore: A computed value based on the values of
    ///   `ChunkLineCharacter`.``ChunkCharacter/completionScore`` for each missing closing
    ///   character. Starting with a total score of `0`, for each missing closing character, the
    ///   total score is multiplied by `5` before adding the completion score for the missing
    ///   closing character.
    case incomplete(completionScore: Int)
    /// A complete line does not contain any mismatched or missing closing characters.
    case complete
}

/// Supports the parsing of a line of chunks.
public struct ChunkLineParser {
    /// Parses a line of chunks.
    ///
    /// - Parameter string: The line to parse.
    /// - Returns: The state of the parsed line of chunks.
    public func parse(string: String) -> ChunkLine {
        // Parse all chunk characters, returning early if the line is corrupted
        var stack = [ChunkCharacter]()
        for character in Array(string).map({ ChunkCharacter(rawValue: $0)! }) {
            if character.opens {
                // Simply add opening characters to the stack
                stack.append(character)
            } else if stack.isEmpty {
                // A closing character should not appear while the stack is empty
                return .corrupted(errorScore: character.errorScore!)
            } else {
                // A closing character should always partner with the top of the stack, so pop and compare
                if character.partner != stack.removeLast() {
                    return .corrupted(errorScore: character.errorScore!)
                }
            }
        }

        // Only complete or incomplete lines will reach this point
        if stack.isEmpty {
            return .complete
        } else {
            // Calculate completion score for incomplete lines
            var completionScore = 0
            for character in stack.reversed() {
                completionScore *= 5
                completionScore += character.partner.completionScore!
            }
            return .incomplete(completionScore: completionScore)
        }
    }
}
