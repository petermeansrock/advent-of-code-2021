import AdventOfCode
import XCTest

@testable import Library

class PaperTests: XCTestCase {
    func testFoldLeftCentered() {
        // Arrange
        let grid = [
            [false, true, false, false, true]
        ]
        let paper = Paper(grid: grid)

        // Act
        let foldedGrid = paper.foldLeft(at: 2).grid

        // Assert
        XCTAssertEqual(foldedGrid[0], [true, true])
    }

    func testFoldLeftOffCenteredToTheLeft() {
        // Arrange
        let grid = [
            [true, true, false, true, true]
        ]
        let paper = Paper(grid: grid)

        // Act
        let foldedGrid = paper.foldLeft(at: 1).grid

        // Assert
        XCTAssertEqual(foldedGrid[0], [true, true, true])
    }

    func testFoldLeftOffCenteredToTheRight() {
        // Arrange
        let grid = [
            [true, true, false, false, true]
        ]
        let paper = Paper(grid: grid)

        // Act
        let foldedGrid = paper.foldLeft(at: 3).grid

        // Assert
        XCTAssertEqual(foldedGrid[0], [true, true, true])
    }

    func testFoldUpCentered() {
        // Arrange
        let grid = [
            [false],
            [true],
            [false],
            [false],
            [true],
        ]
        let paper = Paper(grid: grid)

        // Act
        let foldedGrid = paper.foldUp(at: 2).grid

        // Assert
        XCTAssertEqual(
            foldedGrid,
            [
                [true],
                [true],
            ])
    }

    func testFoldUpOffCenteredToTheTop() {
        // Arrange
        let grid = [
            [true],
            [true],
            [false],
            [true],
            [true],
        ]
        let paper = Paper(grid: grid)

        // Act
        let foldedGrid = paper.foldUp(at: 1).grid

        // Assert
        XCTAssertEqual(
            foldedGrid,
            [
                [true],
                [true],
                [true],
            ])
    }

    func testFoldUpOffCenteredToTheBottom() {
        // Arrange
        let grid = [
            [true],
            [true],
            [false],
            [false],
            [true],
        ]
        let paper = Paper(grid: grid)

        // Act
        let foldedGrid = paper.foldUp(at: 3).grid

        // Assert
        XCTAssertEqual(
            foldedGrid,
            [
                [true],
                [true],
                [true],
            ])
    }

    func testOneFoldWithSampleInput() {
        // Arrange
        let lines = """
            6,10
            0,14
            9,10
            0,3
            10,4
            4,11
            6,0
            6,12
            4,1
            0,13
            10,12
            3,4
            3,0
            8,4
            1,10
            2,14
            8,10
            9,0

            fold along y=7
            fold along x=5

            """.components(separatedBy: .newlines)
        let chunks = PaperTests.loadLineChunks(lines: lines)
        let dots = chunks[0]
            .map { $0.components(separatedBy: ",") }
            .map { (Int($0[0])!, Int($0[1])!) }
            .map(TwoDimensionalPoint.init)
        let paper = Paper(dots: dots)

        // Act
        let dotCount = paper.foldUp(at: 7).dotCount

        // Assert
        XCTAssertEqual(dotCount, 17)
    }

    func testOneFoldWithDay13Input() {
        let chunks = InputFile(bundle: Bundle.module, day: 13).loadLineChunks()
        let dots = chunks[0]
            .map { $0.components(separatedBy: ",") }
            .map { (Int($0[0])!, Int($0[1])!) }
            .map(TwoDimensionalPoint.init)
        let paper = Paper(dots: dots)

        // Act
        let dotCount = paper.foldLeft(at: 655).dotCount

        // Assert
        XCTAssertEqual(dotCount, 781)
    }

    func testAllFoldsWithSampleInput() {
        // Arrange
        let lines = """
            6,10
            0,14
            9,10
            0,3
            10,4
            4,11
            6,0
            6,12
            4,1
            0,13
            10,12
            3,4
            3,0
            8,4
            1,10
            2,14
            8,10
            9,0

            fold along y=7
            fold along x=5

            """.components(separatedBy: .newlines)
        let chunks = PaperTests.loadLineChunks(lines: lines)
        let dots = chunks[0]
            .map { $0.components(separatedBy: ",") }
            .map { (Int($0[0])!, Int($0[1])!) }
            .map(TwoDimensionalPoint.init)
        var paper = Paper(dots: dots)

        // Act
        for fold in chunks[1] {
            let parts = fold.components(separatedBy: "=")
            if parts[0].contains("y") {
                paper = paper.foldUp(at: Int(parts[1])!)
            } else {
                paper = paper.foldLeft(at: Int(parts[1])!)
            }
        }
        let dotCount = paper.dotCount

        // Assert
        XCTAssertEqual(dotCount, 16)
        paper.display()
    }

    func testAllFoldsWithDay13Input() {
        let chunks = InputFile(bundle: Bundle.module, day: 13).loadLineChunks()
        let dots = chunks[0]
            .map { $0.components(separatedBy: ",") }
            .map { (Int($0[0])!, Int($0[1])!) }
            .map(TwoDimensionalPoint.init)
        var paper = Paper(dots: dots)

        // Act
        for fold in chunks[1] {
            let parts = fold.components(separatedBy: "=")
            if parts[0].contains("y") {
                paper = paper.foldUp(at: Int(parts[1])!)
            } else {
                paper = paper.foldLeft(at: Int(parts[1])!)
            }
        }
        let dotCount = paper.dotCount

        // Assert
        XCTAssertEqual(dotCount, 99)
        paper.display()
    }

    private static func loadLineChunks(lines: [String]) -> [[String]] {
        var chunks = [[String]]()
        var chunk = [String]()
        for line in lines {
            if line.count == 0 {
                // On blank lines, record previous chunk and create a new one
                chunks.append(chunk)
                chunk = []
            } else {
                // Otherwise, record line as part of current chunk
                chunk.append(line)
            }
        }

        return chunks
    }
}
