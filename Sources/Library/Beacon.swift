import AdventOfCode
import Collections
import Foundation
import simd

/// A summary of beacon information.
public struct BeaconSummary {
    /// The number of beacons.
    let beaconCount: Int
    /// The maximum taxicab distance between beacons.
    let maxDistance: Int
}

/// A beacon locator can, using relative-to-scanner positions of beacons, derive the number of
/// distinct beacons present in the input data set.
public struct BeaconLocator {
    private let relativeScanners: [[ThreeDimensionalPoint<Int>]]

    /// Creates a new instance.
    ///
    /// - Parameter relativeScanners: An array containing, for each scanner, a sub-array of relative
    ///   beacon locations.
    public init(relativeScanners: [[ThreeDimensionalPoint<Int>]]) {
        self.relativeScanners = relativeScanners
    }

    /// Locates distinct beacons.
    ///
    /// - Returns: A summary of beacons found.
    public func locate() -> BeaconSummary {
        var allAbsoluteScanners = [
            AbsoluteScanner(at: .init(x: 0, y: 0, z: 0), with: self.relativeScanners[0], as: 0)
        ]
        var absoluteScannersToCompare: Deque<AbsoluteScanner> = Deque()
        absoluteScannersToCompare.append(contentsOf: allAbsoluteScanners)

        var remainingRelativeScanners = self.relativeScanners[1...].enumerated()
            .map { RelativeScanner(with: $1, as: $0 + 1) }

        var scannerOrigins = [ThreeDimensionalPoint<Int>]()

        // Continue until all remaining scanners have been mapped
        while !absoluteScannersToCompare.isEmpty {
            let absoluteScanner = absoluteScannersToCompare.removeFirst()

            // Compare all relative scanners to....
            for (i, relativeScanner) in remainingRelativeScanners.enumerated().reversed() {
                if let newAbsoluteScanner = self.determineAbsolutePosition(
                    absolute: absoluteScanner, relative: relativeScanner)
                {
                    allAbsoluteScanners.append(newAbsoluteScanner)
                    absoluteScannersToCompare.append(newAbsoluteScanner)
                    remainingRelativeScanners.remove(at: i)
                    scannerOrigins.append(newAbsoluteScanner.origin)
                }
            }
        }

        if !remainingRelativeScanners.isEmpty {
            fatalError("Failed to find all scanners")
        }

        var maxDistance = 0
        for i in 0..<(scannerOrigins.endIndex - 1) {
            for j in (i + 1)..<scannerOrigins.endIndex {
                let dx = abs(scannerOrigins[i].x - scannerOrigins[j].x)
                let dy = abs(scannerOrigins[i].y - scannerOrigins[j].y)
                let dz = abs(scannerOrigins[i].z - scannerOrigins[j].z)
                let distance = dx + dy + dz
                maxDistance = max(maxDistance, distance)
            }
        }

        let beaconCount =
            allAbsoluteScanners
            .flatMap { $0.points }
            .reduce(into: Set()) { $0.insert($1) }
            .count

        return BeaconSummary(beaconCount: beaconCount, maxDistance: maxDistance)
    }

    fileprivate func determineAbsolutePosition(absolute: AbsoluteScanner, relative: RelativeScanner)
        -> AbsoluteScanner?
    {
        for orientation in relative.orientations {
            for absoluteAnchor in absolute.points {
                for relativeAnchor in orientation.points {
                    let dx = absoluteAnchor.x - relativeAnchor.x
                    let dy = absoluteAnchor.y - relativeAnchor.y
                    let dz = absoluteAnchor.z - relativeAnchor.z

                    let translation = ThreeDimensionalPoint(x: dx, y: dy, z: dz)

                    let candidateScanner = orientation.translate(by: translation)

                    if absolute.points.intersection(candidateScanner.points).count >= 12 {
                        if checkBounds(absolute: absolute, candidate: candidateScanner) {
                            return candidateScanner
                        }
                    }
                }
            }
        }

        return nil
    }

