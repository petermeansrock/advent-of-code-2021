import Foundation

public struct Spot {
    public let number: Int
    public var isMarked: Bool
    
    public init(number: Int, isMarked: Bool = false) {
        self.number = number
        self.isMarked = isMarked
    }
}

public struct BoardSystem {
    private var boards: [Board]
    private let sequence: [Int]
    
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
    
    public mutating func play() -> Int {
        for n in sequence {
            for (i, _) in boards.enumerated() {
                if let solution = boards[i].play(number: n) {
                    return solution
                }
            }
        }
        
        return -1
    }
    
    public mutating func playThroughLastBoard() -> Int {
        var activeBoards = boards.count
        var deadBoards = Array(repeating: false, count: boards.count)
        for n in sequence {
            for (i, _) in boards.enumerated() {
                if !deadBoards[i] {
                    if let solution = boards[i].play(number: n) {
                        if activeBoards == 1 {
                            return solution
                        } else {
                            activeBoards -= 1
                            deadBoards[i] = true
                        }
                    }
                }
            }
        }
        
        return -1
    }
}

public struct Board {
    private var numbers = [[Spot]]()
    private var winner: Int?
    
    public init(lines: [String]) {
        for line in lines {
            let row = line
                .split(separator: " ", omittingEmptySubsequences: true)
                .map{ Spot(number: Int($0)!) }
            self.numbers.append(row)
        }
    }
    
    public mutating func play(number: Int) -> Int? {
        for i in 0..<5 {
            for j in 0..<5 {
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
    
    /// A predicate for evaluating whether or not all spots in the array are marked.
    ///
    /// - Parameter spots: The spots to examine.
    /// - Returns: True if all spots in the array are marked, false otherwise.
    private static func isWinningSequence(in spots: [Spot]) -> Bool {
        return spots.filter{ $0.isMarked }.count == spots.count
    }
}
