import Collections
import Foundation

/// Represents a navigable cave.
public struct Cave: Hashable {
    /// The identifier for this cave.
    public let id: String
    /// Whether or not this cave is small.
    public let isSmall: Bool
    /// Whether or not this is the start cave.
    public let isStart: Bool
    /// Whether or not this is the end cave.
    public let isEnd: Bool

    fileprivate init(id: String) {
        self.id = id
        self.isStart = id == "start"
        self.isEnd = id == "end"
        self.isSmall = !self.isStart && !self.isEnd && id.lowercased() == id
    }

    /// Hashes the essential components of this value by feeding them into the given hasher.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

/// Represents a path through caves.
public struct Path {
    private var vertexPath = [Cave]()
    /// A dictionary mapping each cave to the number of times it's been visited.
    public private(set) var visitCounts = [Cave: Int]()
    /// The number of times small caves have been revisited.
    public private(set) var smallCavesRevisited = 0

    fileprivate mutating func append(cave: Cave) {
        // Keep track of path
        vertexPath.append(cave)

        // Keep track of small caves that have been revisited
        // TODO: This should be removed from Path and moved into a refactored version of VisitPolicy that acts as an observed for exploration.
        if cave.isSmall && visitCounts[cave] != nil {
            smallCavesRevisited += 1
        }

        // Keep track of visits to all caves
        visitCounts[cave, default: 0] += 1
    }
}

private struct PathWithCave {
    fileprivate let path: Path
    fileprivate let cave: Cave
}

/// Determines whether or not a cave can be visited.
public protocol VisitPolicy {
    /// Determines whether or not a cave can be visited.
    ///
    /// - Parameters:
    ///   - cave: The cave to examine.
    ///   - path: The path so far.
    /// - Returns: True if the cave can be visited, false otherwise.
    func allowedToVisit(cave: Cave, in path: Path) -> Bool
}

/// Does not allow revisiting small caves.
public struct NoSmallCaveRevisitPolicy: VisitPolicy {
    /// Determines whether or not a cave can be visited.
    ///
    /// - Parameters:
    ///   - cave: The cave to examine.
    ///   - path: The path so far.
    /// - Returns: True if the cave can be visited, false otherwise.
    public func allowedToVisit(cave: Cave, in path: Path) -> Bool {
        if cave.isSmall {
            return !(path.visitCounts[cave] != nil)
        } else {
            return true
        }
    }
}

/// Only allows revisiting a single small cave.
public struct SingleSmallCaveRevisitPolicy: VisitPolicy {
    /// Determines whether or not a cave can be visited.
    ///
    /// - Parameters:
    ///   - cave: The cave to examine.
    ///   - path: The path so far.
    /// - Returns: True if the cave can be visited, false otherwise.
    public func allowedToVisit(cave: Cave, in path: Path) -> Bool {
        if cave.isSmall {
            // Allow visiting this cave for the first time
            if path.visitCounts[cave, default: 0] == 0 {
                return true
            } else {
                return path.smallCavesRevisited < 1
            }
        } else {
            return true
        }
    }
}

/// A network of caves.
public struct CaveNetwork {
    private let adjacencyLists: [Cave: [Cave]]
    private let visitPolicy: VisitPolicy

    /// Creates a new instance.
    ///
    /// - Parameters:
    ///   - lines: The lines of bidirectional edges between caves.
    ///   - visitPolicy: The policy to use to determine whether to visit a cave.
    public init(lines: [String], visitPolicy: VisitPolicy) {
        var adjacencyLists = [Cave: [Cave]]()

        for line in lines {
            let caves = line.components(separatedBy: "-")
                .map(Cave.init)
            adjacencyLists[caves[0], default: []].append(caves[1])
            adjacencyLists[caves[1], default: []].append(caves[0])
        }

        self.adjacencyLists = adjacencyLists
        self.visitPolicy = visitPolicy
    }

    /// Counts the number of valid paths through the network of caves.
    ///
    /// - Returns: The number of valid paths through the network of caves.
    public func countPaths() -> Int {
        let start = Cave(id: "start")
        var startPath = Path()
        startPath.append(cave: start)

        var completePaths = [Path]()

        var queue = Deque<PathWithCave>()
        queue.append(PathWithCave(path: startPath, cave: start))
        while !queue.isEmpty {
            let pathWithCave = queue.removeFirst()

            // Examine all connected vertices
            for neighbor in self.adjacencyLists[pathWithCave.cave, default: []] {
                // Skip the start node
                if neighbor.isStart {
                    continue
                }

                // Skip if the revisit policy does not allow visiting this cave
                if !self.visitPolicy.allowedToVisit(cave: neighbor, in: pathWithCave.path) {
                    continue
                }

                // Expand path through cave
                var pathThroughNeighbor = pathWithCave.path
                pathThroughNeighbor.append(cave: neighbor)
                if neighbor.isEnd {
                    completePaths.append(pathThroughNeighbor)
                } else {
                    queue.append(PathWithCave(path: pathThroughNeighbor, cave: neighbor))
                }
            }
        }

        return completePaths.count
    }
}
