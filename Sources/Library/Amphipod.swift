import Foundation

/// A burrow solver is capable of finding the minimum cost of aligning a ``Burrow``.
public struct BurrowSolver {
    private let initialState: BurrowState
    private var memo = [BurrowState: Int]()
    private var minimumCostSoFar = Int.max

    /// Creates a new instance.
    ///
    /// - Parameter burrow: The initial burrow for which to solve.
    public init(with burrow: Burrow) {
        self.initialState = BurrowState(burrow: burrow, cost: 0)
    }

    /// Finds the minimum cost to align the burrow.
    ///
    /// - Returns: The minimum cost of aligning the burrow.
    public mutating func findMinimumAlignmentCost() -> Int {
        return findMinimumAlignmentCost(state: self.initialState)
    }

    private mutating func findMinimumAlignmentCost(state: BurrowState) -> Int {
        if memo[state] != nil {
            return memo[state]!
        }

        if state.cost > self.minimumCostSoFar {
            memo[state] = state.cost
            return state.cost
        }

        if state.burrow.aligned {
            memo[state] = state.cost
            return state.cost
        }

        var minimumCost = Int.max
        for move in state.burrow.legalMoves {
            let newState = state.move(with: move)
            let cost = self.findMinimumAlignmentCost(state: newState)
            minimumCost = min(minimumCost, cost)
        }
        self.minimumCostSoFar = min(self.minimumCostSoFar, minimumCost)

        memo[state] = minimumCost
        return minimumCost
    }
}

private struct BurrowState: Hashable {
    let burrow: Burrow
    let cost: Int

    internal func move(with move: BurrowMove) -> BurrowState {
        let (newBurrow, cost) = self.burrow.move(with: move)
        return BurrowState(burrow: newBurrow, cost: self.cost + cost)
    }
}

/// A burrow is a dwelling inhabited by amphipods.
///
/// A burrow is comprised of a hallway, connecting one or more side rooms. For example, the
/// following is a burrow with a hallway of length 11 and four side rooms, each of size 2:
///
/// ```
/// #############
/// #...........#
/// ###B#C#B#D###
///   #A#D#C#A#
///   #########
/// ```
///
/// In the above example, regardless of the current position of amphipods (represented as capital
/// letters), each burrow is assigned to a single amphipod type:
/// - The first room (from left-to-right) is owned by amphipod type `A`.
/// - The second room is owned by amphipod type `B`.
/// - And so on.
///
/// Since in the above burrow, amphipods are visiting the side rooms assigned to other types, the
/// burrow is considered *unaligned*. In contrast, the following burrow is considered aligned as
/// each amphipod type is in its own assigned room:
///
/// ```
/// #############
/// #...........#
/// ###A#B#C#D###
///   #A#B#C#D#
///   #########
/// ```
public struct Burrow: Hashable, LosslessStringConvertible {
    fileprivate var spots: [[Amphipod?]]
    private let amphipodToIndex: [Amphipod: Int]
    private let indexToAmphipod: [Int: Amphipod]
    private let roomIndices: [Int]
    /// The string representation for this burrow.
    public var description: String {
        var lines = [String]()

        // Create hallway lines
        let hallwayLength = spots.count
        lines.append(String(repeating: "#", count: hallwayLength + 2))
        let hallway =
            spots
            .map { $0[0] == nil ? "." : String($0[0]!.rawValue) }
            .reduce("", +)
        lines.append("#\(hallway)#")

        // Create room lines
        let roomIndices = indexToAmphipod.map { $0.key }
        let minimumRoomIndex = roomIndices.min()!
        let maximumRoomIndex = roomIndices.max()!
        for r in 1..<spots[minimumRoomIndex].endIndex {
            var line = ""
            for h in spots.indices {
                if roomIndices.contains(h) {
                    line += spots[h][r].map { String($0.rawValue) } ?? "."
                } else {
                    if r == 1 {
                        // Insert additional "#" symbols
                        line += "#"
                    } else {
                        if h < minimumRoomIndex - 1 {
                            line += " "
                        } else if h <= maximumRoomIndex + 1 {
                            line += "#"
                        }
                    }
                }
            }

            if r == 1 {
                lines.append("#\(line)#")
            } else {
                lines.append(" \(line)")
            }
        }

        let lastLinePrefix = String(repeating: " ", count: minimumRoomIndex)
        let lastLineSuffix = String(repeating: "#", count: roomIndices.count * 2 + 1)
        lines.append(lastLinePrefix + lastLineSuffix)

        return lines.joined(separator: "\n")
    }

