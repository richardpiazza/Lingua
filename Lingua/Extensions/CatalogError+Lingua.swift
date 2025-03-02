import Foundation
import TranslationCatalog
import Occurrence

extension CatalogError: @retroactive CustomNSError {
    public static var errorDomain: String { "TranslationCatalogErrorDomain" }
    
    public var errorCode: Int {
        switch self {
        case .badQuery: return 1
        case .dataTypeConversion: return 2
        case .expressionExistingWithID: return 3
        case .expressionExistingWithKey: return 4
        case .expressionID: return 5
        case .projectExistingWithID: return 6
        case .projectID: return 7
        case .translationExistingWithID: return 8
        case .translationExistingWithValue: return 9
        case .translationID: return 10
        case .unhandledQuery: return 11
        case .unhandledUpdate: return 12
        }
    }
}

extension CatalogError: @retroactive LoggableError {}
