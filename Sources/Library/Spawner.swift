import Foundation

/// Simulates the spawning behavior of a group over time.
public struct Spawner {
    /// Runs a spawning simulation, returning the number of fish at the end of the simulation..
    ///
    /// Consider the following initial groups where each number `i` represents that it will take
    /// `i + 1` days for the a given entity to spawn a new entity:
    ///
    /// ```
    /// 3,4,3,1,2
    /// ```
    ///
    /// Assuming a `cycle` of 7 days and that entities spend 2 days in `childhood`, after 10 days,
    /// we would expect the following state:
    ///
    /// ```
    /// Initial state: 3,4,3,1,2
    /// After  1 day:  2,3,2,0,1
    /// After  2 days: 1,2,1,6,0,8
    /// After  3 days: 0,1,0,5,6,7,8
    /// After  4 days: 6,0,6,4,5,6,7,8,8
    /// After  5 days: 5,6,5,3,4,5,6,7,7,8
    /// After  6 days: 4,5,4,2,3,4,5,6,6,7
    /// After  7 days: 3,4,3,1,2,3,4,5,5,6
    /// After  8 days: 2,3,2,0,1,2,3,4,4,5
    /// After  9 days: 1,2,1,6,0,1,2,3,3,4,8
    /// After 10 days: 0,1,0,5,6,0,1,2,2,3,7,8
    /// ```
    ///
    /// With the above example, this method will return 12 as the number of rish in the population.
    ///
    /// - Parameters:
    ///   - initialGroups: The initial group of entities as a set of numbers where each number `i`
    ///     represents that it will take `i + 1` days for the a given entity to spawn a new entity.
    ///   - days: The days to simulate.
    ///   - cycle: The number of days between spawns for each entity.
    ///   - childhood: The number of days that must pass before a newly spawned entity enters the
    ///     normal spawning cycle.
    /// - Returns: The number of fish at the end of the simulation.
    public func spawn(
        with initialGroups: [Int], through days: Int, every cycle: Int, plus childhood: Int
    ) -> Int {
        // This is the maximum value we will ever expect for a single spawned entity
        let initialSpawnValue = (cycle - 1) + childhood

        // Prepare blank slate for initializing each day
        let emptyDay = Array(repeating: 0, count: initialSpawnValue + 1)

        // Initialize day zero by counting the number of spawned entities which share the same
        // number of days remaining
        var previousDay = initialGroups.reduce(into: emptyDay) { counts, daysRemaining in
            counts[daysRemaining] += 1
        }

        // Simulate each day
        for _ in 1...days {
            // Create blank state for new day
            var newDay = emptyDay

            // Examine each bucket of spawned entities by the number of days remaining
            for (daysRemaining, previousCount) in previousDay.enumerated() {
                // Base the new day's values off the counts from the previous day
                if daysRemaining == 0 {
                    // The group at zero now reset their spawn cycle
                    newDay[cycle - 1] += previousCount

                    // Also, the same number of fish are spawned at the initial spawn value
                    newDay[initialSpawnValue] += previousCount
                } else {
                    // Otherwise, we just shift the previous count down by one day
                    newDay[daysRemaining - 1] += previousCount
                }
            }

            // Update previous to contain the new day's values
            previousDay = newDay
        }

        // Calculcate the sum of the final day
        return previousDay.reduce(0, +)
    }
}