    internal let aligned: Bool
    internal let legalMoves: [BurrowMove]

    /// Creates an instance from the provided description.
    public init?(_ description: String) {
        // Split description into multiple lines
        let lines =
            description
            .components(separatedBy: .newlines)  // Split into multiple lines
            .filter { $0.count > 0 }  // Ignore empty lines
            .map { $0.dropFirst() }  // Strip off the "#" or " " at the beginning of each line
            .map { $0.dropLast() }  // Strip off the "#" at the beginng
            .dropFirst()  // Drop the top row of "#" characters
            .dropLast()  // Drop the last row of "#" characters

        // Determine the hallway length and create the 2-D array of spots
        let hallwayLength = lines[lines.startIndex].count
        var spots: [[Amphipod?]] = Array(
            repeating: Array(repeating: nil, count: 1), count: hallwayLength)

        // All lines but the first (the hallway) will represent a room
        let roomDepth = lines.count - 1

        // Set the spots through the 2-D array (initializing sub-arrays when necessary)
        var amphipodToIndex = [Amphipod: Int]()
        var indexToAmphipod = [Int: Amphipod]()
        var amphipodCount = 0
        for (r, line) in lines.enumerated() {
            for (h, character) in line.enumerated() {
                if character != "#" && character != " " {
                    if r == 1 {
                        // TODO: Guard against an amphipode in the 0th room index (an illegal state)
                        spots[h] = Array(repeating: nil, count: roomDepth + 1)
                        let amphipod = Amphipod.allCases[amphipodCount]
                        amphipodToIndex[amphipod] = h
                        indexToAmphipod[h] = amphipod
                        amphipodCount += 1
                    }

                    spots[h][r] = Amphipod(rawValue: character)
                }
            }
        }

        self.init(spots: spots, amphipodToIndex: amphipodToIndex, indexToAmphipod: indexToAmphipod)
    }

    private init(
        spots: [[Amphipod?]], amphipodToIndex: [Amphipod: Int], indexToAmphipod: [Int: Amphipod]
    ) {
        self.spots = spots
        self.amphipodToIndex = amphipodToIndex
        self.indexToAmphipod = indexToAmphipod
        self.roomIndices = indexToAmphipod.map { $0.key }
        self.aligned = Burrow.isAligned(spots: self.spots, indexToAmphipod: self.indexToAmphipod)
        self.legalMoves = Burrow.determineLegalMoves(
            spots: self.spots, indexToAmphipod: self.indexToAmphipod, roomIndices: self.roomIndices)
    }

    fileprivate static func isPathFree(
        spots: [[Amphipod?]], from source: BurrowPosition, to destination: BurrowPosition
    ) -> Bool {
        // Check path to hallway
        if !source.isInHallwayAndNavigable && source.roomIndex > 0 {
            for r in 0..<source.roomIndex {
                if spots[source.hallwayIndex][r] != nil {
                    return false
                }
            }
        }

        // Check path down hallway
        let distance = destination.hallwayIndex - source.hallwayIndex
        if distance != 0 {
            let step = distance / abs(distance)

            for h in stride(
                from: source.hallwayIndex + step, through: destination.hallwayIndex, by: step)
            {
                if spots[h][0] != nil {
                    return false
                }
            }
        }

        // Check path into room
        if !destination.isInHallwayAndNavigable && destination.roomIndex > 0 {
            for r in 1..<destination.roomIndex {
                if spots[destination.hallwayIndex][r] != nil {
                    return false
                }
            }
        }

        return true
    }

    internal func move(with move: BurrowMove) -> (Burrow, Int) {
        var spots = self.spots

        let amphipod = spots[move.source.hallwayIndex][move.source.roomIndex]!
        spots[move.source.hallwayIndex][move.source.roomIndex] = nil
        spots[move.destination.hallwayIndex][move.destination.roomIndex] = amphipod

        return (
            Burrow(
                spots: spots, amphipodToIndex: self.amphipodToIndex,
                indexToAmphipod: self.indexToAmphipod), move.distance * amphipod.cost
        )
    }

    fileprivate static func isAligned(spots: [[Amphipod?]], indexToAmphipod: [Int: Amphipod])
        -> Bool
    {
        for h in indexToAmphipod.map({ $0.key }) {
            let allowedAmphipod = indexToAmphipod[h]

            for r in 1..<spots[h].endIndex {
                let current = spots[h][r]
                if current == nil || current! != allowedAmphipod {
                    return false
                }
            }
        }

        return true
    }

