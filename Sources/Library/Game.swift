import Foundation

/// A deterministic game, when played, will always have the same outcome.
public struct DeterministicGame {
    private let positions: Int
    private let die: Die
    private let winningScore: Int
    private let player1Start: Int
    private let player2Start: Int

    /// Creates a new instance.
    ///
    /// - Parameters:
    ///   - positions: The number of positions on the game board.
    ///   - winningScore: The score required to win the game.
    ///   - player1Start: The starting position of the first player on the board.
    ///   - player2Start: The starting position of the second player on the board.
    public init(positions: Int = 10, winningScore: Int, player1Start: Int, player2Start: Int) {
        self.positions = positions
        self.die = DeterministicDie()
        self.winningScore = winningScore
        self.player1Start = player1Start
        self.player2Start = player2Start
    }

    /// Plays the game.
    ///
    /// - Returns: The product of the loser's score and number of rolls required to end the game.
    public func play() -> Int {
        var die = self.die
        var player1Position = self.player1Start
        var player1Score = 0
        var player2Position = self.player2Start
        var player2Score = 0
        var rollCount = 0

        while player1Score < self.winningScore && player2Score < self.winningScore {
            player1Position =
                (player1Position + die.roll() + die.roll() + die.roll() - 1) % self.positions + 1
            player1Score += player1Position
            rollCount += 3

            if player1Score >= self.winningScore {
                break
            }

            player2Position =
                (player2Position + die.roll() + die.roll() + die.roll() - 1) % self.positions + 1
            player2Score += player2Position
            rollCount += 3
        }

        return min(player1Score, player2Score) * rollCount
    }
}

/// An exhaustive game, when played, will simulate all potential outcomes.
public struct ExhaustiveGame {
    private let positions: Int
    private let winningScore: Int
    private let player1Start: Int
    private let player2Start: Int
    private var memo = [GameState: Wins]()

    /// Creates a new instance.
    ///
    /// - Parameters:
    ///   - positions: The number of positions on the game board.
    ///   - winningScore: The score required to win the game.
    ///   - player1Start: The starting position of the first player on the board.
    ///   - player2Start: The starting position of the second player on the board.
    public init(positions: Int = 10, winningScore: Int, player1Start: Int, player2Start: Int) {
        self.positions = positions
        self.winningScore = winningScore
        self.player1Start = player1Start
        self.player2Start = player2Start
    }

    /// Plays the game.
    ///
    /// - Returns: The number of wins observed for each player.
    public mutating func play() -> Wins {
        let state = GameState(
            playerTurn: 0,
            players: [
                Player(position: self.player1Start, score: 0),
                Player(position: self.player2Start, score: 0),
            ])

        return self.play(state: state)
    }

    private mutating func play(state: GameState) -> Wins {
        if memo[state] != nil {
            return memo[state]!
        }

        if let winner = state.winner(winningScore: winningScore) {
            let wins = Wins(player: winner)
            memo[state] = wins
            return wins
        }

        // Fork into 3 * 3 * 3 possible states
        var wins = Wins()
        for i in 1...3 {
            for j in 1...3 {
                for k in 1...3 {
                    wins =
                        wins
                        + self.play(state: state.roll(number: i + j + k, positions: self.positions))
                }
            }
        }
        memo[state] = wins

        return wins
    }
}

/// Contains the number of wins observed for each player.
public struct Wins {
    /// An integer array containing the wins for each player.
    ///
    /// The 0th element contains the number of wins observed for player 1, the 1st element contains
    /// the number of wins observed for player 2, and so on.
    public let counts: [Int]

    fileprivate init(counts: [Int]) {
        self.counts = counts
    }

    fileprivate init(player: Int) {
        var counts = Array(repeating: 0, count: 2)
        counts[player] = 1
        self.init(counts: counts)
    }

    fileprivate init() {
        self.init(counts: Array(repeating: 0, count: 2))
    }

    static func + (lhs: Wins, rhs: Wins) -> Wins {
        return Wins(counts: [
            lhs.counts[0] + rhs.counts[0],
            lhs.counts[1] + rhs.counts[1],
        ])
    }
}

private struct GameState: Hashable {
    fileprivate let playerTurn: Int
    fileprivate let players: [Player]

    fileprivate func hash(into hasher: inout Hasher) {
        hasher.combine(playerTurn)
        hasher.combine(players)
    }

    fileprivate func roll(number: Int, positions: Int) -> GameState {
        let currentPlayer = self.players[self.playerTurn]
        let newPosition = (currentPlayer.position + number - 1) % positions + 1
        let updatedPlayer = Player(position: newPosition, score: currentPlayer.score + newPosition)

        var players = self.players
        players[self.playerTurn] = updatedPlayer

        let newPlayerTurn = (self.playerTurn + 1) % 2
        return GameState(playerTurn: newPlayerTurn, players: players)
    }

    fileprivate func winner(winningScore: Int) -> Int? {
        for (i, player) in players.enumerated() {
            if player.score >= winningScore {
                return i
            }
        }

        return nil
    }
}

private struct Player: Hashable {
    fileprivate let position: Int
    fileprivate let score: Int

    fileprivate func hash(into hasher: inout Hasher) {
        hasher.combine(position)
        hasher.combine(score)
    }
}

private protocol Die {
    mutating func roll() -> Int
}

private struct DeterministicDie: Die {
    private var nextRoll: Int
    private let sides: Int

    fileprivate init(with sides: Int = 100) {
        self.nextRoll = 1
        self.sides = sides
    }

    fileprivate mutating func roll() -> Int {
        defer { self.nextRoll = self.nextRoll % self.sides + 1 }
        return self.nextRoll
    }
}
