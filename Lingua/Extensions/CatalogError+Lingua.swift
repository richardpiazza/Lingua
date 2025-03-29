import Foundation
import TranslationCatalog
import Occurrence

extension CatalogError: @retroactive CustomNSError {
    public static var errorDomain: String { "TranslationCatalogErrorDomain" }
    
    public var errorCode: Int {
        switch self {
        case .badQuery: return 1
        case .dataTypeConversion: return 2
        case .expressionExistingWithId: return 3
        case .expressionExistingWithKey: return 4
        case .expressionId: return 5
        case .projectExistingWithId: return 6
        case .projectId: return 7
        case .translationExistingWithId: return 8
        case .translationExistingWithValue: return 9
        case .translationId: return 10
        case .unhandledQuery: return 11
        case .unhandledUpdate: return 12
        }
    }
}

extension CatalogError: @retroactive LoggableError {}
