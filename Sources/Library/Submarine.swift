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

public protocol Aim {
    mutating func move(submarine: inout Submarine, command: Command)
}

public struct PassThroughAim: Aim {
    public init() {
    }
    
    public func move(submarine: inout Submarine, command: Command) {
        var depth = submarine.position.depth
        var horizontalDistance = submarine.position.horizontalDistance
        
        switch command.operation {
        case .forward:
            horizontalDistance += command.value
        case .down:
            depth += command.value
        case .up:
            depth -= command.value
        }
        
        submarine.position = Position(depth: depth, horizontalDistance: horizontalDistance)
    }
}

public struct ChargingAim: Aim {
    private var aim: Int
    
    public init(initial: Int = 0) {
        self.aim = initial
    }
    
    public mutating func move(submarine: inout Submarine, command: Command) {
        switch command.operation {
        case .forward:
            var depth = submarine.position.depth
            var horizontalDistance = submarine.position.horizontalDistance
            horizontalDistance += command.value
            depth += self.aim * command.value
            submarine.position = Position(depth: depth, horizontalDistance: horizontalDistance)
        case .down:
            self.aim += command.value
        case .up:
            self.aim -= command.value
        }
    }
}

public struct Submarine {
    public var position: Position
    private var aim: Aim
    
    public init(at position: Position = Position(depth: 0, horizontalDistance: 0), with aim: Aim = PassThroughAim()) {
        self.position = position
        self.aim = aim
    }
    
    public mutating func move(command: Command) {
        var aim = self.aim
        aim.move(submarine: &self, command: command)
        self.aim = aim
    }
    
    public mutating func move(command: String) {
        let parts = command.components(separatedBy: " ")
        return move(command: Command(operation: .init(rawValue: parts[0])!, value: Int(parts[1])!))
    }
}
