import Foundation

public class DependencyResolver {
    
    public enum Error: Swift.Error {
        case noProviderForType(Any.Type)
        case invalidCastToType(Any.Type)
    }
    
    public static let `shared` = DependencyResolver()
    
    internal var cache = [ObjectIdentifier: () -> Any]()
    
    private init() {}
    
    public func configure(with provider: DependencyProvider) {
        provider.supply(resolver: self)
    }
    
    /// Caches the function block to provide resolution at a later time.
    ///
    /// `DependencyProviders` will use this method when being asked to supply a `DependencyResolver`
    /// with dependencies.
    public func cache<T>(dependency: @escaping () -> T) {
        cache[ObjectIdentifier(T.self)] = dependency
    }
    
    /// Attempts to locate a dependency in the cache for the given type.
    ///
    /// If no provider or a type cannot be asserted, a `DependencyResolver.Error` will be thrown.
    public func resolve<T>() throws -> T {
        guard let provider = cache[ObjectIdentifier(T.self)] else {
            throw Error.noProviderForType(T.self)
        }
        
        guard let dependency = provider() as? T else {
            throw Error.invalidCastToType(T.self)
        }
        
        return dependency
    }
}

public protocol DependencyProvider {
    /// Opportunity to cache dependencies for later retrieval.
    ///
    /// This is when the 'cache()' method is utilized.
    func supply(resolver: DependencyResolver)
}
