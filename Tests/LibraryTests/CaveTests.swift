import AdventOfCode
import XCTest

@testable import Library

class CaveTests: XCTestCase {
    func testCountPathsNoSmallCaveRevisitPolicyWithSmallSampleInput() {
        // Arrange
        let lines = """
            start-A
            start-b
            A-c
            A-b
            b-d
            A-end
            b-end
            """.components(separatedBy: .newlines)
        let graph = CaveNetwork(lines: lines, visitPolicy: NoSmallCaveRevisitPolicy())

        // Act
        let pathCount = graph.countPaths()

        // Assert
        XCTAssertEqual(pathCount, 10)
    }

    func testCountPathsNoSmallCaveRevisitPolicyWithMediumSampleInput() {
        // Arrange
        let lines = """
            dc-end
            HN-start
            start-kj
            dc-start
            dc-HN
            LN-dc
            HN-end
            kj-sa
            kj-HN
            kj-dc
            """.components(separatedBy: .newlines)
        let graph = CaveNetwork(lines: lines, visitPolicy: NoSmallCaveRevisitPolicy())

        // Act
        let pathCount = graph.countPaths()

        // Assert
        XCTAssertEqual(pathCount, 19)
    }

    func testCountPathsNoSmallCaveRevisitPolicyWithLargeSampleInput() {
        // Arrange
        let lines = """
            fs-end
            he-DX
            fs-he
            start-DX
            pj-DX
            end-zg
            zg-sl
            zg-pj
            pj-he
            RW-he
            fs-DX
            pj-RW
            zg-RW
            start-pj
            he-WI
            zg-he
            pj-fs
            start-RW
            """.components(separatedBy: .newlines)
        let graph = CaveNetwork(lines: lines, visitPolicy: NoSmallCaveRevisitPolicy())

        // Act
        let pathCount = graph.countPaths()

        // Assert
        XCTAssertEqual(pathCount, 226)
    }

    func testCountPathsNoSmallCaveRevisitPolicyWithDay12Input() {
        // Arrange
        let lines = InputFile(bundle: Bundle.module, day: 12).loadLines().filter { $0.count > 0 }
        let graph = CaveNetwork(lines: lines, visitPolicy: NoSmallCaveRevisitPolicy())

        // Act
        let pathCount = graph.countPaths()

        // Assert
        XCTAssertEqual(pathCount, 3410)
    }

    func testCountPathsSingleSmallCaveRevisitPolicyWithSmallSampleInput() {
        // Arrange
        let lines = """
            start-A
            start-b
            A-c
            A-b
            b-d
            A-end
            b-end
            """.components(separatedBy: .newlines)
        let graph = CaveNetwork(lines: lines, visitPolicy: SingleSmallCaveRevisitPolicy())

        // Act
        let pathCount = graph.countPaths()

        // Assert
        XCTAssertEqual(pathCount, 36)
    }

    func testCountPathsSingleSmallCaveRevisitPolicyWithMediumSampleInput() {
        // Arrange
        let lines = """
            dc-end
            HN-start
            start-kj
            dc-start
            dc-HN
            LN-dc
            HN-end
            kj-sa
            kj-HN
            kj-dc
            """.components(separatedBy: .newlines)
        let graph = CaveNetwork(lines: lines, visitPolicy: SingleSmallCaveRevisitPolicy())

        // Act
        let pathCount = graph.countPaths()

        // Assert
        XCTAssertEqual(pathCount, 103)
    }

    func testCountPathsSingleSmallCaveRevisitPolicyWithLargeSampleInput() {
        // Arrange
        let lines = """
            fs-end
            he-DX
            fs-he
            start-DX
            pj-DX
            end-zg
            zg-sl
            zg-pj
            pj-he
            RW-he
            fs-DX
            pj-RW
            zg-RW
            start-pj
            he-WI
            zg-he
            pj-fs
            start-RW
            """.components(separatedBy: .newlines)
        let graph = CaveNetwork(lines: lines, visitPolicy: SingleSmallCaveRevisitPolicy())

        // Act
        let pathCount = graph.countPaths()

        // Assert
        XCTAssertEqual(pathCount, 3509)
    }

    func testCountPathsSingleSmallCaveRevisitPolicyWithDay12Input() {
        // Arrange
        let lines = InputFile(bundle: Bundle.module, day: 12).loadLines().filter { $0.count > 0 }
        let graph = CaveNetwork(lines: lines, visitPolicy: SingleSmallCaveRevisitPolicy())

        // Act
        let pathCount = graph.countPaths()

        // Assert
        XCTAssertEqual(pathCount, 98796)
    }
}
