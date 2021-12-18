import AdventOfCode
import XCTest

@testable import Library

class SnailfishTests: XCTestCase {
    func testMagnitude() {
        // Arrange
        let description = "[[1,2],[[3,4],5]]"

        // Act
        let number = SnailfishNumber(description)!

        // Assert
        XCTAssertEqual(number.magnitude, 143)
    }

    func testAddition() {
        // Arrange
        let lhs = SnailfishNumber("[1,2]")!
        let rhs = SnailfishNumber("[[3,4],5]")!

        // Act
        let sum = lhs + rhs

        // Assert
        XCTAssertEqual(sum.description, "[[1,2],[[3,4],5]]")
    }

    func testAdditionWithReduction() {
        // Arrange
        let lhs = SnailfishNumber("[[[[4,3],4],4],[7,[[8,4],9]]]")!
        let rhs = SnailfishNumber("[1,1]")!

        // Act
        let sum = lhs + rhs

        // Assert
        XCTAssertEqual(sum.description, "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]")
    }

    func testWithSampleInput() {
        // Arrange
        let lines = """
            [[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
            [[[5,[2,8]],4],[5,[[9,9],0]]]
            [6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
            [[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
            [[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
            [[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
            [[[[5,4],[7,7]],8],[[8,3],8]]
            [[9,3],[[9,9],[6,[4,9]]]]
            [[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
            [[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
            """.components(separatedBy: .newlines)
        let numbers =
            lines
            .map { SnailfishNumber($0)! }

        // Act
        let sum = numbers[1...]
            .reduce(numbers[0]) { $0 + $1 }

        // Assert
        XCTAssertEqual(sum.magnitude, 4140)
    }

    func testWithDay18Input() {
        // Arrange
        let numbers = InputFile(bundle: Bundle.module, day: 18).loadLines()
            .filter { $0.count > 0 }
            .map { SnailfishNumber($0)! }

        // Act
        let sum = numbers[1...]
            .reduce(numbers[0]) { $0 + $1 }

        // Assert
        XCTAssertEqual(sum.magnitude, 3051)
    }

    func testWithSampleInputToFindMaxMagnitude() {
        // Arrange
        let lines = """
            [[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
            [[[5,[2,8]],4],[5,[[9,9],0]]]
            [6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
            [[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
            [[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
            [[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
            [[[[5,4],[7,7]],8],[[8,3],8]]
            [[9,3],[[9,9],[6,[4,9]]]]
            [[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
            [[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
            """.components(separatedBy: .newlines)
        let numbers =
            lines
            .map { SnailfishNumber($0)! }

        // Act
        var maxMagnitude = 0
        for (i, n1) in numbers.enumerated() {
            for (j, n2) in numbers.enumerated() {
                if i != j {
                    let sum = n1 + n2
                    maxMagnitude = max(maxMagnitude, sum.magnitude)
                }
            }
        }

        // Assert
        XCTAssertEqual(maxMagnitude, 3993)
    }

    func testWithDay18InputToFindMaxMagnitude() {
        // Arrange
        let numbers = InputFile(bundle: Bundle.module, day: 18).loadLines()
            .filter { $0.count > 0 }
            .map { SnailfishNumber($0)! }

        // Act
        var maxMagnitude = 0
        for (i, n1) in numbers.enumerated() {
            for (j, n2) in numbers.enumerated() {
                if i != j {
                    let sum = n1 + n2
                    maxMagnitude = max(maxMagnitude, sum.magnitude)
                }
            }
        }

        // Assert
        XCTAssertEqual(maxMagnitude, 4812)
    }
}
