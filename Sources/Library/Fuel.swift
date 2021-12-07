import Foundation

/// Calculates the cost of moving across a specified distance.
public protocol FuelEfficiency {
    /// Calculates the cost of moving across a specified distance.
    ///
    /// - Parameter distance: The distance for which to calculcate the cost of fuel.
    /// - Returns: The cost of moving across a specified distance.
    func cost(across distance: Int) -> Int
}

/// Calculates the cost of moving across a specified by distance by treating each step as a constant
/// cost of `1`.
///
/// For example, a distance of `5` would cost `5` fuel.
public struct FlatFuelEfficiency: FuelEfficiency {
    /// Calculates the cost of moving across a specified by distance by treating each step as a
    /// constant cost of `1`.
    ///
    /// For example, a distance of `5` would cost `5` fuel.
    ///
    /// - Parameter distance: The distance for which to calculcate the cost of fuel.
    /// - Returns: The cost of moving across a specified distance.
    public func cost(across distance: Int) -> Int {
        return distance
    }
}

/// Calculates the cost of moving across a specified by distance by treating *each* step as costing
/// one more fuel than the previous step.
///
/// The cost of taking the `i`-th step alone will cost `i` fuel. This means that the total fuel
/// spent to cover a distance of `n` is equal to `∑ i` (where `i = 1 to n`).
public struct LinearlyDecreasingFuelEfficiency: FuelEfficiency {
    /// Calculates the cost of moving across a specified by distance by treating *each* step as
    /// costing one more fuel than the previous step.
    ///
    /// The cost of taking the `i`-th step alone will cost `i` fuel. This means that the total fuel
    /// spent to cover a distance of `n` is equal to `∑ i` (where `i = 1 to n`).
    ///
    /// - Parameter distance: The distance for which to calculcate the cost of fuel.
    /// - Returns: The cost of moving across a specified distance.
    public func cost(across distance: Int) -> Int {
        return (distance * (distance + 1)) / 2
    }
}

/// Encapsulates optimization logic for determining the minimum amount of fuel that can be spent to
/// align a set of positioned entities.
public struct FuelOptimizer {
    private let fuelEfficiency: FuelEfficiency

    /// Creates a new instance.
    ///
    /// - Parameter fuelEfficiency: The fuel efficiency to use in order to calculate the cost of
    ///   moving individual entities.
    public init(fuelEfficiency: FuelEfficiency) {
        self.fuelEfficiency = fuelEfficiency
    }

    /// Finds the minimum fuel needed to align entities at the provided position.
    ///
    /// - Parameter positions: The initial positions of all entities that will ultimately be aligned
    ///   together at a single position.
    /// - Returns: The minimum fuel needed to align entities at the provided position.
    public func minimumFuelToAlign(positions: [Int]) -> Int {
        // Reduce the list of positions into an array indexed by the position and containing the
        // number of entities at each position
        let countsByPosition = positions.reduce(into: [:]) { counts, position in
            counts[position, default: 0] += 1
        }
        let minPosition = countsByPosition.map { $0.key }.min()!
        let maxPosition = countsByPosition.map { $0.key }.max()!

        // For each candidate end position
        return (minPosition...maxPosition).map { endPosition in
            // Calculate the cost of moving each group to the candidate end position (accounting for
            // fuel efficiency)
            countsByPosition.map { position, count in
                self.fuelEfficiency.cost(across: abs(endPosition - position)) * count
            }
            // Summing the cost across positions to determine the cost for this candidate end
            // position
            .reduce(0, +)
        }
        // Before finding the minimum cost of all candidate end positions
        .min()!
    }
}
