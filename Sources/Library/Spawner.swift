import Foundation

public struct Spawner {
    public let count: Int

    public init(with initialGroups: [Int], through days: Int, every cycle: Int, plus childhood: Int) {
        // This is the maximum value we will ever expect for a single spawned entity
        let initialSpawnValue = (cycle - 1) + childhood
        
        // Prepare a two-dimensional array where the outside array represents each day
        // and the inner array contains the counts of each spawned entity sharing the
        // same remaining days to spawn (who will always remain in sync with one another)
        var spawnGroupsByDay = Array(repeating: Array(repeating: 0, count: initialSpawnValue + 1), count: days + 1)
        
        // Initialize day zero by counting the number of spawned entity which share the same number of days remaining
        spawnGroupsByDay[0] = initialGroups.reduce(into: spawnGroupsByDay[0]) { counts, daysRemaining in
            counts[daysRemaining] += 1
        }
    
        // Simulate each day
        for day in 1...days {
            // Examine each bucket of spawned entities by the number of days remaining
            for daysRemaining in spawnGroupsByDay[day].indices {
                // Base the new day's values off the counts from the previous day
                let previousCount = spawnGroupsByDay[day - 1][daysRemaining]
                
                if daysRemaining == 0 {
                    // The group at zero now reset their spawn cycle
                    spawnGroupsByDay[day][cycle - 1] += previousCount
                    
                    // Also, the same number of fish are spawned at the initial spawn value
                    spawnGroupsByDay[day][initialSpawnValue] += previousCount
                } else {
                    // Otherwise, we just shift the previous count down by one day
                    spawnGroupsByDay[day][daysRemaining - 1] += previousCount
                }
            }
        }
        
        // Calculcate the sum of the final day
        self.count = spawnGroupsByDay[days].reduce(0, +)
    }
}
