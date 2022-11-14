import Foundation

/// Definition of a simple storage interface.
///
/// This mirrors methods and functionality provided by `Foundation.UserDefaults`.
public protocol PersistedStorage {
    /// Loads the value from the store
    func object(forKey: String) -> Any?
    /// Persists the value in the store.
    mutating func set(_ object: Any?, forKey: String)
    /// Removes the value from the store
    mutating func removeObject(forKey: String)
}

/// Extends `UserDefaults` to conform to the `PersistedStorage` protocol.
extension UserDefaults: PersistedStorage {}
