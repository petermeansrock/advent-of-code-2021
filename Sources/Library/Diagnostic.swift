//
//  File.swift
//  
//
//  Created by Peter VanLund on 12/2/21.
//

import Foundation

public struct DiagnosticReport {
    public let gammaRate: Int
    public let epsilonRate: Int
    public let powerConsumption: Int
    public let oxygenRate: Int
    public let carbonDioxideRate: Int
    public let lifeSupportRate: Int
    
    public init(lines: [String]) {
        var oneCounts: [Int] = Array(repeating: 0, count: lines[0].count)
        for line in lines {
            for (i, character) in Array(line).enumerated() {
                if character == "1" {
                    oneCounts[i] += 1
                }
            }
        }
        
        var gammaRate = ""
        var epsilonRate = ""
        for value in oneCounts {
            if value > (lines.count / 2) {
                gammaRate += "1"
                epsilonRate += "0"
            } else {
                gammaRate += "0"
                epsilonRate += "1"
            }
        }
        // Oxygen
        var oxygenCandidates = lines.map{ Array($0) }
        for i in 0..<lines[0].count {
            let digits = oxygenCandidates.map{ $0[i] }
            let ones = digits.filter{ $0 == "1" }
            let zeros = digits.filter{ $0 == "0" }
            
            var winner = -1
            if ones.count > zeros.count {
                winner = 1
            } else if zeros.count > ones.count {
                winner = 0
            } else {
                winner = 1
            }
            
            oxygenCandidates = oxygenCandidates.filter{ Int(String($0[i]))! == winner }
            if oxygenCandidates.count == 1 {
                break
            }
        }
        
        
        // Carbon dioxide
        var carbonDioxideCandidates = lines.map{ Array($0) }
        for i in 0..<lines[0].count {
            let digits = carbonDioxideCandidates.map{ $0[i] }
            let ones = digits.filter{ $0 == "1" }
            let zeros = digits.filter{ $0 == "0" }
            
            var winner = -1
            if ones.count < zeros.count {
                winner = 1
            } else if zeros.count < ones.count {
                winner = 0
            } else {
                winner = 0
            }
            
            carbonDioxideCandidates = carbonDioxideCandidates.filter{ Int(String($0[i]))! == winner }
            if carbonDioxideCandidates.count == 1 {
                break
            }
        }
        
        var oxygenString = ""
        var carbonDioxideString = ""
        for character in oxygenCandidates[0] {
            oxygenString += String(character)
        }
        for character in carbonDioxideCandidates[0] {
            carbonDioxideString += String(character)
        }
        
        // Most common, least common
        
//        Next, you should verify the life support rating, which can be determined by
//        multiplying the oxygen generator rating by the CO2 scrubber rating.
        
        self.gammaRate = Int(gammaRate, radix: 2)!
        self.epsilonRate = Int(epsilonRate, radix: 2)!
        self.powerConsumption = self.gammaRate * self.epsilonRate
        self.oxygenRate = Int(oxygenString, radix: 2)!
        self.carbonDioxideRate = Int(carbonDioxideString, radix: 2)!
        self.lifeSupportRate = self.oxygenRate * self.carbonDioxideRate
    }
}
