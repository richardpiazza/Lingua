import Foundation

enum StorageMode: Equatable, Codable {
    case json(URL)
    case sqlite(URL)
    
    var url: URL {
        switch self {
        case .json(let url), .sqlite(let url): url
        }
    }
}

extension StorageMode: CustomStringConvertible {
    var description: String {
        switch self {
        case .sqlite(let url):
            "SQLite: \(url)"
        case .json(let url):
            "JSON: \(url)"
        }
    }
}
