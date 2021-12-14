import AdventOfCode
import XCTest

@testable import Library

class PolymerTests: XCTestCase {
    func test10StepsWithSampleInput() {
        // Arrange
        let lines = """
            NNCB

            CH -> B
            HH -> N
            CB -> H
            NH -> C
            HB -> C
            HC -> B
            HN -> C
            NN -> C
            BH -> H
            NC -> B
            NB -> B
            BN -> B
            BB -> N
            BC -> B
            CC -> N
            CN -> C
            """.components(separatedBy: .newlines).filter { $0.count > 0 }
        let template = lines[0]
        let rules = lines[1...].map(PairInsertionRule.init)
        let evaluator = PairInsertionRuleEvaluator(rules: rules)
        let output = evaluator.evaluate(against: template, for: 10)
        XCTAssertEqual(output, 1588)
    }

    func test40StepsWithSampleInput() {
        // Arrange
        let lines = """
            NNCB

            CH -> B
            HH -> N
            CB -> H
            NH -> C
            HB -> C
            HC -> B
            HN -> C
            NN -> C
            BH -> H
            NC -> B
            NB -> B
            BN -> B
            BB -> N
            BC -> B
            CC -> N
            CN -> C
            """.components(separatedBy: .newlines).filter { $0.count > 0 }
        let template = lines[0]
        let rules = lines[1...].map(PairInsertionRule.init)
        let evaluator = PairInsertionRuleEvaluator(rules: rules)
        let output = evaluator.evaluate(against: template, for: 40)
        XCTAssertEqual(output, 2_188_189_693_529)
    }

    func test10StepsWithDay14Input() {
        // Arrange
        let lines = InputFile(bundle: Bundle.module, day: 14).loadLines().filter { $0.count > 0 }
        let template = lines[0]
        let rules = lines[1...].map(PairInsertionRule.init)
        let evaluator = PairInsertionRuleEvaluator(rules: rules)
        let output = evaluator.evaluate(against: template, for: 10)
        XCTAssertEqual(output, 3009)
    }

    func test40StepsWithDay14Input() {
        // Arrange
        let lines = InputFile(bundle: Bundle.module, day: 14).loadLines().filter { $0.count > 0 }
        let template = lines[0]
        let rules = lines[1...].map(PairInsertionRule.init)
        let evaluator = PairInsertionRuleEvaluator(rules: rules)
        let output = evaluator.evaluate(against: template, for: 40)
        XCTAssertEqual(output, 3_459_822_539_451)
    }
}
