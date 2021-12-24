import AdventOfCode
import XCTest

@testable import Library

class ArithmeticTests: XCTestCase {
    func testRunWithAllOperationsAndVariables() {
        // Arrange
        let instructions = """
            inp w
            add w 2
            inp x
            mul w x
            inp y
            mod w y
            add w 2
            eql w y
            add z w
            div y 3
            add z y
            """.components(separatedBy: .newlines)
            .map { Instruction(description: $0) }
        let program = Program(instructions: instructions)
        let input = "359"

        // Act
        let output = program.run(input: input)

        // Assert
        XCTAssertEqual(output, 4)
    }

    func testDay24Input() {
        // Arrange
        let instructions = InputFile(bundle: Bundle.module, day: 24)
            .loadLines()
            .filter { $0.count > 0 }
            .map { Instruction(description: $0) }
        let program = Program(instructions: instructions)

        // Act
        let candidates = program.solve().sorted()

        // Assert
        let maximum = candidates.last!
        let minimum = candidates.first!
        XCTAssertEqual(program.run(input: maximum), 0)
        XCTAssertEqual(program.run(input: minimum), 0)
        XCTAssertEqual("29991993698469", maximum)
        XCTAssertEqual("14691271141118", minimum)
    }
}
