import AdventOfCode
import Foundation

/// Represents a packet containing information.
public protocol Packet {
    /// The packet's header.
    var header: PacketHeader { get }
    /// The packet's value.
    var value: Int { get }
    /// The sum of this packet's version and those of any contained packets.
    var versionSum: Int { get }
}

/// A packet containing a single literal value.
public struct LiteralPacket: Packet {
    /// The packet's header.
    public let header: PacketHeader
    /// A signle literal value.
    public let value: Int
    /// This packet's version.
    public let versionSum: Int

    fileprivate init(with header: PacketHeader, from scanner: inout HexScanner) {
        self.header = header

        var binaryLiteralValue = ""
        var latestBitsRead = "1"
        while latestBitsRead.starts(with: "1") {
            latestBitsRead = scanner.scanBits(count: 5)!
            binaryLiteralValue += latestBitsRead.suffix(4)
        }

        self.value = Int(BinaryUInt64(from: binaryLiteralValue)!.integerValue)
        self.versionSum = header.version
    }
}

/// An operator-specific packet containing one or more other packets.
public struct OperatorPacket: Packet {
    /// The packet's header.
    public let header: PacketHeader
    /// The associated operator type.
    public let type: OperatorType
    /// The computed value of this packet based on its operator type being applied to its contained packets.
    public let value: Int
    /// The packets contained within this packet.
    public let packets: [Packet]
    /// The sum of this packet's version and those of its contained packets.
    public let versionSum: Int

    fileprivate init(
        with header: PacketHeader, of type: OperatorType, from scanner: inout HexScanner
    ) {
        let lengthTypeId = scanner.scanBits(count: 1)!
        if lengthTypeId == "0" {
            let bitCount = Int(BinaryUInt64(from: scanner.scanBits(count: 15)!)!.integerValue)
            self.init(with: header, of: type, from: &scanner, for: bitCount)
        } else {
            let packetCount = Int(BinaryUInt64(from: scanner.scanBits(count: 11)!)!.integerValue)
            self.init(with: header, of: type, from: &scanner, until: packetCount)
        }
    }

    private init(
        with header: PacketHeader, of type: OperatorType, from scanner: inout HexScanner,
        for bitCount: Int
    ) {
        // Parse all packets in the bit sequence
        let bits = scanner.scanBits(count: bitCount)!
        var subScanner = HexScanner(bits: bits)
        let packets = PacketParser().parsePackets(scanner: &subScanner)
        self.init(with: header, of: type, containing: packets)
    }

    private init(
        with header: PacketHeader, of type: OperatorType, from scanner: inout HexScanner,
        until packetCount: Int
    ) {
        // Parse the specified number of packets
        var packets = [Packet]()
        for _ in 1...packetCount {
            packets.append(PacketParser().parsePacket(scanner: &scanner))
        }
        self.init(with: header, of: type, containing: packets)
    }

    private init(with header: PacketHeader, of type: OperatorType, containing packets: [Packet]) {
        self.header = header
        self.type = type
        self.packets = packets
        self.versionSum =
            header.version
            + packets
            .map { $0.versionSum }
            .reduce(0, +)
        let containedValues =
            packets
            .map { $0.value }
        self.value = type.evaluate(operands: containedValues)
    }
}

/// A type of operator to apply one or more ``Packet``s.
public enum OperatorType: Int {
    /// Evaluates the sum of one or more packets' values.
    case sum = 0
    /// Evaluates the product of one or more packets' values.
    case product = 1
    /// Evaluates the minimum of one or more packets' values.
    case minimum = 2
    /// Evaluates the maximum of two or more packets' values.
    case maximum = 3
    /// Evaluates to `1` if the first operand is greater than the second operator, `0` otherwise.
    case greaterThan = 5
    /// Evaluates to `1` if the first operand is less than the second operator, `0` otherwise.
    case lessThan = 6
    /// Evaluates to `1` if the first operand and second operator are equal, `0` otherwise.
    case equal = 7

