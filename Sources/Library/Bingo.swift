import Foundation

/// Represents a single spot on a bingo board which can be marked when a number is selected.
public struct Spot {
    /// The number that must be called to mark this spot.
    public let number: Int
    /// Whether or not this number has been called.
    public var isMarked: Bool
    
    /// Creates a new instance..
    ///
    /// - Parameters:
    ///   - number: The number of this spot.
    ///   - isMarked: The initial set of this spot, defaulting to `false`.
    public init(number: Int, isMarked: Bool = false) {
        self.number = number
        self.isMarked = isMarked
    }
}

/// Represents a bingo board.
public struct Board {
    private var numbers = [[Spot]]()
    private var winner: Int?
    
    /// Creates a new instance.
    ///
    /// This constructor expects multiple strings, each representing a row of numbers. The numbers
    /// per row are delimited by spaces (and may be preceded by spaces) as demonstrated in the
    /// following example:
    ///
    /// ```
    /// 22 13 17 11  0
    ///  8  2 23  4 24
    /// 21  9 14 16  7
    ///  6 10  3 18  5
    ///  1 12 20 15 19
    /// ```
    ///
    /// - Parameter lines: The Lines representing a board.
    public init(lines: [String]) {
        for line in lines {
            let row = line
                .split(separator: " ", omittingEmptySubsequences: true)
                .map{ Spot(number: Int($0)!) }
            self.numbers.append(row)
        }
    }
    
    /// Plays a number by marking all spots with the associated number.
    ///
    /// - Parameter number: The number for which to mark matching spots.
    /// - Returns: Upon playing a winning number, the winning number multiplied by the sum of all
    ///   remaining, unmarked numbers. Otherwise, returns an empty optional.
    public mutating func play(number: Int) -> Int? {
        for i in self.numbers.indices {
            for j in self.numbers[i].indices {
                if self.numbers[i][j].number == number {
                    self.numbers[i][j].isMarked = true
                }
            }
        }
        
        if self.hasWon() {
            let unmarkedSum = self.numbers
                .flatMap{ $0 } // Flatten into a single sequence
                .filter{ !$0.isMarked } // Examine only unmarked elements
                .map{ $0.number } // Retrieve the number of each element
                .reduce(0, +) // Sum
            return number * unmarkedSum
        }
        
        return nil
    }
    
    private func hasWon() -> Bool {
        return self.numbers.first(where: Board.isWinningSequence) != nil // Horizontal
            || self.numbers.columns().first(where: Board.isWinningSequence) != nil // Vertical
    }
    
    private static func isWinningSequence(in spots: [Spot]) -> Bool {
        return spots.filter{ $0.isMarked }.count == spots.count
    }
}

/// Represents multiple playable bingo boards as well as the sequence of numbers to play.
public struct BoardSystem {
    private var boards: [Board]
    private let sequence: [Int]
    
    /// Creates a new instance.
    ///
    /// This constructor expects input composed of two pieces, delimited by an empty line of data:
    /// 1. A single line of comma-delimited integers representing the sequence of numbers to play.
    /// 1. One or more board representations, delimited by empty lines of data, each board matching
    ///    the format expected by `Board`.``Board/init(lines:)``.
    ///
    /// As one example:
    ///
    /// ```
    /// 7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1
    ///
    /// 22 13 17 11  0
    ///  8  2 23  4 24
    /// 21  9 14 16  7
    ///  6 10  3 18  5
    ///  1 12 20 15 19
    ///
    ///  3 15  0  2 22
    ///  9 18 13 17  5
    /// 19  8  7 25 23
    /// 20 11 10 24  4
    /// 14 21 16 12  6
    ///
    /// 14 21 17 24  4
    /// 10 16 15  9 19
    /// 18  8 23 26 20
    /// 22 11 13  6  5
    ///  2  0 12  3  7
    /// ```
    /// - Parameter lines: Lines representing a playable sequence of numbers and multiple boards.
    public init(lines: [String]) {
        self.sequence = lines[0].components(separatedBy: ",").map({ Int($0)! })
        self.boards = []
        var boardLines: [String] = []
        for line in lines[2...] {
            if line.count == 0 {
                self.boards.append(Board(lines: boardLines))
                boardLines = []
            } else {
                boardLines.append(line)
            }
        }
    }
    
    /// Plays the sequence of numbers until the first board wins.
    ///
    /// - Returns: `Board`.``Board/play(number:)`` of the first winnig board.
    public mutating func play() -> Int? {
        return self.play(through: 1)
    }
    
    /// Plays the sequence of numbers until the last board wins.
    ///
    /// - Returns: `Board`.``Board/play(number:)`` of the last winning board.
    public mutating func playThroughLastBoard() -> Int? {
        return self.play(through: self.boards.count)
    }
    
    private mutating func play(through winningBoardCount: Int) -> Int? {
        var remainingBoards = winningBoardCount
        var deadBoards = Array(repeating: false, count: boards.count)
        for n in sequence {
            for (i, _) in boards.enumerated() {
                if !deadBoards[i] {
                    if let solution = boards[i].play(number: n) {
                        if remainingBoards == 1 {
                            return solution
                        } else {
                            remainingBoards -= 1
                            deadBoards[i] = true
                        }
                    }
                }
            }
        }
        
        return nil
    }
}
