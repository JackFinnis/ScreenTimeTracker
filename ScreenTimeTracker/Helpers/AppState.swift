//
//  AppState.swift
//  EnglishHeritage
//
//  Created by Jack Finnis on 02/10/2024.
//

import SwiftUI

@propertyWrapper
struct AppState<T: Codable>: DynamicProperty {
    @AppStorage var data: Data
    
    init(wrappedValue: T, _ key: String) {
        _data = .init(wrappedValue: try! JSONEncoder().encode(wrappedValue), key, store: .shared)
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
}