    /// Applies the operator to an array of operands.
    ///
    /// - Parameter operands: The operands to which to apply the operator.
    /// - Returns: The evaluation of the operator against the operands.
    public func evaluate(operands: [Int]) -> Int {
        switch self {
        case .sum:
            return operands.reduce(0, +)
        case .product:
            return operands.reduce(1, *)
        case .minimum:
            return operands.min()!
        case .maximum:
            return operands.max()!
        case .greaterThan:
            return operands[0] > operands[1] ? 1 : 0
        case .lessThan:
            return operands[0] < operands[1] ? 1 : 0
        case .equal:
            return operands[0] == operands[1] ? 1 : 0
        }
    }
}

/// The type of a packet.
public enum PacketType {
    /// The type of a ``LiteralPacket``.
    case literal
    /// The type of an ``OperatorPacket``.
    case operate(id: Int)

    /// Returns the enumerated value based on a packet type ID.
    ///
    /// A ``LiteralPacket`` has a type ID of `4`. All other packets are interpreted as ``OperatorPacket``s.
    ///
    /// - Parameter id: The packet type ID.
    public init(id: Int) {
        switch id {
        case 4:
            self = .literal
        default:
            self = .operate(id: id)
        }
    }
}

/// The header of a packet.
public struct PacketHeader {
    /// The version of a packet.
    public let version: Int
    /// The packet's type.
    public let packetType: PacketType

    /// Creates a new instance.
    ///
    /// - Parameter binary: A binary string representing a header.
    public init?(binary: String) {
        guard let version = BinaryUInt64(from: String(binary.prefix(3))),
            let typeId = BinaryUInt64(from: String(binary.suffix(3)))
        else {
            return nil
        }

        self.version = Int(version.integerValue)
        self.packetType = .init(id: Int(typeId.integerValue))
    }
}

/// A parser capable of parsing packets.
public struct PacketParser {
    /// Parses one packet (which may containing one or more other packets within it) from the provided string of hexadecimal values.
    ///
    /// - Parameter string: A string of hexadecimal characters.
    /// - Returns: A packet parsed from the provided string.
    public func parse(string: String) -> Packet {
        var scanner = HexScanner(string: string)
        return self.parsePacket(scanner: &scanner)
    }

    fileprivate func parsePacket(scanner: inout HexScanner) -> Packet {
        // Read the header
        let header = PacketHeader(binary: scanner.scanBits(count: 6)!)!

        // Read the packet
        switch header.packetType {
        case .literal:
            return LiteralPacket(with: header, from: &scanner)
        case .operate(let id):
            return OperatorPacket(with: header, of: .init(rawValue: id)!, from: &scanner)
        }
    }

    fileprivate func parsePackets(scanner: inout HexScanner) -> [Packet] {
        var packets = [Packet]()

        while scanner.hasMoreBits() {
            packets.append(self.parsePacket(scanner: &scanner))
        }

        return packets
    }
}

private struct HexScanner {
    private var stringRemaining: String
    private var bitsRemaining: String

    fileprivate init(string: String) {
        self.stringRemaining = string
        self.bitsRemaining = ""
    }

    fileprivate init(bits: String) {
        self.stringRemaining = ""
        self.bitsRemaining = bits
    }

    fileprivate func hasMoreBits() -> Bool {
        return !(stringRemaining.isEmpty && bitsRemaining.isEmpty)
    }

    fileprivate mutating func scanBits(count: Int) -> String? {
        while bitsRemaining.count < count {
            guard self.hasMoreBits() else {
                return nil
            }

            let value = UInt64(String(stringRemaining.removeFirst()), radix: 16)!
            let binary = BinaryUInt64(from: value, with: 4)!
            bitsRemaining += binary.binaryValue
        }

        defer { bitsRemaining.removeFirst(count) }
        return String(bitsRemaining.prefix(count))
    }
}
