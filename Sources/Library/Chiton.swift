import AdventOfCode
import Foundation
import SwiftPriorityQueue

internal struct TwoDimensionalPointWithWeight: Comparable, Hashable {
    let x: Int
    let y: Int
    let weight: Int

    static func < (lhs: TwoDimensionalPointWithWeight, rhs: TwoDimensionalPointWithWeight) -> Bool {
        return lhs.weight < rhs.weight
    }

    /// Hashes the essential components of this value by feeding them into the given hasher.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.x)
        hasher.combine(self.y)
        hasher.combine(self.weight)
    }
}

/// Represents a weighted graph.
public struct WeightedGraph {
    private let grid: [[Int]]

    /// Creates a new instance.
    ///
    /// - Parameter grid: A grid of weights representing the cost of entering a node.
    public init(grid: [[Int]]) {
        self.grid = grid
    }

    /// Creates a new instance.
    ///
    /// - Parameters:
    ///   - grid: A grid of weights representing the cost of entering a node.
    ///   - multiplier: A multiplier to use to expand the supplied grid into a larger grid.
    public init(grid: [[Int]], multiplier: Int) {
        let originalHeight = grid.count
        let originalWidth = grid[0].count
        var multipliedGrid = Array(
            repeating: Array(repeating: 0, count: originalWidth * multiplier),
            count: originalHeight * multiplier)

        for r in multipliedGrid.indices {
            for c in multipliedGrid[r].indices {
                // Determine original row and column associated with this cell
                let originalRow = r % originalHeight
                let originalColumn = c % originalWidth

                // Determine the index of the row and column tiles
                let rowTile = r / originalHeight
                let columnTile = c / originalWidth
                let tileCount = rowTile + columnTile

                // Increase the original value by the total combined tile count
                let unwrappedValue = grid[originalRow][originalColumn] + tileCount

                // Values above 9 should be wrapped back to 1
                let wrappedValue = (unwrappedValue - 1) % 9 + 1
                multipliedGrid[r][c] = wrappedValue
            }
        }

        self.init(grid: multipliedGrid)
    }

    /// Returns the cost of the cheapest path from the start node (the top-left of the underlying
    /// grid) to the end node (the bottom-right of the underlying grid).
    ///
    /// - Returns: The cost of the cheapest path from the start node to the end node.
    public func findPathWithLowestRisk() -> Int {
        // Use a two-dimensional array to represent the "shortest path" (or lowest risk levels) from
        // the start node to each node in the grid
        var shortestPathFromStart = Array(
            repeating: Array(repeating: Int.max, count: self.grid[0].count), count: self.grid.count)
        shortestPathFromStart[0][0] = 0

        // Keep track of all unvisited nodes
        var allUnvisitedNodes = Set<TwoDimensionalPoint<Int>>()
        for r in shortestPathFromStart.indices {
            for c in shortestPathFromStart[r].indices {
                allUnvisitedNodes.insert(TwoDimensionalPoint(x: c, y: r))
            }
        }
        var unvisitedNodesWithCost = PriorityQueue(
            ascending: true, startingValues: [TwoDimensionalPointWithWeight(x: 0, y: 0, weight: 0)])

        // Use Dijkstra's algorithm to determine the shortest path to end node
        while !unvisitedNodesWithCost.isEmpty {
            // Start on unvisited node with shortest distance
            let currentNode = unvisitedNodesWithCost.pop()!
            allUnvisitedNodes.remove(TwoDimensionalPoint(x: currentNode.x, y: currentNode.y))

            if currentNode.y == self.grid.endIndex - 1 && currentNode.x == self.grid[0].endIndex - 1
            {
                break
            }

            // Loop through all unvisited neighbors
            let neighbors = grid.neighbors(
                row: currentNode.y, column: currentNode.x,
                adjacencies: Set([.horizontal, .vertical]))
            let unvisitedNeighbors =
                neighbors
                .map { TwoDimensionalPoint(x: $0.column, y: $0.row) }
                .filter { allUnvisitedNodes.contains($0) }
            for neighbor in unvisitedNeighbors {
                // Look up the previous distance from the start node to this neighbor
                let previousDistance = shortestPathFromStart[neighbor.y][neighbor.x]

                // Calculate a tentative alternative distance based on the current node
                let tentativeDistance =
                    shortestPathFromStart[currentNode.y][currentNode.x]
                    + self.grid[neighbor.y][neighbor.x]

                // If this new tentative distance is shorter, save it and update the neighbor's
                // weight in the priority queue
                if tentativeDistance < previousDistance {
                    unvisitedNodesWithCost.remove(
                        TwoDimensionalPointWithWeight(
                            x: neighbor.x, y: neighbor.y, weight: previousDistance))
                    unvisitedNodesWithCost.push(
                        TwoDimensionalPointWithWeight(
                            x: neighbor.x, y: neighbor.y, weight: tentativeDistance))

                    shortestPathFromStart[neighbor.y][neighbor.x] = tentativeDistance
                }
            }
        }

        return shortestPathFromStart.last!.last!
    }
}