    fileprivate func checkBounds(absolute: AbsoluteScanner, candidate: AbsoluteScanner) -> Bool {
        let overlap = absolute.points.intersection(candidate.points)
        let xValues = overlap.map { $0.x }
        let yValues = overlap.map { $0.y }
        let zValues = overlap.map { $0.z }

        let xRange = xValues.min()!...xValues.max()!
        let yRange = yValues.min()!...yValues.max()!
        let zRange = zValues.min()!...zValues.max()!

        let absoluteCount =
            absolute.points
            .filter { xRange.contains($0.x) && yRange.contains($0.y) && zRange.contains($0.z) }
            .count
        let candidateCount =
            candidate.points
            .filter { xRange.contains($0.x) && yRange.contains($0.y) && zRange.contains($0.z) }
            .count

        if absoluteCount != candidateCount || candidateCount != overlap.count {
            return false
        }

        let xBound = (candidate.origin.x - 1000)...(candidate.origin.x + 1000)
        let yBound = (candidate.origin.y - 1000)...(candidate.origin.y + 1000)
        let zBound = (candidate.origin.z - 1000)...(candidate.origin.z + 1000)

        let absoluteTotalCount =
            absolute.points
            .filter { xBound.contains($0.x) && yBound.contains($0.y) && zBound.contains($0.z) }
            .count
        let candidateTotalCount =
            candidate.points
            .filter { xBound.contains($0.x) && yBound.contains($0.y) && zBound.contains($0.z) }
            .count

        if absoluteTotalCount != overlap.count {
            return false
        }

        if candidateTotalCount != candidate.points.count {
            print("Thought we had a match, but this origin doesn't contain all points, strangely")
            return false
        }

        return true
    }
}

private struct AbsoluteScanner {
    let id: Int
    let origin: ThreeDimensionalPoint<Int>
    let points: Set<ThreeDimensionalPoint<Int>>

    init(
        at origin: ThreeDimensionalPoint<Int>, with points: [ThreeDimensionalPoint<Int>], as id: Int
    ) {
        self.id = id
        self.origin = origin
        self.points =
            points
            .reduce(into: Set()) { $0.insert($1) }
    }

    init(
        at origin: ThreeDimensionalPoint<Int>, with points: Set<ThreeDimensionalPoint<Int>>,
        as id: Int
    ) {
        self.id = id
        self.origin = origin
        self.points = points
    }
}

private struct RelativeScannerOrientation {
    let id: Int
    let points: Set<ThreeDimensionalPoint<Int>>

    init(with points: Set<ThreeDimensionalPoint<Int>>, as id: Int) {
        self.id = id
        self.points = points
    }

    func rotateAroundX() -> RelativeScannerOrientation {
        return RelativeScannerOrientation(
            with:
                points
                .map { ThreeDimensionalPoint(x: $0.x, y: -1 * $0.z, z: $0.y) }
                .reduce(into: Set()) { $0.insert($1) },
            as: self.id
        )
    }

    func rotateAroundY() -> RelativeScannerOrientation {
        return RelativeScannerOrientation(
            with:
                points
                .map { ThreeDimensionalPoint(x: $0.z, y: $0.y, z: -1 * $0.x) }
                .reduce(into: Set()) { $0.insert($1) },
            as: self.id
        )
    }

    func rotateAroundZ() -> RelativeScannerOrientation {
        return RelativeScannerOrientation(
            with:
                points
                .map { ThreeDimensionalPoint(x: -1 * $0.y, y: $0.x, z: $0.z) }
                .reduce(into: Set()) { $0.insert($1) },
            as: self.id
        )
    }

    func translate(by translation: ThreeDimensionalPoint<Int>) -> AbsoluteScanner {
        let translatedPoints =
            points
            .map {
                ThreeDimensionalPoint(
                    x: $0.x + translation.x, y: $0.y + translation.y, z: $0.z + translation.z)
            }
            .reduce(into: Set()) { $0.insert($1) }
        return AbsoluteScanner(at: translation, with: translatedPoints, as: self.id)
    }
}

private struct RelativeScanner {
    let id: Int
    let orientations: [RelativeScannerOrientation]

    init(with points: [ThreeDimensionalPoint<Int>], as id: Int) {
        self.id = id
        var orientations = [RelativeScannerOrientation]()

        // First face
        orientations.append(
            RelativeScannerOrientation(
                with:
                    points
                    .reduce(into: Set()) { $0.insert($1) },
                as: self.id
            )
        )
        for i in 0...2 {
            orientations.append(orientations[i].rotateAroundY())
        }

        // Second face
        orientations.append(orientations[0].rotateAroundZ())
        for i in 4...6 {
            orientations.append(orientations[i].rotateAroundY())
        }

        // Third face
        orientations.append(orientations[4].rotateAroundZ())
        for i in 8...10 {
            orientations.append(orientations[i].rotateAroundY())
        }

        // Fourth face
        orientations.append(orientations[8].rotateAroundZ())
        for i in 12...14 {
            orientations.append(orientations[i].rotateAroundY())
        }

        // Fifth face
        orientations.append(orientations[0].rotateAroundX())
        for i in 16...18 {
            orientations.append(orientations[i].rotateAroundY())
        }

        // Sixth face
        orientations.append(orientations[10].rotateAroundX())
        for i in 20...22 {
            orientations.append(orientations[i].rotateAroundY())
        }

        self.orientations = orientations
    }
}
