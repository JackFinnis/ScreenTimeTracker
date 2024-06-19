//
//  Array.swift
//  ScreenTimeTracker
//
//  Created by Jack Finnis on 14/05/2024.
//

import Foundation

extension Array {
    subscript(safe index: Index) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}

extension Array where Element == Double {
    func sum() -> Double {
        reduce(0) { $0 + $1 }
    }
    
    func average() -> Double {
        sum() / Double(count)
    }
}
