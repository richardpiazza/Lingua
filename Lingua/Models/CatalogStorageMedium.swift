import Foundation

enum CatalogStorageMedium: Codable {
    case coreData(fileURL: URL)
    case sqlite(fileURL: URL)
    
    var url: URL {
        switch self {
        case .coreData(let fileURL):
            fileURL
        case .sqlite(let fileURL):
            fileURL
        }
    }
}
