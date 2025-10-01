//
//  AppState.swift
//  EnglishHeritage
//
//  Created by Jack Finnis on 02/10/2024.
//

import SwiftUI

@MainActor
@propertyWrapper
struct AppState<T: Codable>: DynamicProperty {
    @AppStorage var data: Data
    
    init(wrappedValue: T, _ key: Key) {
        _data = .init(wrappedValue: try! JSONEncoder().encode(wrappedValue), key.rawValue, store: .shared)
    }
    
    var wrappedValue: T {
        get { try! JSONDecoder().decode(T.self, from: data) }
        nonmutating set { data = try! JSONEncoder().encode(newValue) }
    }
    
    var projectedValue: Binding<T> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = $0 }
        )
    }
    
    enum Key: String {
        case productiveActivities
    }
}
