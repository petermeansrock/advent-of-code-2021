import Foundation

public struct Sonar {
    public init() {
    }
    
    public func sweep(depths: [Int]) -> Int {
        return zip(depths.dropFirst(), depths)
            .map{ $0 > $1 ? 1 : 0 }
            .reduce(0, +)
    }
    
    public func sweepMeasurementWindows(depths: [Int], windows: Int = 3) -> Int {
        let measurementWindows = zip(depths.dropFirst(2), zip(depths.dropFirst(), depths))
            .map{ $0 + $1.0 + $1.1 }
        return self.sweep(depths: measurementWindows)
    }
}
