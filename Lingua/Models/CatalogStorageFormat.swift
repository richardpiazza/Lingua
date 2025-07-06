import Foundation

enum CatalogStorageFormat: Codable {
    case json(directory: URL)
    case relational(medium: CatalogStorageMedium)
    
    var url: URL {
        switch self {
        case .json(let directory):
            directory
        case .relational(let medium):
            medium.url
        }
    }
}
