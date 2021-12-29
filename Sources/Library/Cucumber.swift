import Foundation

/// Simulates the movement of sea cucumbers.
public struct Cucumbers {
    private let grid: [[Direction?]]
    private let height: Int
    private let width: Int

    /// Creates the initial state of sea cucumber positions.
    ///
    /// - Parameter lines: A textual representation of sea cucumbers.
    public init(lines: [String]) {
        self.height = lines.count
        self.width = lines[0].count
        var grid: [[Direction?]] = Array(
            repeating: Array(repeating: nil, count: self.width), count: self.height)

        for (r, line) in lines.enumerated() {
            for (c, character) in line.enumerated() {
                grid[r][c] = Direction(rawValue: character)
            }
        }

        self.grid = grid
    }

    /// Simulates the movement of sea cucumbers until movement is no longer possible.
    ///
    /// - Returns: The number of steps taken until movement is no longer possible.
    public func simulate() -> Int {
        var stepCount = 0
        var changesDuringStep = true
        var currentGrid = self.grid

        while changesDuringStep {
            stepCount += 1
            changesDuringStep = false

            for direction in Direction.allCases {
                var nextGrid = currentGrid

                for r in currentGrid.indices {
                    for c in currentGrid[r].indices {
                        if currentGrid[r][c] == direction {
                            let (nextRow, nextColumn) = direction.nextLocation(
                                row: r, column: c, height: self.height, width: self.width)
                            if currentGrid[nextRow][nextColumn] == nil {
                                nextGrid[r][c] = nil
                                nextGrid[nextRow][nextColumn] = direction
                                changesDuringStep = true
                            }
                        }
                    }
                }

                currentGrid = nextGrid
            }
        }

        return stepCount
    }
}

private enum Direction: Character, CaseIterable {
    case east = ">"
    case south = "v"

    func nextLocation(row: Int, column: Int, height: Int, width: Int) -> (row: Int, column: Int) {
        switch self {
        case .east:
            return (row: row, column: (column + 1) % width)
        case .south:
            return (row: (row + 1) % height, column: column)
        }
    }
}
