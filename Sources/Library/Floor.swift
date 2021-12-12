import AdventOfCode
import Foundation

/// A queue that remembers items previously enqueued to it, ignoring attempts to enqueue the same
/// it again.
internal struct VisitedQueue<T: Hashable> {
    /// The set of uniquely enqueued items.
    public private(set) var visited = Set<T>()
    private var queue = [T]()
    var isEmpty: Bool {
        return queue.isEmpty
    }
    var enqueuedCount: Int {
        return visited.count
    }

    @discardableResult mutating func enqueue(_ item: T) -> Bool {
        if visited.insert(item).inserted {
            queue.append(item)
            return true
        } else {
            return false
        }
    }

    @discardableResult mutating func enqueueAll(_ items: [T]) -> Int {
        var count = 0
        for item in items {
            if self.enqueue(item) {
                count += 1
            }
        }
        return count
    }

    mutating func dequeue() -> T {
        return queue.removeFirst()
    }
}

/// A basin is all locations that eventually flow downward to a single low point.
///
/// Every low point in an ``OceanFloor`` has a basin, although some basins are very small. Locations
/// of height `9` do not count as being in any basin, and all other locations will always be part of
/// exactly one basin.
public struct Basin {
    /// The height of the low point for this basin plus one.
    public let riskLevel: Int
    /// The number of locations within this basin.
    public let size: Int
}

/// An ocean floor is comprised of multiple locations, each of varying heights.
public struct OceanFloor {
    private let grid: [[Int]]

    /// Creates a new instance.
    ///
    /// This method takes a two-dimensional grid of single-digit numbers, each representing the
    /// height at that location. For example:
    ///
    /// ```
    /// 2199943210
    /// 3987894921
    /// 9856789892
    /// 8767896789
    /// 9899965678
    /// ```
    ///
    /// - Parameter grid: A two-dimensional grid of single digit numbers, each representing the
    ///   height at that location.
    public init(grid: [[Int]]) {
        self.grid = grid
    }

    /// Finds all basins across the ocean floor.
    ///
    /// - Returns: The basins found.
    public func findBasins() -> [Basin] {
        var basins = [Basin]()

        // Loop through the entire grid
        for i in grid.indices {
            for j in grid[i].indices {
                // Create point for coordinates
                let point = ThreeDimensionalPoint(x: j, y: i, z: self.grid[i][j])

                // Find all neighbors
                let neighbors = self.grid.neighbors(
                    row: point.y, column: point.x, adjacencies: Set([.horizontal, .vertical])
                ).map { ThreeDimensionalPoint(x: $0.column, y: $0.row, z: $0.value) }

                // Find all neighbors taller than the current point
                let tallerNeighbors =
                    neighbors
                    .filter { $0.z > point.z }

                // If all neighbors are taller, we've found a low point (and thus, a basin)
                if tallerNeighbors.count == neighbors.count {
                    // Determine the basin's risk level and size
                    let riskLevel = point.z + 1
                    let size = determineBasinSize(lowPoint: point)
                    basins.append(Basin(riskLevel: riskLevel, size: size))
                }
            }
        }

        return basins
    }

    private func determineBasinSize(lowPoint: ThreeDimensionalPoint<Int>) -> Int {
        // Use a special purpose queue that (1) will ignore attempts to enqueue the same point twice
        // and (2) will keep track of all unique points ever enqueued. This will allow us to enqueue
        // neighbors without checking whether each one has been visited before.
        var queue = VisitedQueue<ThreeDimensionalPoint<Int>>()
        queue.enqueue(lowPoint)

        while !queue.isEmpty {
            let point = queue.dequeue()
            let traversableNeighbors = self.grid.neighbors(
                row: point.y, column: point.x, adjacencies: Set([.horizontal, .vertical])
            ).map { ThreeDimensionalPoint(x: $0.column, y: $0.row, z: $0.value) }
            .filter { $0.z < 9 }
            queue.enqueueAll(traversableNeighbors)
        }

        return queue.enqueuedCount
    }
}
