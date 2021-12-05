import Foundation

/// Represents actions that can be performed against a submarine or its aim.
public enum Action: String {
    case forward = "forward"
    case down = "down"
    case up = "up"
}

/// Represents a command that can be performed against a submarine or its aim.
public struct Command {
    /// An operation to perform as part of the command.
    public let operation: Action
    /// A value associated with the operation to perform.
    public let value: Int
    
    /// Creates a new instance.
    ///
    /// - Parameters:
    ///   - operation: The operation to perform.
    ///   - value: The value associated with the operation to perform.
    public init(operation: Action, value: Int) {
        self.operation = operation
        self.value = value
    }
}

/// Represents the position of an undersea object.
public struct Position {
    /// The depth below the surface.
    public let depth: Int
    /// The horizontal distance traveled.
    public let horizontalDistance: Int
    /// The product of the depth and horizontal distance (for the purposes of Advent of Code).
    public let product: Int
    
    /// Creates an instance.
    /// - Parameters:
    ///   - depth: The depth below the surface.
    ///   - horizontalDistance: The horizontal distance traveled.
    public init(depth: Int, horizontalDistance: Int) {
        self.depth = depth
        self.horizontalDistance = horizontalDistance
        self.product = depth * horizontalDistance
    }
}

/// A navigable submarine.
///
/// The movement behavior of a submarine is governed by the ``Aim`` implementation passed in during initialization.
public struct Submarine {
    /// The current position of the submarine.
    public var position: Position
    private var aim: Aim
    
    /// Creates a new instance.
    ///
    /// - Parameters:
    ///   - position: The initial position of the submarine.
    ///   - aim: The aim implement which will control the submarine's movement.
    public init(at position: Position = .init(depth: 0, horizontalDistance: 0), with aim: Aim = PassThroughAim()) {
        self.position = position
        self.aim = aim
    }
    
    /// Moves the submarine by delegating to its ``Aim`` implementation.
    ///
    /// - Parameter command: The command to use for movement.
    public mutating func move(command: Command) {
        self.position = self.aim.move(from: self.position, using: command)
    }
    
    /// Moves the submarine by delegating to its ``Aim`` implementation.
    ///
    /// Examples of valid command strings include:
    ///
    /// ```
    /// forward 5
    /// down 5
    /// forward 8
    /// up 3
    /// down 8
    /// forward 2
    /// ```
    ///
    /// - Parameter command: The command, as a string, to use for movement.
    public mutating func move(command: String) {
        let parts = command.components(separatedBy: " ")
        return move(command: .init(operation: .init(rawValue: parts[0])!, value: Int(parts[1])!))
    }
}

/// An aim is invoked by a submarine in order to determine its new position upon receiving a command.
public protocol Aim {
    /// Determines the new position of a submarine based on its starting position and command.
    ///
    /// - Parameters:
    ///   - position: The starting position of the submarine.
    ///   - command: The command to evaluate.
    /// - Returns: The determined new position of the submarine.
    mutating func move(from position: Position, using command: Command) -> Position
}

/// An aim which immediately performs movement based on a ``Command``.
public struct PassThroughAim: Aim {
    /// Creates an instance.
    public init() {
    }
    
    /// Determines the new position of a submarine based on its starting position and command.
    ///
    /// - Parameters:
    ///   - position: The starting position of the submarine.
    ///   - command: The command to evaluate.
    /// - Returns: The determined new position of the submarine.
    public func move(from position: Position, using command: Command) -> Position {
        var depth = position.depth
        var horizontalDistance = position.horizontalDistance
        
        switch command.operation {
        case .forward:
            horizontalDistance += command.value
        case .down:
            depth += command.value
        case .up:
            depth -= command.value
        }
        
        return Position(depth: depth, horizontalDistance: horizontalDistance)
    }
}

/// An aim with a stored value influenced by ``Action/up`` and ``Action/down`` commands.
public struct ChargingAim: Aim {
    private var aim: Int
    
    /// Creates an instance.
    ///
    /// - Parameter initial: The initial aim value.
    public init(initial: Int = 0) {
        self.aim = initial
    }
    
    /// Determines the new position of a submarine based on its starting position and command.
    ///
    /// - Parameters:
    ///   - position: The starting position of the submarine.
    ///   - command: The command to evaluate.
    /// - Returns: The determined new position of the submarine.
    public mutating func move(from position: Position, using command: Command) -> Position {
        switch command.operation {
        case .forward:
            var depth = position.depth
            var horizontalDistance = position.horizontalDistance
            horizontalDistance += command.value
            depth += self.aim * command.value
            return Position(depth: depth, horizontalDistance: horizontalDistance)
        case .down:
            self.aim += command.value
        case .up:
            self.aim -= command.value
        }
        
        return position
    }
}
