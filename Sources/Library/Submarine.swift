import Foundation
import CoreImage

public enum Action: String {
    case forward = "forward"
    case down = "down"
    case up = "up"
}

public struct Command {
    let operation: Action
    let value: Int
    
    public init(operation: Action, value: Int) {
        self.operation = operation
        self.value = value
    }
}

public struct Position {
    public let depth: Int
    public let horizontalDistance: Int
    public let product: Int

    public init(depth: Int, horizontalDistance: Int) {
        self.depth = depth
        self.horizontalDistance = horizontalDistance
        self.product = depth * horizontalDistance
    }
}

public struct Submarine {
    public var position: Position
    
    public init(position: Position = Position(depth: 0, horizontalDistance: 0)) {
        self.position = position
    }
    
    public mutating func move(command: Command) {
        var depth = self.position.depth
        var horizontalDistance = self.position.horizontalDistance
        
        switch command.operation {
        case .forward:
            horizontalDistance += command.value
        case .down:
            depth += command.value
        case .up:
            depth -= command.value
        }
        
        self.position = Position(depth: depth, horizontalDistance: horizontalDistance)
    }
    
    public mutating func move(command: String) {
        let parts = command.components(separatedBy: " ")
        return move(command: Command(operation: .init(rawValue: parts[0])!, value: Int(parts[1])!))
    }
}
