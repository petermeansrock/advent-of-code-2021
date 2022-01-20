import AdventOfCode
import Foundation

/// Represents an operation to perform against a cuboid.
///
/// An insruction is comprised of:
/// - An operation (e.g., turning it on or off)
/// - The x, y, and z axis ranges specifying the cuboid bounds.
public struct CuboidInstruction {
    /// The x-axis range describing the bounds of the cuboid.
    public let xRange: ClosedRange<Int>
    /// The y-axis range describing the bounds of the cuboid.
    public let yRange: ClosedRange<Int>
    /// The z-axis range describing the bounds of the cuboid.
    public let zRange: ClosedRange<Int>
    fileprivate let switchState: SwitchState
    private static let regex =
        #"(on|off) x=(-?\d+)\.\.(-?\d+),y=(-?\d+)\.\.(-?\d+),z=(-?\d+)\.\.(-?\d+)"#

    /// Creates a new instance.
    ///
    /// The specified string must contain an operation (either `on` or `off`) followed by a comma-
    /// separated set of x, y, and z axis ranges describing the bounds of the cuboid. For example,
    /// the following is a valid instruction string:
    /// ```
    /// on x=10..12,y=10..12,z=10..12
    /// ```
    ///
    /// - Parameter string: A string describing the instruction.
    public init(string: String) {
        let substrings = try! string.firstMatch(pattern: CuboidInstruction.regex)!
            .captureGroups
            .map { String($0.substring) }
        let integers = substrings[1...]
            .map { Int($0)! }

        self.switchState = SwitchState(rawValue: substrings[0])!
        self.xRange = integers[0]...integers[1]
        self.yRange = integers[2]...integers[3]
        self.zRange = integers[4]...integers[5]
    }
}

/// Represents a rebootable reactor of a submarine.
public struct CuboidReactor {
    private var nonOverlappingCuboids = [Cuboid]()
    /// The sum of the volume of all *on* cuboids.
    public var volume: Int {
        return
            nonOverlappingCuboids
            .map { $0.volume }
            .reduce(0, +)
    }

    /// Runs the provided instructions to reboot the reactor.
    ///
    /// - Parameter instruction: The instructions to run.
    public mutating func run(instruction: CuboidInstruction) {
        let cuboid = Cuboid(
            xRange: instruction.xRange, yRange: instruction.yRange, zRange: instruction.zRange)
        if instruction.switchState == .on {
            self.turnOn(cuboid)
        } else {
            self.turnOff(cuboid)
        }
    }

    private mutating func turnOn(_ cuboid: Cuboid) {
        // These are the candidate cuboids that may be added to the non-overlapping array.
        var currentCandidates = [cuboid]

        for nonOverlappingCuboid in nonOverlappingCuboids {
            var newCandidates = [Cuboid]()

            // Subtract the existing from the candidate(s) (potentially breaking them apart or erasing them)
            for currentCandidate in currentCandidates {
                newCandidates.append(contentsOf: (currentCandidate - nonOverlappingCuboid))
            }

            currentCandidates = newCandidates
        }

        self.nonOverlappingCuboids.append(contentsOf: currentCandidates)
    }

    private mutating func turnOff(_ cuboid: Cuboid) {
        // This is the updated list of non-overlapping after subtracting the "off" cuboid
        var updated = [Cuboid]()

        for nonOverlappingCuboid in self.nonOverlappingCuboids {
            updated.append(contentsOf: (nonOverlappingCuboid - cuboid))
        }

        self.nonOverlappingCuboids = updated
    }
}

private enum SwitchState: String {
    case on = "on"
    case off = "off"
}

private struct Cuboid {
    let xRange: ClosedRange<Int>
    let yRange: ClosedRange<Int>
    let zRange: ClosedRange<Int>
    var volume: Int {
        return xRange.count * yRange.count * zRange.count
    }

    init(xRange: ClosedRange<Int>, yRange: ClosedRange<Int>, zRange: ClosedRange<Int>) {
        self.xRange = xRange
        self.yRange = yRange
        self.zRange = zRange
    }

    func overlap(with cuboid: Cuboid) -> Cuboid? {
        if self.overlaps(with: cuboid) {
            return Cuboid(
                xRange: max(
                    self.xRange.lowerBound, cuboid.xRange.lowerBound)...min(
                        self.xRange.upperBound, cuboid.xRange.upperBound),
                yRange: max(
                    self.yRange.lowerBound, cuboid.yRange.lowerBound)...min(
                        self.yRange.upperBound, cuboid.yRange.upperBound),
                zRange: max(
                    self.zRange.lowerBound, cuboid.zRange.lowerBound)...min(
                        self.zRange.upperBound, cuboid.zRange.upperBound)
            )
        } else {
            return nil
        }
    }

