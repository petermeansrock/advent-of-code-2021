import Foundation

internal struct Pair: Hashable {
    let left: Character
    let right: Character

    internal init(left: Character, right: Character) {
        self.left = left
        self.right = right
    }

    internal init(pair: String) {
        let characters = Array(pair)
        self.init(left: characters[0], right: characters[1])
    }

    /// Hashes the essential components of this value by feeding them into the given hasher.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.left)
        hasher.combine(self.right)
    }
}

/// A rule that defines an insertion rule based on a pair of characters.
public struct PairInsertionRule {
    internal let pair: Pair
    internal let insertion: Character

    /// Creates a new instance.
    ///
    /// - Parameter string: A string containing a source pair of characters, followed by an arrow
    ///   ` -> `, followed by the insertion character. For example, `CH -> B` defines a rule from
    ///   the pair `CH` to an insertion character `B`.
    public init(string: String) {
        let parts = string.components(separatedBy: " -> ")
        self.init(pair: Pair(pair: parts[0]), insertion: Array(parts[1])[0])
    }

    internal init(pair: Pair, insertion: Character) {
        self.pair = pair
        self.insertion = insertion
    }
}

/// An evaluator of pair insertion rules.
public struct PairInsertionRuleEvaluator {
    private let rules: [Pair: Character]

    /// Creates a new instance.
    ///
    /// - Parameter rules: An array of pair insertion rules.
    public init(rules: [PairInsertionRule]) {
        self.rules = rules.reduce(into: [:]) { map, rule in
            map[rule.pair] = rule.insertion
        }
    }

    /// Evaluates the configured set of rules against the provided polymer template fror the
    /// specified number of steps.
    ///
    /// - Parameters:
    ///   - polymerTemplate: The polymer template against which to evaluate rules.
    ///   - steps: The number of steps to evaluate.
    /// - Returns: The difference between the frequency of the highest occurring character in the
    ///   output string and the frequency of the least occurring character in the output string.
    public func evaluate(against polymerTemplate: String, for steps: Int) -> Int {
        // Keep track of the numbers of times each character will appear in the output string
        let polymerTemplateCharacters = Array(polymerTemplate)
        var characterCounts =
            polymerTemplateCharacters
            .reduce(into: [:]) { counts, character in
                counts[character, default: 0] += 1
            }

        // Keep track of the latest set of pairs along with their number of occurrences
        var latestPairCounts = zip(polymerTemplateCharacters, polymerTemplateCharacters.dropFirst())
            .map { Pair(left: $0, right: $1) }
            .reduce(into: [:]) { counts, pair in
                counts[pair, default: 0] += 1
            }

        // Iterate through all steps
        for _ in 1...steps {
            // Keep track of the pair counts for this step
            var stepPairCounts = [Pair: Int]()

            for pair in latestPairCounts.keys {
                // Retrieve and record insertion character count based on the number of pair
                // occurrences
                let insertionCharacter = rules[pair]!
                characterCounts[insertionCharacter, default: 0] += latestPairCounts[pair]!

                // Build new pairs from old pair
                let leftPair = Pair(left: pair.left, right: insertionCharacter)
                let rightPair = Pair(left: insertionCharacter, right: pair.right)

                // Carryover counts from previous generation
                stepPairCounts[leftPair, default: 0] += latestPairCounts[pair]!
                stepPairCounts[rightPair, default: 0] += latestPairCounts[pair]!
            }

            // Update the latest pair counts based on the completed step
            latestPairCounts = stepPairCounts
        }

        // Calculate the solution based on the character counts
        let sortedCounts =
            characterCounts
            .map { $0.value }
            .sorted()
        return sortedCounts.last! - sortedCounts.first!
    }
}
