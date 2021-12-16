import AdventOfCode
import XCTest

@testable import Library

class PacketTests: XCTestCase {
    func testParseLiteral() {
        // Arrange
        let hex = "D2FE28"
        let parser = PacketParser()

        // Act
        let packet = parser.parse(string: hex)

        // Assert
        XCTAssertEqual(packet.header.version, 6)
        XCTAssertTrue(packet is LiteralPacket)
        let literalPacket = packet as! LiteralPacket
        XCTAssertEqual(literalPacket.value, 2021)
    }

    func testParseOperatorWithFixedLength() {
        // Arrange
        let hex = "38006F45291200"
        let parser = PacketParser()

        // Act
        let packet = parser.parse(string: hex)

        // Assert
        XCTAssertEqual(packet.header.version, 1)
        XCTAssertTrue(packet is OperatorPacket)
        let operatorPacket = packet as! OperatorPacket
        XCTAssertEqual(operatorPacket.packets.count, 2)
        XCTAssertTrue(operatorPacket.packets[0] is LiteralPacket)
        XCTAssertTrue(operatorPacket.packets[1] is LiteralPacket)
        let literalPackets = operatorPacket.packets
            .map { $0 as! LiteralPacket }
        XCTAssertEqual(literalPackets[0].value, 10)
        XCTAssertEqual(literalPackets[1].value, 20)
    }

    func testParseOperatorWithPacketCount() {
        // Arrange
        let hex = "EE00D40C823060"
        let parser = PacketParser()

        // Act
        let packet = parser.parse(string: hex)

        // Assert
        XCTAssertEqual(packet.header.version, 7)
        XCTAssertTrue(packet is OperatorPacket)
        let operatorPacket = packet as! OperatorPacket
        XCTAssertEqual(operatorPacket.packets.count, 3)
        XCTAssertTrue(operatorPacket.packets[0] is LiteralPacket)
        XCTAssertTrue(operatorPacket.packets[1] is LiteralPacket)
        XCTAssertTrue(operatorPacket.packets[2] is LiteralPacket)
        let literalPackets = operatorPacket.packets
            .map { $0 as! LiteralPacket }
        XCTAssertEqual(literalPackets[0].value, 1)
        XCTAssertEqual(literalPackets[1].value, 2)
        XCTAssertEqual(literalPackets[2].value, 3)
    }

    func testParseOperatorWithNestedOperators() {
        // Arrange
        let hex = "8A004A801A8002F478"
        let parser = PacketParser()

        // Act
        let packet = parser.parse(string: hex)

        // Assert
        XCTAssertEqual(packet.header.version, 4)
        XCTAssertTrue(packet is OperatorPacket)
        let operatorPacket = packet as! OperatorPacket
        XCTAssertEqual(operatorPacket.packets.count, 1)
        XCTAssertTrue(operatorPacket.packets[0] is OperatorPacket)
        let nestedOperatorPacket = operatorPacket.packets[0] as! OperatorPacket
        XCTAssertEqual(nestedOperatorPacket.header.version, 1)
        XCTAssertEqual(packet.versionSum, 16)
    }

    func testParseWithCombinationOfOperators() {
        // Arrange
        let hex = "9C0141080250320F1802104A08"
        let parser = PacketParser()

        // Act
        let packet = parser.parse(string: hex)

        // Assert
        XCTAssertEqual(packet.value, 1)
    }

    func testParseWithDay16Input() {
        // Arrange
        let hex = InputFile(bundle: Bundle.module, day: 16).loadLines()[0]
        let parser = PacketParser()

        // Act
        let packet = parser.parse(string: hex)

        // Assert
        XCTAssertEqual(packet.versionSum, 877)
        XCTAssertEqual(packet.value, 194_435_634_456)
    }
}
