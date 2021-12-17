import AdventOfCode
import Foundation

/// Contains statistics about potential cannon trajectories.
public struct TrajectoryStatistics {
    /// The max height reached of all trajectories which hit the target.
    public let maxHeight: Int
    /// The number of initial velocity candidates which successfully hit the target.
    public let velocityCandidateCount: Int
}

/// A cannon be used to determine trajectory statistics when aiming at a target area.
public struct Cannon {
    /// Calculates the combined statistics of all trajectories which would hit the target.
    ///
    /// - Parameters:
    ///   - targetX: The target's range in the x-axis.
    ///   - targetY: The target's range in the y-axis.
    /// - Returns: The statistics of all trajectories which would hit the target.
    public func aim(targetX: ClosedRange<Int>, targetY: ClosedRange<Int>) -> TrajectoryStatistics {
        var maxHeight = Int.min
        var velocityCount = 0

        for dy in targetY.lowerBound...abs(targetY.lowerBound) {
            for dx in 0...targetX.upperBound {
                if let height = self.willHit(
                    targetX: targetX, targetY: targetY, velocityX: dx, velocityY: dy)
                {
                    maxHeight = max(maxHeight, height)
                    velocityCount += 1
                }
            }
        }

        return .init(maxHeight: maxHeight, velocityCandidateCount: velocityCount)
    }

    private func willHit(
        targetX: ClosedRange<Int>, targetY: ClosedRange<Int>, velocityX: Int, velocityY: Int
    ) -> Int? {
        var currentVelocityX = velocityX
        var currentVelocityY = velocityY
        var position = TwoDimensionalPoint(x: 0, y: 0)
        var maxHeight = Int.min

        while position.x <= targetX.upperBound && position.y >= targetY.lowerBound {
            // Calculate next point
            let newPosition = TwoDimensionalPoint(
                x: position.x + currentVelocityX, y: position.y + currentVelocityY)

            // Keep track of maximum height reached
            maxHeight = max(maxHeight, newPosition.y)

            // Evaluate new position point
            if targetX.contains(newPosition.x) && targetY.contains(newPosition.y) {
                return maxHeight
            }

            // Adjust position and velocity
            position = newPosition
            currentVelocityY -= 1
            if currentVelocityX > 0 {
                currentVelocityX -= 1
            }
        }

        return nil
    }
}
