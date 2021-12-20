import AdventOfCode
import Foundation

/// An infinitely-sized, monochromatic image consisting of lit and dark pixels.
public struct Image {
    /// The number of lit pixels.
    public let litPixelCount: Int
    fileprivate let grid: [[Pixel]]
    fileprivate let outsidePixel: Pixel

    /// Creates a new instance.
    ///
    /// Each line of text should consist of lit pixels represented by hash characters `#` and dark
    /// pixels represented by periods `.`. For example, the following lines of text produce a valid
    /// image:
    ///
    /// ```
    /// #..#.
    /// #....
    /// ##..#
    /// ..#..
    /// ..###
    /// ```
    ///
    /// - Parameter lines: Lines of text representing an image.
    public init(lines: [String]) {
        let grid = lines.map { Array($0).map { Pixel(rawValue: $0)! } }
        self.init(grid: grid, outsidePixel: .dark)
    }

    fileprivate init(grid: [[Pixel]], outsidePixel: Pixel) {
        self.grid = grid
        self.litPixelCount = self.grid.flatMap { $0 }.filter { $0 == .light }.count
        self.outsidePixel = outsidePixel
    }

    /// Writes the image to standard out.
    public func display() {
        self.grid.forEach { row in
            print(String(row.map { $0.rawValue }))
        }
    }

    fileprivate func addBorder(of width: Int = 1) -> Image {
        // Enlarge image in all directions
        var enlargedImage = Array(
            repeating: Array(repeating: self.outsidePixel, count: self.grid[0].count + width * 2),
            count: self.grid.count + width * 2)
        for r in self.grid.indices {
            for c in self.grid[r].indices {
                // Calculate indices in enlarged image
                let rowEnlarged = r + width
                let columnEnlarged = c + width

                // Copy the original image into the enlarged image
                enlargedImage[rowEnlarged][columnEnlarged] = self.grid[r][c]
            }
        }
        return Image(grid: enlargedImage, outsidePixel: self.outsidePixel)
    }
}

/// An algorithm for enhancing an ``Image``.
public struct EnhancementAlgorithm {
    private let algorithm: [Pixel]

    /// A 512 character string concisting of `#` and `.` to represent lit and dark pixels,
    /// respectively.
    ///
    /// - Parameter algorithm: A 512 character string concisting of `#` and `.`.
    public init(algorithm: String) {
        self.algorithm = Array(algorithm).map { Pixel(rawValue: $0)! }
    }

    /// Enhances the provided image using the algorithm.
    ///
    /// - Parameter image: The image to ehance.
    /// - Returns: The enhanced image.
    public func enhance(image: Image) -> Image {
        let enlargedImage = image.addBorder()
        var enhancedImage = enlargedImage.grid
        for r in enlargedImage.grid.indices {
            for c in enlargedImage.grid[r].indices {
                // Create a list of all relevant indices
                var binary = ""
                let relevantIndices = [
                    (r - 1, c - 1), (r - 1, c), (r - 1, c + 1),
                    (r, c - 1), (r, c), (r, c + 1),
                    (r + 1, c - 1), (r + 1, c), (r + 1, c + 1),
                ]
                for relevantIndex in relevantIndices {
                    if enlargedImage.grid.indices.contains(relevantIndex.0)
                        && enlargedImage.grid[relevantIndex.0].indices.contains(relevantIndex.1)
                    {
                        binary += String(
                            enlargedImage.grid[relevantIndex.0][relevantIndex.1].number)
                    } else {
                        binary += String(enlargedImage.outsidePixel.number)
                    }
                }

                // Look up the enhanced character based on the binary string
                let algorithmIndex = Int(BinaryUInt64(from: binary)!.integerValue)

                // Lookup by index into the
                enhancedImage[r][c] = self.algorithm[algorithmIndex]
            }
        }

        // Recalculate new outside pixel
        let outsideBinary = String(repeating: String(enlargedImage.outsidePixel.number), count: 9)
        let outsideAlgorithmIndex = Int(BinaryUInt64(from: outsideBinary)!.integerValue)
        let newOutsidePixel = self.algorithm[outsideAlgorithmIndex]

        return Image(grid: enhancedImage, outsidePixel: newOutsidePixel)
    }
}

private enum Pixel: Character {
    case light = "#"
    case dark = "."

    var number: Int {
        switch self {
        case .light:
            return 1
        case .dark:
            return 0
        }
    }
}
