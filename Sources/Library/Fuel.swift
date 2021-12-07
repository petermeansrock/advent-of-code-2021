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

        // Perform a binary search for the minimum fuel cost as the costs should fall into a
        // continuum
        var leftPosition = countsByPosition.map { $0.key }.min()!
        var rightPosition = countsByPosition.map { $0.key }.max()!
        while leftPosition <= rightPosition {
            // Find the midpoint of the current range
            let centerPosition = (leftPosition + rightPosition) / 2

            // Handle scenarios where there are too few positions remaining to continue binary
            // searching
            if leftPosition == centerPosition && centerPosition == rightPosition {
                // If we are down to one position, simply return the cost
                return determineFuelCost(for: centerPosition, considering: countsByPosition)
            } else if centerPosition == leftPosition || centerPosition == rightPosition {
                // If we are down to two positions, return the lower of the two costs
                return min(
                    determineFuelCost(for: leftPosition, considering: countsByPosition),
                    determineFuelCost(for: rightPosition, considering: countsByPosition)
                )
            }

            // Consider three consecutive positions to determine whether to search left, right, or
            // return early
            let left = determineFuelCost(for: centerPosition - 1, considering: countsByPosition)
            let center = determineFuelCost(for: centerPosition, considering: countsByPosition)
            let right = determineFuelCost(for: centerPosition + 1, considering: countsByPosition)

            if left < center {
                // Move our search to the left side of the remaining positions
                rightPosition = centerPosition - 1
            } else if right < center {
                // Move our search to the right side of the remaining positions
                leftPosition = centerPosition + 1
            } else {
                // Return early since we've already found the minimum
                return center
            }
        }

        // The following line should not be reachable
        fatalError("There is a bug in the logic above")
    }

    /// Calculates the fuel cost for a single candidate end position.
    ///
    /// - Parameters:
    ///   - endPosition: A candidate end position for all entities.
    ///   - countsByPosition: A map from starting positions to the count of entities at each
    ///     position.
    /// - Returns: The fuel cost to move all entities to a single candidate end position.
    private func determineFuelCost(for endPosition: Int, considering countsByPosition: [Int: Int])
        -> Int
    {
        // Calculate the cost of moving each group to the candidate end position (accounting for
        // fuel efficiency)
        return countsByPosition.map { position, count in
            self.fuelEfficiency.cost(across: abs(endPosition - position)) * count
        }.reduce(0, +)  // Summing across the cost of all source positions
    }
}
