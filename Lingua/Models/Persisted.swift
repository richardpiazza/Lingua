import Foundation

/// Property wrapper that allows for any `Codable` object to be persisted.
///
/// `Codable` is used here to allow for a multitude of types to be used. Internally, `JSONEncoder`
/// & `JSONDecoder` are used to convert the object type to/from a `Data` representation.
///
/// A `defaultValue` is specified in initialization which will be returned in place of a nil
/// persisted value returned by the `PersistedStorage`.
@propertyWrapper public struct Persisted<T: Codable> {

    public struct Identifier: ExpressibleByStringLiteral {
        public let rawValue: String
        public init(stringLiteral rawValue: String) {
            self.rawValue = rawValue
        }
    }

    public let identifier: Identifier
    public var storage: PersistedStorage
    private let defaultValue: T

    /// Initialize a `Persisted` wrapper.
    ///
    /// - parameters
    ///   - identifier: A unique value that identifies the persisted value.
    ///   - store: The `PersistedStorage` responsible for persisting the value.
    ///   - defaultValue: A value that should be returned when the store has no value.
    public init(_ identifier: Identifier, store: PersistedStorage = UserDefaults.standard, defaultValue: T) {
        self.identifier = identifier
        storage = store
        self.defaultValue = defaultValue
    }

    public var wrappedValue: T {
        get { read() }
        set(newValue) { update(newValue) }
    }

    public mutating func delete() {
        storage.removeObject(forKey: identifier.rawValue)
    }

    /// Loads the value from the store or return the `defaultValue` when no value exists.
    private func read() -> T {
        guard let data = storage.object(forKey: identifier.rawValue) as? Data else {
            return defaultValue
        }

        let value: T
        do {
            value = try decoder.decode(T.self, from: data)
        } catch {
            print(error)
            return defaultValue
        }

        return value
    }

    private mutating func update(_ value: T) {
        let data: Data
        do {
            data = try encoder.encode(value)
        } catch {
            print(error)
            return
        }

        storage.set(data, forKey: identifier.rawValue)
    }
}

/// `PersistedStorage` encoder. Declared here as computed static cannot be declared on a generic type.
private let encoder: JSONEncoder = JSONEncoder()

/// `PersistedStorage` decoder. Declared here as computed static cannot be declared on a generic type.
private let decoder: JSONDecoder = JSONDecoder()
