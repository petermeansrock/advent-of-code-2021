import Foundation

/// Represents sonar capable of sweeping the ocean depths.
public struct Sonar {
    /// Creates a new instance.
    public init() {
    }

    /// Performs a sweep of the ocean depths.
    ///
    /// Returns the number of times the ocean depth increases from one depth value to the next. For
    /// example, consider the following input:
    /// ```
    /// 199
    /// 200
    /// 208
    /// 210
    /// 200
    /// 207
    /// 240
    /// 269
    /// 260
    /// 263
    /// ```
    ///
    /// This input will be interpreted as follows:
    /// ```
    /// 199 (N/A - no previous measurement)
    /// 200 (increased)
    /// 208 (increased)
    /// 210 (increased)
    /// 200 (decreased)
    /// 207 (increased)
    /// 240 (increased)
    /// 269 (increased)
    /// 260 (decreased)
    /// 263 (increased)
    /// ```
    ///
    /// As a result, this method will return `7` for this sample input.
    ///
    /// - Parameter depths: The depths to sweep.
    /// - Returns: The number of times the ocean depth increases from one depth value to the next.
    public func sweep(depths: [Int]) -> Int {
        return zip(depths.dropFirst(), depths)
            .map { $0 > $1 ? 1 : 0 }
            .reduce(0, +)
    }

    /// Performs a sweep of the ocean depths considering measurement windows.
    ///
    /// Returns the number of times each measurement window, representing the sum of a consecutive
    /// set of depths, increases from one window to the next. For example, consider the following
    /// input (the numeric values) annotated with the letter representing each three-value (in this
    /// example) measurement window:
    /// ```
    /// 199  A
    /// 200  A B
    /// 208  A B C
    /// 210    B C D
    /// 200  E   C D
    /// 207  E F   D
    /// 240  E F G
    /// 269    F G H
    /// 260      G H
    /// 263        H
    /// ```
    ///
    /// Summing each measurement window will produce the following values:
    /// ```
    /// A: 607 (N/A - no previous sum)
    /// B: 618 (increased)
    /// C: 618 (no change)
    /// D: 617 (decreased)
    /// E: 647 (increased)
    /// F: 716 (increased)
    /// G: 769 (increased)
    /// H: 792 (increased)
    /// ```
    ///
    /// As a result, this method will return `5` for the sample input.
    /// - Parameters:
    ///   - depths: The depths to sweep.
    ///   - windowSize: The size of each measurement window.
    /// - Returns: The number of times each measurement window increases from one window value to
    ///   the next.
    public func sweepMeasurementWindows(depths: [Int], windowSize: Int = 3) -> Int {
        let measurementWindows = zip(depths.dropFirst(2), zip(depths.dropFirst(), depths))
            .map { $0 + $1.0 + $1.1 }
        return self.sweep(depths: measurementWindows)
    }
}
