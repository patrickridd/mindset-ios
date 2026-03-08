//
//  UserDefaultWrapper.swift
//  SharedUtils
//
//  Created by patrick ridd on 3/1/26.
//

import Foundation

@propertyWrapper
public struct UserDefaultWrapper<Value> {
    private let key: String
    private let defaultValue: Value
    private let container: UserDefaults

    public init(key: String, defaultValue: Value, container: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.container = container
    }

    public var wrappedValue: Value {
        get {
            container.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            container.set(newValue, forKey: key)
        }
    }
}

/// Property wrapper for optional UserDefaults values. Setting nil removes the key.
@propertyWrapper
public struct OptionalUserDefaultWrapper<Wrapped> {
    private let key: String
    private let container: UserDefaults

    public init(key: String, container: UserDefaults = .standard) {
        self.key = key
        self.container = container
    }

    public var wrappedValue: Wrapped? {
        get {
            container.object(forKey: key) as? Wrapped
        }
        set {
            if let newValue {
                container.set(newValue, forKey: key)
            } else {
                container.removeObject(forKey: key)
            }
        }
    }
}
