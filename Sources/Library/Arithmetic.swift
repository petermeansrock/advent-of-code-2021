import Collections
import Foundation

/// A program represents set of instructions that can be run on an arithmetic logic unit (ALU).
public struct Program {
    private let instructions: [Instruction]
    private let chunkedInstructions: [[Instruction]]

    /// Creates a program from a set of instructions.
    ///
    /// - Parameter instructions: The instructions comprising the program.
    init(instructions: [Instruction]) {
        self.instructions = instructions
        self.chunkedInstructions = self.instructions.chunked(into: 18)
    }

    /// Runs the program.
    ///
    /// - Parameter input: the input on which to run the program
    /// - Returns: The output of the program
    func run(input: String) -> Int {
        // Prepare input
        var digits =
            input
            .map { $0.wholeNumberValue }

        // Instantiate memory
        var memory = Memory()

        // Loop through all instructions
        for instruction in instructions {
            if instruction.operation == .input {
                memory.write(variable: instruction.firstOperand, value: digits.removeFirst()!)
            } else {
                let firstValue = memory.read(variable: instruction.firstOperand)
                let secondValue = instruction.secondOperand!.lookup(memory: memory)
                memory.write(
                    variable: instruction.firstOperand,
                    value: instruction.operation.perform(
                        firstOperand: firstValue, secondOperand: secondValue)!)
            }
        }

        // Return value of variable "z"
        return memory.read(variable: .z)
    }

    /// Determines all candidate input values that are considered valid (e.g., will produce an
    /// output value of `0` when run.
    ///
    /// - Returns: The list of all valid candidate input values.
    func solve() -> [String] {
        // Keep track of the rules between digits
        var rules = [DigitRelationship]()

        // Keep a stack of retained values and the digit of the input to which they map
        var stack = Deque<RetainedDigit>()

        // Loop through chunk for each digit to determine relationship between digits
        for (i, chunk) in chunkedInstructions.enumerated() {
            let divisor = Divisor(rawValue: (chunk[4].secondOperand as! LiteralOperand).value)!
            switch divisor {
            case .push:
                let addendToRetain = (chunk[15].secondOperand as! LiteralOperand).value
                let digit = RetainedDigit(index: i, addend: addendToRetain)
                stack.append(digit)
            case .pop:
                let addendToExamine = (chunk[5].secondOperand as! LiteralOperand).value
                let digit = stack.removeLast()
                let delta = digit.addend + addendToExamine
                rules.append(
                    DigitRelationship(
                        sourceDigitIndex: digit.index, targetDigitIndex: i, targetDelta: delta))
            }
        }

        // Consider all combinations of possible digits based on rules
        var possibilities: [DigitPossibility] = []
        for rule in rules {
            let rulePossibilities = rule.possibilities
            if possibilities.isEmpty {
                possibilities = rulePossibilities
            } else {
                var newPossibilities: [DigitPossibility] = []
                for possibilitySoFar in possibilities {
                    for rulePossibility in rulePossibilities {
                        var availableDigits: [Digit] = []
                        availableDigits.append(contentsOf: possibilitySoFar.digits)
                        availableDigits.append(contentsOf: rulePossibility.digits)
                        newPossibilities.append(DigitPossibility(digits: availableDigits))
                    }
                }
                possibilities = newPossibilities
            }
        }

        // Build list of valid input values based on possibilities
        var candidates: [String] = []
        for possibility in possibilities {
            // TODO: Don't hardcode 14 digits
            var candidate = Array(repeating: 0, count: 14)
            for digit in possibility.digits {
                candidate[digit.index] = digit.value
            }
            candidates.append(candidate.map { String($0) }.joined())
        }

        return candidates
    }
}

private struct DigitRelationship {
    fileprivate let sourceDigitIndex: Int
    fileprivate let targetDigitIndex: Int
    fileprivate let targetDelta: Int
    fileprivate var possibilities: [DigitPossibility] {
        var possibilities: [DigitPossibility] = []
        let min: Int
        let max: Int
        if targetDelta < 0 {
            min = abs(targetDelta) + 1
            max = 9
        } else {
            min = 1
            max = 9 - targetDelta
        }
        for i in min...max {
            possibilities.append(
                DigitPossibility(digits: [
                    Digit(index: sourceDigitIndex, value: i),
                    Digit(index: targetDigitIndex, value: i + targetDelta),
                ]))
        }
        return possibilities
    }
}

private struct RetainedDigit {
    fileprivate let index: Int
    fileprivate let addend: Int
}

private enum Divisor: Int {
    case push = 1
    case pop = 26
}

private struct Digit {
    fileprivate let index: Int
    fileprivate let value: Int
}

private struct DigitPossibility {
    fileprivate let digits: [Digit]
}

/// An instruction represents an operation that can be performed as part of a program along with its
/// associated operands.
public struct Instruction: CustomStringConvertible {
    fileprivate let operation: InstructionOperation
    fileprivate let firstOperand: Variable
    fileprivate let secondOperand: Operand?
    /// The string representation of an instruction.
    public let description: String

    init(description: String) {
        self.description = description
        let parts = description.split(separator: " ", maxSplits: 1)
        let operands = parts[1].split(separator: " ")
        self.operation = InstructionOperation(rawValue: String(parts[0]))!
        self.firstOperand = Variable(rawValue: String(operands[0]))!

        if operands.count > 1 {
            if let integerOperand = Int(operands[1]) {
                self.secondOperand = LiteralOperand(value: integerOperand)
            } else {
                self.secondOperand = MemoryOperand(
                    variable: Variable(rawValue: String(operands[1]))!)
            }
        } else {
            self.secondOperand = nil
        }
    }
}

private struct Memory: ReadOnlyMemory, WriteOnlyMemory {
    private var memory = [Variable: Int]()

    func read(variable: Variable) -> Int {
        return memory[variable, default: 0]
    }

    mutating func write(variable: Variable, value: Int) {
        memory[variable] = value
    }

}

private protocol ReadOnlyMemory {
    func read(variable: Variable) -> Int
}

private protocol WriteOnlyMemory {
    mutating func write(variable: Variable, value: Int)
}

private protocol Operand {
    func lookup(memory: ReadOnlyMemory) -> Int
}

private struct LiteralOperand: Operand {
    fileprivate let value: Int

    func lookup(memory: ReadOnlyMemory) -> Int {
        return self.value
    }
}

private struct MemoryOperand: Operand {
    fileprivate let variable: Variable

    func lookup(memory: ReadOnlyMemory) -> Int {
        return memory.read(variable: self.variable)
    }
}

private enum InstructionOperation: String {
    case input = "inp"
    case add = "add"
    case multiply = "mul"
    case division = "div"
    case modulo = "mod"
    case equals = "eql"

    func perform(firstOperand: Int, secondOperand: Int) -> Int? {
        switch self {
        case .add:
            return firstOperand + secondOperand
        case .multiply:
            return firstOperand * secondOperand
        case .division:
            return firstOperand / secondOperand
        case .modulo:
            return firstOperand % secondOperand
        case .equals:
            return firstOperand == secondOperand ? 1 : 0
        default:
            return nil
        }
    }
}

private enum Variable: String {
    case w = "w"
    case x = "x"
    case y = "y"
    case z = "z"
}
