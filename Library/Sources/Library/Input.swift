//
//  Input.swift
//  
//
//  Created by Peter VanLund on 11/30/21.
//

import Foundation

public struct InputFile {
    private let url: URL
    
    @available(macOS 10.12, *)
    public init(day: Int) {
        self.url = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Development")
            .appendingPathComponent("Advent of Code")
            .appendingPathComponent("2021")
            .appendingPathComponent("Advent of Code 2021")
            .appendingPathComponent("Library")
            .appendingPathComponent("Inputs")
            .appendingPathComponent("\(day)")
            .appendingPathExtension("txt")
    }
    
    public func loadContents() -> String {
        return (try? String(contentsOf: self.url, encoding: .utf8))!
    }
    
    public func loadLines() -> [String] {
        return self.loadContents().components(separatedBy: .newlines).compactMap{ $0 }
    }
}
