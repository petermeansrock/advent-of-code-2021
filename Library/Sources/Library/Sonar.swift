//
//  Sonar.swift
//  
//
//  Created by Peter VanLund on 11/30/21.
//

import Foundation

public struct Sonar {
    public init() {
    }
    
    public func sweep(depths: [Int]) -> Int {
        var increasedDepthCount = 0

        for i in 1..<depths.count {
            if depths[i] > depths[i - 1] {
                increasedDepthCount += 1
            }
        }
        
        return increasedDepthCount
    }
}
