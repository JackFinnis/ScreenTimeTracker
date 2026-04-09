//
//  Store.swift
//  EnglishHeritage
//
//  Created by Jack Finnis on 12/11/2024.
//

import Foundation

protocol KeyValueStore {
    func object(forKey key: String) -> Any?
    func set(_ object: Any?, forKey key: String)
    func removeObject(forKey key: String)
}
extension UserDefaults: KeyValueStore {}
extension NSUbiquitousKeyValueStore: KeyValueStore {}

struct ObjectStore {
    enum Key: String {
        case none
        
        var store: KeyValueStore {
            switch self {
            case .none:
                return UserDefaults.shared
            }
        }
    }
    
    static func get<T>(key: Key) -> T? {
        key.store.object(forKey: key.rawValue) as? T
    }
    
    static func set<T>(key: Key, value: T) {
        key.store.set(value, forKey: key.rawValue)
    }
}

struct FileStore {
    static let decoder = JSONDecoder()
    static let encoder = JSONEncoder()
    
    enum Key: String {
        case productiveActivities
        case blockedActivities
    }
    
    static func get<T: Codable>(key: Key) -> T? {
        let url = URL.groupContainer.appendingPathComponent(key.rawValue)
        do {
            return try decoder.decode(T.self, from: Data(contentsOf: url))
        } catch {
            print(error)
            return nil
        }
    }
    
    static func set<T: Codable>(key: Key, value: T) {
        let url = URL.groupContainer.appendingPathComponent(key.rawValue)
        do {
            try encoder.encode(value).write(to: url)
        } catch {
            print(error)
        }
    }
}