    func overlaps(with cuboid: Cuboid) -> Bool {
        return xRange.overlaps(cuboid.xRange) && yRange.overlaps(cuboid.yRange)
            && zRange.overlaps(cuboid.zRange)
    }

    static func - (cuboid: Cuboid, rhs: Cuboid) -> [Cuboid] {
        // If the cuboids don't overlap, simply return the first operand
        guard let overlap = cuboid.overlap(with: rhs) else {
            return [cuboid]
        }

        let cuboidDimensions = [
            // Front face: bottom row
            (
                start: (
                    cuboid.xRange.lowerBound, cuboid.yRange.lowerBound, cuboid.zRange.lowerBound
                ),
                end: (
                    overlap.xRange.lowerBound - 1, overlap.yRange.lowerBound - 1,
                    overlap.zRange.lowerBound - 1
                )
            ),
            (
                start: (
                    overlap.xRange.lowerBound, cuboid.yRange.lowerBound, cuboid.zRange.lowerBound
                ),
                end: (
                    overlap.xRange.upperBound, overlap.yRange.lowerBound - 1,
                    overlap.zRange.lowerBound - 1
                )
            ),
            (
                start: (
                    overlap.xRange.upperBound + 1, cuboid.yRange.lowerBound,
                    cuboid.zRange.lowerBound
                ),
                end: (
                    cuboid.xRange.upperBound, overlap.yRange.lowerBound - 1,
                    overlap.zRange.lowerBound - 1
                )
            ),
            // Front face: middle row
            (
                start: (
                    cuboid.xRange.lowerBound, overlap.yRange.lowerBound, cuboid.zRange.lowerBound
                ),
                end: (
                    overlap.xRange.lowerBound - 1, overlap.yRange.upperBound,
                    overlap.zRange.lowerBound - 1
                )
            ),
            (
                start: (
                    overlap.xRange.lowerBound, overlap.yRange.lowerBound, cuboid.zRange.lowerBound
                ),
                end: (
                    overlap.xRange.upperBound, overlap.yRange.upperBound,
                    overlap.zRange.lowerBound - 1
                )
            ),
            (
                start: (
                    overlap.xRange.upperBound + 1, overlap.yRange.lowerBound,
                    cuboid.zRange.lowerBound
                ),
                end: (
                    cuboid.xRange.upperBound, overlap.yRange.upperBound,
                    overlap.zRange.lowerBound - 1
                )
            ),
            // Front face: top row
            (
                start: (
                    cuboid.xRange.lowerBound, overlap.yRange.upperBound + 1,
                    cuboid.zRange.lowerBound
                ),
                end: (
                    overlap.xRange.lowerBound - 1, cuboid.yRange.upperBound,
                    overlap.zRange.lowerBound - 1
                )
            ),
            (
                start: (
                    overlap.xRange.lowerBound, overlap.yRange.upperBound + 1,
                    cuboid.zRange.lowerBound
                ),
                end: (
                    overlap.xRange.upperBound, cuboid.yRange.upperBound,
                    overlap.zRange.lowerBound - 1
                )
            ),
            (
                start: (
                    overlap.xRange.upperBound + 1, overlap.yRange.upperBound + 1,
                    cuboid.zRange.lowerBound
                ),
                end: (
                    cuboid.xRange.upperBound, cuboid.yRange.upperBound,
                    overlap.zRange.lowerBound - 1
                )
            ),
            // Back face: bottom row
            (
                start: (
                    cuboid.xRange.lowerBound, cuboid.yRange.lowerBound,
                    overlap.zRange.upperBound + 1
                ),
                end: (
                    overlap.xRange.lowerBound - 1, overlap.yRange.lowerBound - 1,
                    cuboid.zRange.upperBound
                )
            ),
            (
                start: (
                    overlap.xRange.lowerBound, cuboid.yRange.lowerBound,
                    overlap.zRange.upperBound + 1
                ),
                end: (
                    overlap.xRange.upperBound, overlap.yRange.lowerBound - 1,
                    cuboid.zRange.upperBound
                )
            ),
            (
                start: (
                    overlap.xRange.upperBound + 1, cuboid.yRange.lowerBound,
                    overlap.zRange.upperBound + 1
                ),
                end: (
                    cuboid.xRange.upperBound, overlap.yRange.lowerBound - 1,
                    cuboid.zRange.upperBound
                )
            ),
            // Back face: middle row
            (
                start: (
                    cuboid.xRange.lowerBound, overlap.yRange.lowerBound,
                    overlap.zRange.upperBound + 1
                ),
                end: (
                    overlap.xRange.lowerBound - 1, overlap.yRange.upperBound,
                    cuboid.zRange.upperBound
                )
            ),
            (
                start: (
                    overlap.xRange.lowerBound, overlap.yRange.lowerBound,
                    overlap.zRange.upperBound + 1
                ),
                end: (
                    overlap.xRange.upperBound, overlap.yRange.upperBound, cuboid.zRange.upperBound
                )
            ),
            (
                start: (
                    overlap.xRange.upperBound + 1, overlap.yRange.lowerBound,
                    overlap.zRange.upperBound + 1
                ),
                end: (cuboid.xRange.upperBound, overlap.yRange.upperBound, cuboid.zRange.upperBound)
            ),
            // Back face: top row
            (
                start: (
                    cuboid.xRange.lowerBound, overlap.yRange.upperBound + 1,
                    overlap.zRange.upperBound + 1
                ),
                end: (
                    overlap.xRange.lowerBound - 1, cuboid.yRange.upperBound,
                    cuboid.zRange.upperBound
                )
            ),
            (
                start: (
                    overlap.xRange.lowerBound, overlap.yRange.upperBound + 1,
                    overlap.zRange.upperBound + 1
                ),
                end: (overlap.xRange.upperBound, cuboid.yRange.upperBound, cuboid.zRange.upperBound)
            ),
            (
                start: (
                    overlap.xRange.upperBound + 1, overlap.yRange.upperBound + 1,
                    overlap.zRange.upperBound + 1
                ),
                end: (cuboid.xRange.upperBound, cuboid.yRange.upperBound, cuboid.zRange.upperBound)
            ),
            // Middle face: bottom row
            (
                start: (
                    cuboid.xRange.lowerBound, cuboid.yRange.lowerBound, overlap.zRange.lowerBound
                ),
                end: (
                    overlap.xRange.lowerBound - 1, overlap.yRange.lowerBound - 1,
                    overlap.zRange.upperBound
                )
            ),
            (
                start: (
                    overlap.xRange.lowerBound, cuboid.yRange.lowerBound, overlap.zRange.lowerBound
                ),
                end: (
                    overlap.xRange.upperBound, overlap.yRange.lowerBound - 1,
                    overlap.zRange.upperBound
                )
            ),
            (
                start: (
                    overlap.xRange.upperBound + 1, cuboid.yRange.lowerBound,
                    overlap.zRange.lowerBound
                ),
                end: (
                    cuboid.xRange.upperBound, overlap.yRange.lowerBound - 1,
                    overlap.zRange.upperBound
                )
            ),
            // Middle face: middle row
            (
                start: (
                    cuboid.xRange.lowerBound, overlap.yRange.lowerBound, overlap.zRange.lowerBound
                ),
                end: (
                    overlap.xRange.lowerBound - 1, overlap.yRange.upperBound,
                    overlap.zRange.upperBound
                )
            ),
            (
                start: (
                    overlap.xRange.upperBound + 1, overlap.yRange.lowerBound,
                    overlap.zRange.lowerBound
                ),
                end: (
                    cuboid.xRange.upperBound, overlap.yRange.upperBound, overlap.zRange.upperBound
                )
            ),
            // Middle face: top row
            (
                start: (
                    cuboid.xRange.lowerBound, overlap.yRange.upperBound + 1,
                    overlap.zRange.lowerBound
                ),
                end: (
                    overlap.xRange.lowerBound - 1, cuboid.yRange.upperBound,
                    overlap.zRange.upperBound
                )
            ),
            (
                start: (
                    overlap.xRange.lowerBound, overlap.yRange.upperBound + 1,
                    overlap.zRange.lowerBound
                ),
                end: (
                    overlap.xRange.upperBound, cuboid.yRange.upperBound, overlap.zRange.upperBound
                )
            ),
            (
                start: (
                    overlap.xRange.upperBound + 1, overlap.yRange.upperBound + 1,
                    overlap.zRange.lowerBound
                ),
                end: (cuboid.xRange.upperBound, cuboid.yRange.upperBound, overlap.zRange.upperBound)
            ),
        ]

        var cuboids = [Cuboid]()
        for d in cuboidDimensions {
            if d.start.0 <= d.end.0 && d.start.1 <= d.end.1 && d.start.2 <= d.end.2 {
                let xRange = d.start.0...d.end.0
                let yRange = d.start.1...d.end.1
                let zRange = d.start.2...d.end.2

                if !xRange.isEmpty && !yRange.isEmpty && !zRange.isEmpty {
                    cuboids.append(Cuboid(xRange: xRange, yRange: yRange, zRange: zRange))
                }
            }
        }

        return cuboids
    }
}
