import Foundation

/// Simulates steps of energy growth and distribution among a two-dimensional space of entities.
public class EnergySimulator {
    private var grid: [[Int]]

    /// Creates a new instance.
    ///
    /// - Parameter grid: A two-dimensional space of initial energy values.
    public init(grid: [[Int]]) {
        self.grid = grid
    }

    /// Simulates a number of steps.
    ///
    /// - Parameter steps: The number of steps to simulate.
    /// - Returns: The total number of energy flashes that took place.
    public func simulate(for steps: Int) -> Int {
        var grid = self.grid
        return EnergySimulator.simulate(with: &grid, for: steps)
    }

    /// Simulates one or more steps until all entities flash within a single step.
    ///
    /// - Returns: The number of steps needed to reach a synchronized flash.
    public func simulateUntilSynchronized() -> Int {
        // Operate on a copy of the grid
        var grid = self.grid

        // Keep track of steps simulated and the last step's flash count
        var stepCount = 0
        var flashCount = 0

        // Stop once all points have flashed
        let totalPoints = grid.count * grid[0].count

        // Until synchronized
        while flashCount != totalPoints {
            // Simulate one step
            flashCount = EnergySimulator.simulate(with: &grid, for: 1)
            stepCount += 1
        }

        return stepCount
    }

    private static func simulate(with grid: inout [[Int]], for steps: Int) -> Int {
        var flashCount = 0

        // Iterate through steps
        for _ in 1...steps {
            var flashQueue = VisitedQueue<TwoDimensionalPoint>()

            // Perform initial pass to increase all energy levels
            for i in grid.indices {
                for j in grid[i].indices {
                    grid[i][j] += 1

                    if grid[i][j] == 10 {
                        flashQueue.enqueue(TwoDimensionalPoint(row: i, column: j))
                    }
                }
            }

            // Evaluate flashes
            while !flashQueue.isEmpty {
                let point = flashQueue.dequeue()
                let neighbors = EnergySimulator.neighbors(grid: grid, point: point)

                for neighbor in neighbors {
                    grid[neighbor.row][neighbor.column] += 1

                    if grid[neighbor.row][neighbor.column] > 9 {
                        flashQueue.enqueue(neighbor)
                    }
                }
            }

            // Set flashed points back to zero
            for flashedPoint in flashQueue.visited {
                grid[flashedPoint.row][flashedPoint.column] = 0
            }

            flashCount += flashQueue.enqueuedCount
        }

        return flashCount
    }

    private static func neighbors(grid: [[Int]], point: TwoDimensionalPoint)
        -> [TwoDimensionalPoint]
    {
        var neighbors = [TwoDimensionalPoint]()

        // Consider all neighbors horizontally, vertically, or diagonally adjacent to specified point
        for di in -1...1 {
            for dj in -1...1 {
                if !(di == 0 && dj == 0) {
                    let i = point.row + di
                    let j = point.column + dj
                    if grid.indices.contains(i) && grid[i].indices.contains(j) {
                        neighbors.append(TwoDimensionalPoint(row: i, column: j))
                    }
                }
            }
        }

        return neighbors
    }
}
