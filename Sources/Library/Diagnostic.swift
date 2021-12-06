import Foundation

public enum Frequency {
    case most
    case least
}

public struct DiagnosticReport {
    public let gammaRate: Int
    public let epsilonRate: Int
    public let powerConsumption: Int
    public let oxygenRate: Int
    public let carbonDioxideRate: Int
    public let lifeSupportRate: Int

    public init(lines: [String]) {
        let linesOfCharacters = lines.map { Array($0) }

        (self.gammaRate, self.epsilonRate) = DiagnosticReport.determineGammaEpsilonRates(
            linesOfCharacters: linesOfCharacters)
        self.oxygenRate = DiagnosticReport.determineRateByBitCriteria(
            linesOfCharacters: linesOfCharacters, frequency: .most, tieBreak: "1")
        self.carbonDioxideRate = DiagnosticReport.determineRateByBitCriteria(
            linesOfCharacters: linesOfCharacters, frequency: .least, tieBreak: "0")

        self.powerConsumption = self.gammaRate * self.epsilonRate
        self.lifeSupportRate = self.oxygenRate * self.carbonDioxideRate
    }

    private static func determineGammaEpsilonRates(linesOfCharacters: [[Character]]) -> (Int, Int) {
        // Use frequency of binary digits to determine gamma rate in binary
        var binaryGammaRate = ""
        for i in 0..<linesOfCharacters[0].count {
            let onesAtIndex = linesOfCharacters.map { $0[i] }.filter { $0 == "1" }.count
            binaryGammaRate += (onesAtIndex > linesOfCharacters.count / 2) ? "1" : "0"
        }

        // Invert gamma rate binary to determine epsilon rate in binary
        let binaryEpsilonRate = Array(binaryGammaRate)
            .map { $0 == "1" ? "0" : "1" }
            .reduce("", +)

        return (Int(binaryGammaRate, radix: 2)!, Int(binaryEpsilonRate, radix: 2)!)
    }

    private static func determineRateByBitCriteria(
        linesOfCharacters: [[Character]], frequency: Frequency, tieBreak: Character
    ) -> Int {
        var candidates = linesOfCharacters
        for i in 0..<linesOfCharacters[0].count {
            // Create a sorted list of digit-to-count pairs
            let digitToCounts = candidates.map { $0[i] }.reduce(into: [:]) { counts, digit in
                counts[digit, default: 0] += 1
            }.sorted { $0.1 < $1.1 }

            // Select a winning digit based on the following order:
            // 1. If there's only a single digit used at this index, use it
            // 2. If there's the same number of occurrences of both digits, use the tie-break value
            // 3. If we should use least frequently used digit, grab the first key
            // 4. If we should use the most frequently used digit, grab the last key
            let winningDigit: Character
            if digitToCounts.count == 1 {
                winningDigit = digitToCounts.first!.key
            } else if Set(digitToCounts.map { $0.value }).count == 1 {
                winningDigit = tieBreak
            } else if frequency == .least {
                winningDigit = digitToCounts.first!.key
            } else {
                winningDigit = digitToCounts.last!.key
            }

            candidates = candidates.filter { $0[i] == winningDigit }
            if candidates.count == 1 {
                break
            }
        }

        return Int(String(candidates[0]), radix: 2)!
    }
}
