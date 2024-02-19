import Foundation
import Occurrence

enum LinguaError: CustomNSError, LoggableError {
    case storageBookmark
    case storageJSON
    case storageSQLite
    case expressionCreate(Error)
    case expressionDelete(Error)
    case expressionUpdate(Error)
    case projectCreate(Error)
    case projectDelete(Error)
    case projectUpdate(Error)
    case translationCreate(Error)
    case translationDelete(Error)
    case translationUpdate(Error)
    
    static var errorDomain: String { "LinguaErrorDomain" }
}