    fileprivate static func determineLegalMoves(
        spots: [[Amphipod?]], indexToAmphipod: [Int: Amphipod], roomIndices: [Int]
    ) -> [BurrowMove] {
        var moves = [BurrowMove]()

        var freeHallwaySpots = [BurrowPosition]()
        var freeRoomSpot = [Amphipod: BurrowPosition]()
        var sources = [BurrowPosition]()

        // Examine hallway
        for h in spots.indices {
            let hallwayPosition = BurrowPosition(
                hallwayIndex: h, roomIndex: 0, roomIndices: roomIndices)

            // Determine presence in hall (or if the spot in the hallway is freely navigable)
            if spots[h][0] != nil {
                sources.append(hallwayPosition)
            } else if hallwayPosition.isInHallwayAndNavigable {
                freeHallwaySpots.append(hallwayPosition)
            }

            // Fork off into rooms
            if !hallwayPosition.isInHallwayAndNavigable {
                let allowedAmphipod = indexToAmphipod[h]!
                var openToAllowedAmphipod = true
                var firstOccupiedSpot: BurrowPosition?
                var lastFreeSpot: BurrowPosition?

                for r in 1..<spots[h].endIndex {
                    let position = BurrowPosition(
                        hallwayIndex: h, roomIndex: r, roomIndices: roomIndices)
                    let present = spots[h][r]
                    if present == nil {
                        lastFreeSpot = position
                    } else {
                        if firstOccupiedSpot == nil {
                            firstOccupiedSpot = position
                        }

                        if present != allowedAmphipod {
                            openToAllowedAmphipod = false
                            break
                        }
                    }
                }

                if openToAllowedAmphipod {
                    if let freePosition = lastFreeSpot {
                        freeRoomSpot[allowedAmphipod] = freePosition
                    }
                } else {
                    sources.append(firstOccupiedSpot!)
                }
            }
        }

        for source in sources {
            // Consider room destinations
            let amphipod = spots[source.hallwayIndex][source.roomIndex]!
            if let destination = freeRoomSpot[amphipod] {
                if self.isPathFree(spots: spots, from: source, to: destination) {
                    moves.append(BurrowMove(from: source, to: destination))

                    // There's no point in considering a hallway move if we can move to a room
                    continue
                }
            }

            // If not in hallway, consider hallway positions
            if !source.isInHallwayAndNavigable {
                for destination in freeHallwaySpots {
                    if self.isPathFree(spots: spots, from: source, to: destination) {
                        moves.append(BurrowMove(from: source, to: destination))
                    }
                }
            }
        }

        return moves
    }

    /// Hashes the essential components of this value by feeding them into the given hasher.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(spots)
    }
}

internal struct BurrowMove: Hashable {
    let source: BurrowPosition
    let destination: BurrowPosition
    let distance: Int

    init(from source: BurrowPosition, to destination: BurrowPosition) {
        self.source = source
        self.destination = destination
        self.distance = self.destination - self.source
    }
}

internal struct BurrowPosition: Hashable {
    let hallwayIndex: Int
    let roomIndex: Int
    let isInHallwayAndNavigable: Bool

    init(hallwayIndex: Int, roomIndex: Int, roomIndices: [Int]) {
        self.hallwayIndex = hallwayIndex
        self.roomIndex = roomIndex
        self.isInHallwayAndNavigable = !roomIndices.contains(hallwayIndex)
    }

    static func - (lhs: BurrowPosition, rhs: BurrowPosition) -> Int {
        let hallwayDistance = abs(lhs.hallwayIndex - rhs.hallwayIndex)
        let roomDistance: Int
        if hallwayDistance > 0 {
            roomDistance = lhs.roomIndex + rhs.roomIndex
        } else {
            roomDistance = abs(lhs.roomIndex - rhs.roomIndex)
        }
        return hallwayDistance + roomDistance
    }
}

private enum Amphipod: Character, CaseIterable {
    case amber = "A"
    case bronze = "B"
    case copper = "C"
    case desert = "D"

    fileprivate var cost: Int {
        switch self {
        case .amber:
            return 1
        case .bronze:
            return 10
        case .copper:
            return 100
        case .desert:
            return 1000
        }
    }
}
