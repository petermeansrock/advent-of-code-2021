import AdventOfCode
import XCTest

@testable import Library

class EhanceTests: XCTestCase {
    func testTwoEnhancementsWithSampleInput() {
        // Arrange
        let lines = """
            ..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..##\
            #..######.###...####..#..#####..##..#.#####...##.#.#..#.##..#.#......#.###\
            .######.###.####...#.##.##..#..#..#####.....#.#....###..#.##......#.....#.\
            .#..#..##..#...##.######.####.####.#.#...#.......#..#.#.#...####.##.#.....\
            .#..#...##.#.##..#...##.#.##..###.#......#.#.......#.#.#.####.###.##...#..\
            ...####.#..#..#.##.#....##..#.####....##...##..#...#......#.#.......#.....\
            ..##..####..#...#.#.#...##..#.#..###..#####........#..####......#..#

            #..#.
            #....
            ##..#
            ..#..
            ..###

            """.components(separatedBy: .newlines)
        let chunks = loadLineChunks(lines: lines)
        let algorithm = EnhancementAlgorithm(algorithm: chunks[0][0])
        let image = Image(lines: chunks[1])

        // Act
        var currentImage = image
        image.display()
        print()
        for _ in 1...2 {
            currentImage = algorithm.enhance(image: currentImage)
            currentImage.display()
            print()
        }

        // Assert
        XCTAssertEqual(currentImage.litPixelCount, 35)
    }

    func testFiftyEnhancementsWithSampleInput() {
        // Arrange
        let lines = """
            ..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..##\
            #..######.###...####..#..#####..##..#.#####...##.#.#..#.##..#.#......#.###\
            .######.###.####...#.##.##..#..#..#####.....#.#....###..#.##......#.....#.\
            .#..#..##..#...##.######.####.####.#.#...#.......#..#.#.#...####.##.#.....\
            .#..#...##.#.##..#...##.#.##..###.#......#.#.......#.#.#.####.###.##...#..\
            ...####.#..#..#.##.#....##..#.####....##...##..#...#......#.#.......#.....\
            ..##..####..#...#.#.#...##..#.#..###..#####........#..####......#..#

            #..#.
            #....
            ##..#
            ..#..
            ..###

            """.components(separatedBy: .newlines)
        let chunks = loadLineChunks(lines: lines)
        let algorithm = EnhancementAlgorithm(algorithm: chunks[0][0])
        let image = Image(lines: chunks[1])

        // Act
        var currentImage = image
        for _ in 1...50 {
            currentImage = algorithm.enhance(image: currentImage)
        }

        // Assert
        XCTAssertEqual(currentImage.litPixelCount, 3351)
    }

    func testTwoEnhancementsWithDay20Input() {
        // Arrange
        let chunks = InputFile(bundle: Bundle.module, day: 20).loadLineChunks()
        let algorithm = EnhancementAlgorithm(algorithm: chunks[0][0])
        let image = Image(lines: chunks[1])

        // Act
        var currentImage = image
        for _ in 1...2 {
            currentImage = algorithm.enhance(image: currentImage)
        }

        // Assert
        XCTAssertEqual(currentImage.litPixelCount, 5503)
    }

    func testFiftyEnhancementsWithDay20Input() {
        // Arrange
        let chunks = InputFile(bundle: Bundle.module, day: 20).loadLineChunks()
        let algorithm = EnhancementAlgorithm(algorithm: chunks[0][0])
        let image = Image(lines: chunks[1])

        // Act
        var currentImage = image
        for _ in 1...50 {
            currentImage = algorithm.enhance(image: currentImage)
        }

        // Assert
        XCTAssertEqual(currentImage.litPixelCount, 19156)
    }

    func loadLineChunks(lines: [String]) -> [[String]] {
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
