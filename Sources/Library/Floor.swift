import Foundation

internal struct Point: Equatable, Hashable {
    let row: Int
    let column: Int
    let height: Int

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.row)
        hasher.combine(self.column)
        hasher.combine(self.height)
    }

    static func == (lhs: Point, rhs: Point) -> Bool {
        return lhs.row == rhs.row && lhs.column == rhs.column && lhs.height == rhs.height
    }
}

/// A queue that remembers items previously enqueued to it, ignoring attempts to enqueue the same
/// it again.
internal struct VisitedQueue<T: Hashable> {
    private var queue = [T]()
    private var set = Set<T>()
    var isEmpty: Bool {
        return queue.isEmpty
    }
    var enqueuedCount: Int {
        return set.count
    }

    @discardableResult mutating func enqueue(_ item: T) -> Bool {
        if set.insert(item).inserted {
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
                let point = Point(row: i, column: j, height: self.grid[i][j])

                // Find all neighbors
                let neighbors = self.neighbors(point: point)

                // Find all neighbors taller than the current point
                let tallerNeighbors =
                    neighbors
                    .filter { $0.height > point.height }

                // If all neighbors are taller, we've found a low point (and thus, a basin)
                if tallerNeighbors.count == neighbors.count {
                    // Determine the basin's risk level and size
                    let riskLevel = point.height + 1
                    let size = determineBasinSize(lowPoint: point)
                    basins.append(Basin(riskLevel: riskLevel, size: size))
                }
            }
        }

        return basins
    }

    private func neighbors(point: Point) -> [Point] {
        var neighbors = [Point]()

        // Consider all neighbors horizontally or vertically adjacent to the specified point
        for (i, j) in [
            (point.row - 1, point.column),
            (point.row + 1, point.column),
            (point.row, point.column - 1),
            (point.row, point.column + 1),
        ] {
            if self.grid.indices.contains(i) && self.grid[i].indices.contains(j) {
                neighbors.append(Point(row: i, column: j, height: self.grid[i][j]))
            }
        }
        return neighbors
    }

    private func determineBasinSize(lowPoint: Point) -> Int {
        // Use a special purpose queue that (1) will ignore attempts to enqueue the same point twice
        // and (2) will keep track of all unique points ever enqueued. This will allow us to enqueue
        // neighbors without checking whether each one has been visited before.
        var queue = VisitedQueue<Point>()
        queue.enqueue(lowPoint)

        while !queue.isEmpty {
            let point = queue.dequeue()
            let traversableNeighbors = self.neighbors(point: point)
                .filter { $0.height < 9 }
            queue.enqueueAll(traversableNeighbors)
        }

        return queue.enqueuedCount
    }
}
