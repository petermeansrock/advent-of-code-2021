import Foundation

/*
 7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

 22 13 17 11  0
  8  2 23  4 24
 21  9 14 16  7
  6 10  3 18  5
  1 12 20 15 19

  3 15  0  2 22
  9 18 13 17  5
 19  8  7 25 23
 20 11 10 24  4
 14 21 16 12  6

 14 21 17 24  4
 10 16 15  9 19
 18  8 23 26 20
 22 11 13  6  5
  2  0 12  3  7
 */

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
    private var sequence: [Int]
    
    public init(lines: [String]) {
        var boards = [Board]()
        var sequence: [Int]? = nil
        var boardLines: [String]? = nil
        for line in lines {
            if sequence == nil {
                sequence = line.components(separatedBy: ",").map({ Int($0)! })
            } else if line.count == 0 && boardLines != nil {
                var newBoard = Board(lines: boardLines!)
                boards.append(newBoard)
                boardLines = [String]()
            } else if line.count == 0 {
                boardLines = [String]()
            } else {
                boardLines!.append(line)
            }
        }
        self.sequence = sequence!
        self.boards = boards
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
    private var numbers: [[Spot]]
    private var winner: Int?
    
    public init(lines: [String]) {
        var numbers = Array(repeating: Array(repeating: Spot(number: -1), count: 5), count: 5)
        for (i, line) in lines.enumerated() {
            for (j, value) in line.split(separator: " ", omittingEmptySubsequences: true).map({ Int($0)! }).enumerated() {
                numbers[i][j] = Spot(number: value)
            }
        }
        self.numbers = numbers
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
            var unmarkedSum = 0
            for i in 0..<5 {
                for j in 0..<5 {
                    if !self.numbers[i][j].isMarked {
                        unmarkedSum += self.numbers[i][j].number
                    }
                }
            }
            return number * unmarkedSum
        }
        
        return nil
    }
    
    private func hasWon() -> Bool {
        // Horizontal wins
        for i in 0..<5 {
            if self.numbers[i].filter({ $0.isMarked }).count == 5 {
                return true
            }
        }
        
        // Vertical wins
        for i in 0..<5 {
            if self.numbers.map({ $0[i] }).filter({ $0.isMarked }).count == 5 {
                return true
            }
        }
        
        return false
    }
    
    
}
