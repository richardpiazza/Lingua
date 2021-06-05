import Foundation

@propertyWrapper
public struct Dependency<T> {
    
    private(set) var dependency: T?
    public var wrappedValue: T {
        mutating get {
            guard let dependency = self.dependency else {
                do {
                    let resolved: T = try DependencyResolver.shared.resolve()
                    self.dependency = resolved
                    return resolved
                } catch {
                    preconditionFailure("Attempted to access dependency of type '\(String(describing: T.self))', but none could be located.")
                }
            }
            
            return dependency
        }
        set {
            dependency = newValue
        }
    }
    
    public init() {}
    
    public mutating func reset() {
        dependency = nil
    }
}
