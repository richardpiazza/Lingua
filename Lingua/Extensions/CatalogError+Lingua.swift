import Foundation
import Occurrence
import TranslationCatalog

extension CatalogError: @retroactive CustomNSError {
    public static var errorDomain: String { "TranslationCatalogErrorDomain" }

    public var errorCode: Int {
        switch self {
        case .badQuery: 1
        case .dataTypeConversion: 2
        case .expressionExistingWithId: 3
        case .expressionExistingWithKey: 4
        case .expressionId: 5
        case .projectExistingWithId: 6
        case .projectId: 7
        case .translationExistingWithId: 8
        case .translationExistingWithValue: 9
        case .translationId: 10
        case .unhandledQuery: 11
        case .unhandledUpdate: 12
        }
    }
}

extension CatalogError: @retroactive LoggableError {}
