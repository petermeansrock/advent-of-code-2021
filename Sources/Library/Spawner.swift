import Foundation

public struct Spawner {
    public let count: Int

    public init(with initialGroups: [Int], through days: Int, every cycle: Int, plus childhood: Int) {
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
        self.count = previousDay.reduce(0, +)
    }
}
