import AdventOfCode
import Foundation

/// Represents a foldable paper comprised of dots.
public struct Paper {
    /// The number of dots present on the paper.
    public let dotCount: Int
    internal let grid: [[Bool]]
    private let width: Int
    private let height: Int

    /// Creates a new instance.
    ///
    /// - Parameter grid: A two-dimensional grid of booleans with `true` values representing dots.
    public init(grid: [[Bool]]) {
        self.grid = grid
        dotCount = grid.flatMap { $0 }.filter { $0 }.count
        self.width = grid[0].count
        self.height = grid.count
    }

    /// Creates a new instance.
    ///
    /// - Parameter dots: An array of two-dimensional points of dots on the paper.
    public init(dots: [TwoDimensionalPoint<Int>]) {
        let maxX =
            dots
            .map { $0.x }
            .max()!
        let maxY =
            dots
            .map { $0.y }
            .max()!

        var grid = Array(repeating: Array(repeating: false, count: maxX + 1), count: maxY + 1)
        for dot in dots {
            grid[dot.y][dot.x] = true
        }
        self.init(grid: grid)
    }

    /// Folds the paper left at an x coordinate.
    ///
    /// - Parameter x: The x coordinate at which to fold the paper.
    /// - Returns: A new paper instance representing the folded version of the paper.
    public func foldLeft(at x: Int) -> Paper {
        let newWidth: Int
        let originalStart: Int
        let originalEnd: Int

        if x >= self.width / 2 {
            newWidth = x
            originalStart = 0
            originalEnd = x + newWidth
        } else {
            newWidth = self.width - 1 - x
            originalStart = -1 * x
            originalEnd = x + newWidth
        }

        var newGrid = Array(repeating: Array(repeating: false, count: newWidth), count: height)

        for r in newGrid.indices {
            for c in newGrid[r].indices {
                for i in [originalStart + c, originalEnd - c] {
                    if self.grid[r].indices.contains(i) {
                        newGrid[r][c] = newGrid[r][c] || self.grid[r][i]
                    }
                }
            }
        }

        return Paper(grid: newGrid)
    }

    /// Folds the paper up at a y coordinate.
    ///
    /// - Parameter y: The y coordinate at which to fold the paper.
    /// - Returns: A new paper instance representing the folded version of the paper.
    public func foldUp(at y: Int) -> Paper {
        let newHeight: Int
        let originalStart: Int
        let originalEnd: Int

        if y >= self.height / 2 {
            newHeight = y
            originalStart = 0
            originalEnd = y + newHeight
        } else {
            newHeight = self.height - 1 - y
            originalStart = -1 * y
            originalEnd = y + newHeight
        }

        var newGrid = Array(repeating: Array(repeating: false, count: self.width), count: newHeight)

        for r in newGrid.indices {
            for c in newGrid[r].indices {
                for i in [originalStart + r, originalEnd - r] {
                    if self.grid.indices.contains(i) {
                        newGrid[r][c] = newGrid[r][c] || self.grid[i][c]
                    }
                }
            }
        }

        return Paper(grid: newGrid)
    }

    /// Displays the contents of the paper to standard output.
    public func display() {
        for row in self.grid {
            var string = ""
            for cell in row {
                string += cell ? "#" : "."
            }
            print(string)
        }
    }
}
